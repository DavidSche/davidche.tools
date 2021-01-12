#!/usr/bin/env bash

# 使用 *hostnamectl* 命令设置主机名称信息
#查看Linux 版本信息：

# 设置阿里云yum源仓库
#curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

echo " RedHat Linux 版本信息 !"

cat  /etc/redhat-release


#echo "setting hostname !"
#hostnamectl --static set-hostname sjjy-test-node7


#!/usr/bin/env bash
echo "setting vm.max_map_count=262144 !"
sysctl -w vm.max_map_count=262144

echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sudo sysctl -p

#yum update && yum install -y iputils-ping

#diable firewall
#echo "disable firewall !"
#sudo systemctl stop firewalld
#sudo systemctl disable firewalld

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
firewall-cmd --add-port=9200/tcp --permanent
firewall-cmd --add-port=5601/tcp --permanent
firewall-cmd --add-port=9411/tcp --permanent
firewall-cmd --add-port=8400/tcp --permanent
firewall-cmd --add-port=8500/tcp --permanent
firewall-cmd --add-port=8600/tcp --permanent
firewall-cmd --add-port=6379/tcp --permanent
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --add-port=8700/tcp --permanent
firewall-cmd --add-port=8888/tcp --permanent
firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --add-port=3307/tcp --permanent

firewall-cmd --add-port=8900/tcp --permanent
firewall-cmd --add-port=5672/tcp --permanent
firewall-cmd --add-port=15672/tcp --permanent

# 批量开放端口
# firewall-cmd --permanent --zone=public --add-port=100-500/tcp
# firewall-cmd --permanent --zone=public --add-port=100-500/udp

sudo firewall-cmd --reload
sudo systemctl restart  firewalld

firewall-cmd --zone=public --list-ports

netstat -ntlp
 
 
#sudo reboot
echo "set firewall ok !"

#如果没有安装ntp服务器，刚需要先执行以下命令：
#echo "set date !"
#sudo yum install ntp -y
#同步时间使用ntpdate命令如下:
#sudo ntpdate cn.pool.ntp.org
#sudo hwclock --systohc

echo "install system utils & tools!"
sudo yum install net-tools -y
sudo yum install psmisc -y
sudo yum install wget -y
sudo yum install curl -y
sudo yum install yum-plugin-ovl -y
sudo yum install yum-utils -y
sudo yum install psmisc -y 

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

# 存储路径 
#    "graph": "/home/data/docker",

# >> 追加文件写入 > 覆盖文件写入

cat << EOF > /etc/docker/daemon.json
{
    "insecure-registries": [
        "192.168.9.10:5000"
    ],
    "registry-mirrors": [
        "https://um1k3l1w.mirror.aliyuncs.com"
    ],
    "log-driver": "json-file",
    "log-opts": {
      "max-size": "100m",
      "max-file": "3",
      "labels": "production_status",
      "env": "os,customer"
    },
    "graph": "/home/docker",
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
#curl -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
#
#curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose
# scp 192.168.9.20:/usr/local/bin/docker-compose  /usr/local/bin/
#
echo "install docker-compose ok !"

sudo docker-compose version

sudo reboot
