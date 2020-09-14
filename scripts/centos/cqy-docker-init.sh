#!/usr/bin/env bash

# 使用 *hostnamectl* 命令设置主机名称信息
#查看Linux 版本信息：
echo " RedHat Linux 版本信息 !"

cat  /etc/redhat-release
#查看Linux内核版本信息
echo "Linux虚拟机内核版本信息 !"
cat /proc/version
# DNS
#vi或者vim /etc/resolv.conf    #一般情况下是设置nameserver 114.114.114.114

# for 
echo "setting vm.max_map_count=262144 !"
sysctl -w vm.max_map_count=262144

echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sudo sysctl -p

#yum update && yum install -y iputils-ping

echo "setting firewall, add swarm port to firewall !"
# 例如在centos 7下执行以下命令开放端口
#查看所有打开的端口： firewall-cmd --zone=public --list-ports

#添加
#firewall-cmd --zone=public --add-port=80/tcp --permanent    （--permanent永久生效，没有此参数重启后失效）
#重新载入
#firewall-cmd --reload
#查看
#firewall-cmd --zone=public --query-port=80/tcp
#删除
#firewall-cmd --zone=public --remove-port=80/tcp --permanent
#批量开放端口
#firewall-cmd --permanent --zone=public --add-port=100-500/tcp

#!/usr/bin/env bash
# sudo systemctl enable  firewalld
# sudo systemctl start  firewalld

firewall-cmd --add-port=2376/tcp --permanent
firewall-cmd --add-port=2377/tcp --permanent
firewall-cmd --add-port=7946/tcp --permanent
firewall-cmd --add-port=7946/udp --permanent
firewall-cmd --add-port=4789/udp --permanent
firewall-cmd --add-port=4789/tcp --permanent

firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=10050/tcp --permanent


firewall-cmd --add-port=9000/tcp --permanent
firewall-cmd --add-port=9001/tcp --permanent
firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --add-port=3307/tcp --permanent

# 批量开放端口
# firewall-cmd --permanent --zone=public --add-port=100-500/tcp
# firewall-cmd --permanent --zone=public --add-port=100-500/udp

sudo firewall-cmd --reload
sudo systemctl restart  firewalld

firewall-cmd --zone=public --list-ports

netstat -ntlp
 
#sudo reboot
echo "set firewall ok !"

yum update -y

echo "install system utils & tools!"
sudo yum install net-tools -y
sudo yum install psmisc -y
sudo yum install wget -y
sudo yum install curl -y
sudo yum install yum-plugin-ovl -y
sudo yum install yum-utils -y


# install docker
echo "install docker engine ！"

#  docker-18.09.9.tgz              2019-09-04 18:23:09 53.7 MiB
#wget  https://download.docker.com/linux/static/stable/x86_64/docker-19.03.2.tgz  
#tar xzvf docker-18.09.5.tgz 
#sudo cp -rf docker/* /usr/local/bin/
#sudo dockerd &
#docker version
#sudo docker swarm init --advertise-addr 10.140.0.6 --listen-addr 10.140.0.6:2377

sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum install docker-ce -y

# 桥接网络
sysctl net.ipv4.conf.all.forwarding=1

echo "config docker"
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl stop docker

echo "write  docker config to /etc/docker/daemon.json "

#echo "{ " > /etc/docker/daemon.json
#echo -e " \"insecure-registries\": [\"172.19.4.40:5000\"],  " >> /etc/docker/daemon.json
#echo -e " \"registry-mirrors\": [\"https://um1k3l1w.mirror.aliyuncs.com\"]   " >> /etc/docker/daemon.json
#echo -e "}" >> /etc/docker/daemon.json


# >> 追加文件写入 > 覆盖文件写入

cat << EOF > /etc/docker/daemon.json
{
    "insecure-registries": [
        "192.168.9.10:5000"
    ],
    "registry-mirrors": [
        "https://um1k3l1w.mirror.aliyuncs.com"
    ],
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ]
}
EOF

echo "write daemon.json setting success ! "
#应用最新的BUILDKIT构建架构
export DOCKER_BUILDKIT=1
# 桥接网络
sysctl net.ipv4.conf.all.forwarding=1
# WARNING: bridge-nf-call-iptables is disabled
sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.bridge.bridge-nf-call-ip6tables=1

systemctl daemon-reload && systemctl restart docker

echo "restart docker ok! "

# docker-compose
echo "install docker-compose ! "
curl -L https://github.com/docker/compose/releases/download/1.25.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
#
#curl -L https://github.com/docker/compose/releases/download/1.25.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose
# scp 192.168.9.20:/usr/local/bin/docker-compose  /usr/local/bin/
echo "install docker-compose ok !"


# ----over !
echo "init os lib success ok! "
