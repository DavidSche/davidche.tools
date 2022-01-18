# 离线安装k3s（centos7 环境）


## 准备工作

### 安装docker 环境 

#### 二进制方式安装 docker 

[download url](https://download.docker.com/linux/centos/7/x86_64/stable/Packages/)

下载二进制文件包

```

wget https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz
wget https://download.docker.com/linux/static/stable/x86_64/docker-rootless-extras-20.10.9.tgz

```
解压文件

```
tar xzvf docker-20.10.9.tgz
tar xzvf docker-rootless-extras-20.10.9.tgz

```

复制文件
```shell
cp docker/* /usr/bin/
cp docker-rootless-extras/* /usr/bin/

```

启动Docker Engine

```shell
 dockerd &
 
 docker run hello-world

```

制作系统自动启动文件 /etc/systemd/system/docker.service

```shell
vi /etc/systemd/system/docker.service

/usr/lib/systemd/system/docker.service

```

添加文件内容：

```
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target

```

添加执行权限

```shell
chmod +x /etc/systemd/system/docker.service

systemctl daemon-reload
```


开机启动

```shell
systemctl enable docker.service
```

启动docker

```shell
systemctl start docker
```

##### 安装基本必须


```
 yum install --downloadonly --downloaddir=/home/docker createrepo   
 
```
##### 

### 搭建本地registry   hub

生成密钥文件

```shell
#!/usr/bin/env bash

cd /opt
pwd
# /opt/certs/
# 生成证书
#mkdir -p certs -f
if [ ! -d certs ]; then
  mkdir -p certs
  echo " mkdir certs success ! "
fi

openssl req \
 -newkey rsa:4096 \
 -nodes -sha256 \
 -keyout certs/hub.mpaas.com.key \
 -x509 -days 3600 -subj "/CN=hub.mpaas.com"  \
 -out certs/hub.mpaas.com.crt
# 将证书复制到系统证书中
cat /opt/certs/hub.mpaas.com.crt >> /etc/ssl/certs/ca-certificates.crt

# 将域名写入/etc/hosts
HOSTNAME=`hostname`
hub_url="hub.mpaas.com"
#hub_ip="127.0.0.1"
#获取主机IP 地址
hub_ip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

hub_ip_map="${hub_ip} ${hub_url}"
#inner_ip_map="${in_ip} ${in_url}"
echo ${hub_ip_map} >> /etc/hosts

#echo "127.0.0.1  hub.mpaas.com" >> /etc/hosts

echo "${hub_ip_map} wrrite to hosts success !"
#设置docker engine 的证书信息
#mkdir -p /etc/docker/certs.d/
if [ ! -d /etc/docker/certs.d/ ];then
  mkdir -p /etc/docker/certs.d/
  echo " mkdir /etc/docker/certs.d/ success ! "
fi
#exit
cp /opt/certs/hub.mpaas.com.crt /etc/docker/certs.d/
echo "copy hub.mpaas.com.crt to /etc/docker/certs.d/ success ! "

```
使用docker-compose.yml部署registry及registry-ui 服务

```yaml
version: '3.0'

# https://github.com/Joxit/docker-registry-ui

services:
  registry:
    image: registry:2.7.1
    volumes:
      - registry-data:/var/lib/registry
      - /opt/certs/:/certs
    ports:
      - 443:443
    networks:
      - net-registry
    environment:
#      - TZ=${TIME_ZONE}
      - REGISTRY_HTTP_HEADERS_X-Content-Type-Options=[nosniff]
      - REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin=['*']
      - REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods=['HEAD', 'GET', 'OPTIONS', 'DELETE']
      - REGISTRY_HTTP_HEADERS_Access-Control-Expose-Headers=['Docker-Content-Digest']
      - REGISTRY_HTTP_HEADERS_Access-Control-Max-Age=[1728000]
      - REGISTRY_HTTP_HEADERS_Access-Control-Allow-Credentials=[true]
      - REGISTRY_HTTP_ADDR=0.0.0.0:443
      - REGISTRY_HTTP_TLS_CERTIFICATE=/certs/hub.mpaas.com.crt
      - REGISTRY_HTTP_TLS_KEY=/certs/hub.mpaas.com.key
      #      - REGISTRY_HTTP_HEADERS_Access-Control-Allow-Credentials=[true]
      - REGISTRY_STORAGE_DELETE_ENABLED=true

    deploy:
      mode: replicated
      replicas: 1
      placement:
        # constraints: [node.labels.pm-node == true]  # 部署标签约束
        # docker node update --label-add registry-node=true
        constraints: [node.labels.registry-node == true]  # 部署标签约束
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "3"
  ui:
    image: joxit/docker-registry-ui:latest
    ports:
      - 1080:80
    environment:
      - REGISTRY_TITLE=My Private Docker Registry
      - NGINX_PROXY_PASS_URL=https://registry:443
      - PULL_URL=hub.mpaas.com
      - DELETE_IMAGES=true
      - SINGLE_REGISTRY=true
    depends_on:
      - registry
    networks:
      - net-registry
    deploy:
      mode: replicated
      replicas: 1
      placement:
        # constraints: [node.labels.pm-node == true]  # 部署标签约束  docker node update --label-add registry-node=true
        constraints: [node.labels.registry-node == true]  # 部署标签约束
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "3"

networks:
  net-registry:

volumes:
  registry-data:
    external: true
  
```

## 安装k3s


### 准备k3s安装包

#### 获取k3s-selinux-0.5-1.el7.noarch.rpm
 
从以下页面获取对应的安装包

[https://github.com/k3s-io/k3s-selinux/releases](https://github.com/k3s-io/k3s-selinux/releases)

使用rpm命令安装

```shell

rpm -ivh  k3s-selinux-0.5-1.el7.noarch.rpm

```

获取  k3s 

[https://github.com/k3s-io/k3s/releases/download/v1.23.1%2Bk3s2/k3s](https://github.com/k3s-io/k3s/releases/download/v1.23.1%2Bk3s2/k3s)
```shell
curl -sfL -O https://github.com/k3s-io/k3s/releases/download/v1.23.1%2Bk3s2/k3s

chmod +x ./k3s
sudo cp ./k3s /usr/local/bin/ 

```
将 k3s 二进制文件放在 /usr/local/bin/k3s 路径下，并确保拥有可执行权限。完成后，

获取k3s 对应的image 包 k3s-airgap-images-amd64.tar

[k3s-airgap-images-amd64.tar](https://github.com/k3s-io/k3s/releases/download/v1.23.1%2Bk3s2/k3s-airgap-images-amd64.tar)

k3s-images.txt

```txt
docker.io/rancher/klipper-helm:v0.6.6-build20211022
docker.io/rancher/klipper-lb:v0.3.4
docker.io/rancher/local-path-provisioner:v0.0.20
docker.io/rancher/mirrored-coredns-coredns:1.8.4
docker.io/rancher/mirrored-library-busybox:1.32.1
docker.io/rancher/mirrored-library-traefik:2.5.0
docker.io/rancher/mirrored-metrics-server:v0.5.0
docker.io/rancher/mirrored-pause:3.1

```

加载镜像到本地

```shell
docker load --quiet -i k3s-airgap-images-amd64.tar

# docker image ls  --filter "reference=rancher/*"
REPOSITORY                         TAG                    IMAGE ID       CREATED        SIZE
rancher/klipper-lb                 v0.3.4                 746788bcc27e   2 months ago   8.08MB
rancher/klipper-helm               v0.6.6-build20211022   194c895f8d63   2 months ago   241MB
rancher/mirrored-library-traefik   2.5.0                  3c1baa65c343   5 months ago   96.9MB
rancher/local-path-provisioner     v0.0.20                933989e1174c   5 months ago   35MB
rancher/mirrored-coredns-coredns   1.8.4                  8d147537fb7d   7 months ago   47.6MB
rancher/mirrored-metrics-server    v0.5.0                 1c655933b9c5   8 months ago   63.5MB
rancher/mirrored-library-busybox   1.32.1                 388056c9a683   9 months ago   1.23MB
rancher/mirrored-pause             3.1                    da86e6ba6ca1   4 years ago    742kB


```

从K3s GitHub Release页面获取你所运行的 K3s 版本的镜像 tar 文件。

将 tar 文件放在images目录下，例如：

```shell
sudo mkdir -p /var/lib/rancher/k3s/agent/images/
sudo cp ./k3s-airgap-images-$ARCH.tar /var/lib/rancher/k3s/agent/images/

```

将 k3s 二进制文件放在 /usr/local/bin/k3s 路径下，并确保拥有可执行权限。完成后，现在可以转到下面的安装 K3s部分，开始安装 K3s。


获取k3s 安装脚本文件

```shell

curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh  -o install.sh
chmod +x install.sh


```

#### 安装k3s

##### 前提条件

 - 在安装 K3s 之前，完成上面的部署私有镜像仓库或手动部署镜像，导入安装 K3s 所需要的镜像。
 - 从 release 页面下载 K3s 二进制文件，K3s 二进制文件需要与离线镜像的版本匹配。将二进制文件放在每个离线节点的 /usr/local/bin 中，并确保这个二进制文件是可执行的。
 - 下载 K3s 安装脚本：https://get.k3s.io 。将安装脚本放在每个离线节点的任意地方，并命名为 install.sh。

offline 方式安装k3s server

要在单个服务器上安装 K3s，只需在 server 节点上执行以下操作：

```shell
INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh

```
或

```shell

export INSTALL_K3S_SKIP_DOWNLOAD=true
sh k3s-install.sh


```
然后，要选择添加其他 agent，请在每个 agent 节点上执行以下操作。注意将 myserver 替换为 server 的 IP 或有效的 DNS，并将 mynodetoken 替换 server 节点的 token，通常在/var/lib/rancher/k3s/server/node-token。

```shell

# cat /var/lib/rancher/k3s/server/node-token
K10fa7d29481751f7caa017200d63a494ae34592055bdd163a16fa7058830a798bb::server:d6776a60852d19df34e4c4441275e1a9


INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken ./install.sh

```
> 注意:
   K3s 还为 kubelets 提供了一个--resolv-conf标志，这可能有助于在离线网络中配置 DNS。


在线方式

```shell
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -
```

## 安装portainer


### Docker 方式

```shell

docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:2.11.0
    
```

###  安装k8s agent 代理

portainer-agent-k8s.yaml

```yaml

apiVersion: v1
kind: Namespace
metadata:
  name: portainer
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: portainer-sa-clusteradmin
  namespace: portainer
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: portainer-crb-clusteradmin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: portainer-sa-clusteradmin
  namespace: portainer
---
apiVersion: v1
kind: Service
metadata:
  name: portainer-agent
  namespace: portainer
spec:
  type: NodePort
  selector:
    app: portainer-agent
  ports:
    - name: http
      protocol: TCP
      port: 9001
      targetPort: 9001
      nodePort: 30778
---
apiVersion: v1
kind: Service
metadata:
  name: portainer-agent-headless
  namespace: portainer
spec:
  clusterIP: None
  selector:
    app: portainer-agent
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: portainer-agent
  namespace: portainer
spec:
  selector:
    matchLabels:
      app: portainer-agent
  template:
    metadata:
      labels:
        app: portainer-agent
    spec:
      serviceAccountName: portainer-sa-clusteradmin
      containers:
      - name: portainer-agent
        image: portainer/agent:2.11.0
        imagePullPolicy: Always
        env:
        - name: LOG_LEVEL
          value: DEBUG
        - name: AGENT_CLUSTER_ADDR
          value: "portainer-agent-headless"
        - name: KUBERNETES_POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        ports:
        - containerPort: 9001
          protocol: TCP


```

