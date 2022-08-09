# K3S 国内环境搭建

## 准备环境

### 关闭防火墙:

```shell
# systemctl stop firewalld && systemctl disable firewalld
```

### 关闭selinux

```shell
# sed -i 's/enforcing/disabled/' /etc/selinux/config 
# setenforce 0
```

### 关闭swap

```shell
# swapoff -a  # 临时关闭
# vi /etc/fstab 注释掉swap那一行 # 永久关闭

```

设置时区(选项)

```shell
timedatectl set-timezone "Asia/Shanghai"
```

添加主机名与IP对应关系(主机都执行)：

```shell
# cat >> /etc/hosts << EOF
10.10.100.53 k8s-master-53
10.10.100.54 k8s-node-54
47.104.82.131 k8s-node-43
EOF

```

设置  主机主机名(名称必须符合规范，不能使用_)

```shell
# hostnamectl set-hostname  k8s-master-53
```

将桥接的IPv4流量传递到iptables的链(主机都执行)：

```shell
# cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
# sysctl --system
```

## 安装软件

安装docker-ce

```shell
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "config docker"
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl stop docker

echo "write  docker config to /etc/docker/daemon.json "

cat << EOF > /etc/docker/daemon.json
{
    "insecure-registries": [
        "0.0.0.0:5000"
    ],
    "registry-mirrors": [
        "https://um1k3l1w.mirror.aliyuncs.com"
    ],  
    "log-driver": "json-file",
    "log-opts": {
    "max-size": "300m",
    "max-file": "3",
    "labels": "production_status",
    "env": "os,customer"
    }
}
EOF

cat << EOF > /etc/docker/daemon.json
{
    "insecure-registries": [
        "192.168.9.10:5000"
    ],
    "registry-mirrors": [
        "https://um1k3l1w.mirror.aliyuncs.com"
    ],
    "graph": "/home/docker",
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ]
}
EOF

#应用最新的BUILDKIT构建架构
export DOCKER_BUILDKIT=1

cat >> /etc/profile << EOF
export DOCKER_BUILDKIT=1
EOF
source /etc/profile

# 桥接网络
sysctl net.ipv4.conf.all.forwarding=1
# WARNING: bridge-nf-call-iptables is disabled
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.bridge.bridge-nf-call-ip6tables=1

systemctl daemon-reload && systemctl restart docker

echo "restart docker ok! "

# another demo 

cat << EOF > /etc/docker/daemon.json
{
    "insecure-registries": [
        "0.0.0.0:5000"
    ],
    "registry-mirrors": [
        "https://um1k3l1w.mirror.aliyuncs.com"
    ]
    #"graph": "/home/docker",

}
EOF


```

## 安装K3s

### master 节点

```shell
curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh | INSTALL_K3S_VERSION=v1.23.9+k3s1 \           INSTALL_K3S_MIRROR=cn  \
    INSTALL_K3S_EXEC="--docker" sh -
```

#### 查看服务

```shell
systemctl daemon-reload && systemctl restart k3s
```

#### 查看token

```shell
[root@k8s-53 k3s]# sudo cat /var/lib/rancher/k3s/server/token
K103110d9db14ba7bf014d0c710c5ec9c59055ec729223b5c750b5ca04f61816fbb::server:f9d81a1ccb996a715f936b9417b76d8c

```

### worker节点

```shell
curl -sfL https://rancher-mirror.oss-cn-beijing.aliyuncs.com/k3s/k3s-install.sh |  INSTALL_K3S_VERSION=v1.23.9+k3s1 \
    INSTALL_K3S_MIRROR=cn K3S_URL=https://10.10.100.53:6443  \
    K3S_TOKEN=K103110d9db14ba7bf014d0c710c5ec9c59055ec729223b5c750b5ca04f61816fbb::server:f9d81a1ccb996a715f936b9417b76d8c  \
    INSTALL_K3S_EXEC="--docker" sh -

```

Set the environment variables

export K3S_TOKEN=<Token from master>

export MASTER_IP=<master node IP>
Regular internet facing install:

```shell
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.21.0+k3s1 K3S_TOKEN="${K3S_TOKEN}" K3S_URL=https://${MASTER_IP}:6443 sh -

#Internal network install


export NODE_INTERNAL_IP=192.168.0.1

export INTERNAL_INTERFACE=eth0

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.21.0+k3s1 K3S_TOKEN="${K3S_TOKEN}" \
K3S_URL=https://${MASTER_IP}:6443 INSTALL_K3S_EXEC="--node-ip ${NODE_INTERNAL_IP} --flannel-iface ${INTERNAL_INTERFACE}" \
sh -
```

### 查看k3s日志

```shell
 journalctl -r -u k3s
 journalctl -r -u kubelet
```

## 卸载

### **Server**

```shell
/usr/local/bin/k3s-uninstall.sh
```

### **Agent**

```shell
/usr/local/bin/k3s-agent-uninstall.sh

```

#### **安装helm**

```shell
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

```

### 安装portainer

```shell
helm repo add portainer https://portainer.github.io/k8s/
helm repo update

helm install --create-namespace -n portainer portainer portainer/portainer --set tls.force=true

#kubectl apply -n portainer -f https://downloads.portainer.io/ce2-14/portainer.yaml
#访问 https://localhost:30779/ or http://localhost:30777/
#访问 https://ip:30779

```

## 其他操作

### 查看pod日志

```shell
kubectl get pods -o wide

kubectl describe pods helm-install-traefik-t·   cvjk -n kube-system

kubectl delete pod pod-name
kubectl delete pods pod_name --grace-period=0 --force

```

### 参考

<https://k3s.rocks/install-setup/>

[k3s加速k8s集群学习](https://www.escapelife.site/posts/3782d272.html)
[K3S工具进阶完全指南](https://www.escapelife.site/posts/754ba85c.html)
[快速入门指南](https://docs.rancher.cn/docs/k3s/quick-start/_index/)

-------

# 实用K3S/K3D 管理集群

## How To: Deploy K3S using K3D with all node ports available, and then managing it with Portainer

So, deploying a K3S single node lab is easy, but what if you want to up the "realism" of your lab, and have multiple Kubernetes Nodes running as a cluster, but all of this actually running on a single Server; well thats where K3D comes in... K3D makes the process of creation a virtual multi-node cluster, that runs on a single server, easy.. however... if you want to externally expose Kubernetes services you deploy within the K3S Cluster, how can you do that? Watch and learn..

Commands used in the Video:
apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL <https://download.docker.com/linux/ubu>... | sudo apt-key add
add-apt-repository "deb [arch=amd64] <https://download.docker.com/linux/ubuntu>  $(lsb_release -cs)  stable"
apt-get update
apt-get install docker-ce

curl -LO <https://storage.googleapis.com/kubern>...`curl -s https://storage.googleapis.com/kubern...`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

curl -s <https://raw.githubusercontent.com/ran>... | bash

k3d cluster create portainer --api-port 6443 --servers 1 --agents 3 -p 30000-32767:30000-32767@server[0]

curl -LO <https://raw.githubusercontent.com/por>...
kubectl apply -f portainer-nodeport.yaml
