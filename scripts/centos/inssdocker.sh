#!/usr/bin/env bash
# 使用 *hostnamectl* 命令设置主机名称信息

echo "setting hostname !"
hostnamectl --static set-hostname cqy-test13

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
echo "set firewall ok !"

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

#install git
echo "install git !"
sudo yum install git -y
echo "git install ok !"
# install docker
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
        "192.168.106.11:5000"
    ],
    "registry-mirrors": [
        "https://um1k3l1w.mirror.aliyuncs.com"
    ]
}
EOF

echo " write daemon.json setting success ! "

systemctl daemon-reload && systemctl restart docker

echo "restart docker ok! "
sudo docker info 

# docker-compose
echo "install docker-compose ! "
curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "install docker-compose ok !"

sudo docker-compose version