#!/bin/sh

yum update -y 
# 三台主机全部关闭防火墙:
systemctl stop firewalld && systemctl disable firewalld
# 关闭selinux: 
sed -i 's/enforcing/disabled/' /etc/selinux/config 
# 关闭selinux: 
setenforce 0
#关闭swap: 
sed -i '/ swap / s/^ (.*)$/#1/g' /etc/fstab
swapoff -a
#设置时区
timedatectl set-timezone "Asia/Shanghai"
#设置HOST
cat >> /etc/hosts << EOF
10.10.102.53 k8s-node-53
10.10.102.54 k8s-node-54
10.10.102.55 k8s-node-55
10.10.8.6 k8s-node-aliyun
EOF

# 将桥接的IPv4流量传递到iptables的链(三台主机都执行): 
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

 yum install -y yum-utils
  yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

 yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

systemctl daemon-reload && systemctl enable docker  && systemctl start docker   
echo "start docker ok! "
systemctl stop docker
echo "stop docker ok! "

# >> 追加文件写入 > 覆盖文件写入
cat << EOF > /etc/docker/daemon.json
{
    "insecure-registries": [
        "0.0.0.0/0"
    ],
    "registry-mirrors": [
        "https://um1k3l1w.mirror.aliyuncs.com"
    ],
    "metrics-addr" : "0.0.0.0:9323",
    "experimental" : true,
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m",
      "max-file": "3",
      "labels": "production_status",
      "env": "os,customer"
    }
}
EOF
echo " write daemon.json setting success ! "

#应用最新的BUILDKIT构建架构
export DOCKER_BUILDKIT=1
# 桥接网络  SPRING.PROFILES.ACTIVE
sysctl net.ipv4.conf.all.forwarding=1
# WARNING: bridge-nf-call-iptables is disabled
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.bridge.bridge-nf-call-ip6tables=1

systemctl daemon-reload && systemctl restart docker

echo "restart docker ok! "
sudo docker info 


#k3s setting 
cat >> /etc/profile << EOF
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
EOF

source /etc/profile







