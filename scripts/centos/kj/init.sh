#!/usr/bin/env bash
# 使用 *hostnamectl* 命令设置主机名称信息

#echo "setting hostname !"
#hostnamectl --static set-hostname kj-develop-node1

# for
echo "setting vm.max_map_count=262144 !"
sysctl -w vm.max_map_count=262144

echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sudo sysctl -p

#yum update && yum install -y iputils-ping

#diable firewall
#echo "disable firewall !"
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo "setting firewall, add swarm port to firewall !"
# 例如在centos 7下执行以下命令开放端口
# firewall-cmd --add-port=2376/tcp --permanent
# firewall-cmd --add-port=2377/tcp --permanent
# firewall-cmd --add-port=7946/tcp --permanent
# firewall-cmd --add-port=7946/udp --permanent
# firewall-cmd --add-port=4789/udp --permanent
# firewall-cmd --add-port=4789/tcp --permanent
# firewall-cmd --add-port=9323/tcp --permanent
# sudo firewall-cmd --reload
#sudo reboot
echo "set firewall ok !"

# update os kernel
echo "update kernel to 4.x !"

echo ulimit -n 65535 >>/etc/profile
source /etc/profile    #加载修改后的profile
ulimit -n

yum update -y

#如果没有安装ntp服务器，刚需要先执行以下命令：
echo "set date !"
sudo yum install ntp -y
#同步时间使用ntpdate命令如下:
sudo ntpdate cn.pool.ntp.org

echo "install system utils & tools!"
sudo yum install net-tools -y
sudo yum install psmisc -y
sudo yum install wget -y
sudo yum install yum-plugin-ovl -y
sudo yum install yum-utils -y
sudo yum install psmisc -y

echo "install docker engine ！"


#wget  https://download.docker.com/linux/static/stable/x86_64/docker-18.09.5.tgz
#tar xzvf docker-18.09.5.tgz
#sudo cp -rf docker/* /usr/local/bin/
#sudo dockerd &
#docker version
#sudo docker swarm init --advertise-addr 10.140.0.6 --listen-addr 10.140.0.6:2377

export DOCKER_BUILDKIT=1

sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum install docker-ce -y

echo "config docker"
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl stop docker

echo "write  docker config to /etc/docker/daemon.json "

# >> 追加文件写入 > 覆盖文件写入
cat << EOF > /etc/docker/daemon.json
{
    "insecure-registries": [
        "192.168.9.10:5000"
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
    },
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ]
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