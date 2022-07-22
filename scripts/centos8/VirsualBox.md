#  VirsualBox 相关问题

## 安装 guest additions on RHEL 8 / CentOS 8

需要先安装相关依赖

```shell
 # dnf install tar bzip2 kernel-devel-$(uname -r) kernel-headers perl gcc make elfutils-libelf-devel -y
 # /dev/cdrom
 #mkdir -p /mnt/cdrom 
 # mount /dev/cdrom /mnt/cdrom 
 # cd /mnt/cdrom 
# ./VBoxLinuxAdditions.run


# lsmod | grep vbox
.......
```
## 启用SSH

修改配置文件

```shell
vim /etc/ssh/sshd_config


Port 22
#AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::

PasswordAuthentication yes


PermitRootLogin  yes

# systemctl restart sshd
```

## reset root password 


[reset-root-password-on-almalinux](https://blog.eldernode.com/reset-root-password-on-almalinux/)

##错误：GPG 检查失败

解决办法：

修改yum的配置文件：/etc/yum.conf

```shell
vim /etc/yum.conf

gpgcheck=0

```


curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn   INSTALL_K3S_EXEC="--docker" sh -

curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
    INSTALL_K3S_MIRROR=cn K3S_NODE_NAME=k3s1 \
    K3S_KUBECONFIG_OUTPUT=/home/escape/.kube/config \
    INSTALL_K3S_EXEC="--docker" sh -
    
    
    
    curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
    INSTALL_K3S_MIRROR=cn K3S_NODE_NAME=k3s1 \
    K3S_KUBECONFIG_OUTPUT=/home/david/.kube/config \
    INSTALL_K3S_EXEC="--docker" sh -
    
    
    ## disable Selinux
    
  
    
    
    Open the /etc/selinux/config file and set the SELINUX mod to disabled:
    
    ```
        setenforce 0
        getenforce
    ```
    
    curl -sfL https://get.k3s.io |  INSTALL_K3S_MIRROR=cn   INSTALL_K3S_EXEC="--docker"  sh - 

INSTALL_K3S_SKIP_DOWNLOAD=true   INSTALL_K3S_MIRROR=cn   INSTALL_K3S_EXEC="--docker"    ./install.sh  

yum update --nogpgcheck



cat <<EOF> /etc/sysctl.d/k8s.conf 
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv4.conf.all.rp_filter = 1
vm.swappiness=0
EOF


sysctl  --system 

cat <<EOF>  /etc/yum.repos.d/kubernetes.repo
name=Kubernetes Repository
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF


hostnamectl set-hostname k3s1

hostnamectl set-hostname master-k8s1

127.0.0.1  master-k8s1
192.168.141.120  master-k8s1


sudo setenforce 0
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux

sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab



cat <<EOF>  /etc/docker/daemon.json
{
    "insecure-registries": [
        "0.0.0.0:5000","0.0.0.0"
    ],
    "registry-mirrors": [
        "https://um1k3l1w.mirror.aliyuncs.com"
    ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}

EOF

systemctl daemon-reload   & sudo systemctl restart docker


vim /etc/yum.repos.d/kubernetes.repo 

name=Kubernetes Repository
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0

rm -rf /etc/containerd/config.toml 
systemctl restart containerd

yum install -y --nogpgcheck kubelet kubeadm kubectl

kubeadm init --apiserver-advertise-address=192.168.141.120   \
--image-repository registry.aliyuncs.com/google_containers  \
--pod-network-cidr=10.244.0.0/16


kubeadm init --apiserver-advertise-address=192.168.141.120   \
--image-repository registry.aliyuncs.com/google_containers

--feature-gates SupportPodPidsLimit=false --feature-gates SupportNodePidsLimit=false

systemctl daemon-reload   & sudo systemctl restart kubelet 


journalctl -xefu kubelet

journalctl -f  -u kubelet

kubeadm init  --image-repository registry.aliyuncs.com/google_containers

ps aux|grep kubelet

usr/libexec/kubernetes/kubelet-plugins/volume/exec/ 


/usr/lib/systemd/system/kubelet.service; 

--feature-gates=SupportPodPidsLimit=false,SupportNodePidsLimit=false


/etc/sysconfig/network-scripts/if-cfg-DEVICEID and change ONBOOT=no to ONBOOT=yes

# firewall-cmd --permanent --add-port=53/udp

# firewall-cmd --reload



yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

journalctl -xefu k3s


curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
    INSTALL_K3S_MIRROR=cn K3S_NODE_NAME=k3s1 \
    K3S_KUBECONFIG_OUTPUT=/home/root/.kube/config \
    INSTALL_K3S_EXEC="--docker" sh -
    
    
    ### helm3
    
    $ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    $ chmod 700 get_helm.sh
    $ ./get_helm.sh


curl -s -L "https://github.com/loft-sh/vcluster/releases/latest" | sed -nE 's!.*"([^"]*vcluster-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o vcluster && chmod +x vcluster;
sudo mv vcluster /usr/local/bin

vcluster --version

helm upgrade --install my-vcluster vcluster \
  --values vcluster.yaml \
  --repo https://charts.loft.sh \
  --namespace host-namespace-1 \
  --repository-config=''
  
  
  报错信息:

Error: Kubernetes cluster unreachable: Get "http://localhost:8080/version?timeout=32s": dial tcp [::1]:8080: connect: connection refused

报错原因: helm v3版本不再需要Tiller，而是直接访问ApiServer来与k8s交互，通过环境变量KUBECONFIG来读取存有ApiServre的地址与token的配置文件地址，默认地址为~/.kube/config

解决方法:

手动配置 KUBECONFIG环境变量

临时解决: export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

export KUBECONFIG=~/.kube/config

永久解决:

执行: vi /etc/profile
写入内容: export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
执行: source /etc/profile



yum install kernel-devel gcc

kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name -n cattle-system) 9000:9000 -n cattle-system

http://traefik.k3s1.com/dashboard/

kubectl port-forward $(kubectl get pods --selector "app.kubernetes.io/name=traefik" --output=name -n kube-system) 9000:9000 -n kube-system

kubectl port-forward  traefik-df4ff85d6-8tbqv  9000:9000 -n kube-system
traefik-df4ff85d6-8tbqv


 sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | \
    INSTALL_K3S_MIRROR=cn K3S_NODE_NAME=k3s1 \
    K3S_KUBECONFIG_OUTPUT=/home/root/.kube/config \
    INSTALL_K3S_EXEC="--docker" sh -
    
me@yunali222
