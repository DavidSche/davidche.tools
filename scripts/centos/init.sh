#!/usr/bin/env bash

# 使用 *hostnamectl* 命令设置主机名称信息

echo "setting hostname !"
hostnamectl --transient set-hostname centos-node-40 

# for 
echo "setting vm.max_map_count=262144 !"

echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sudo sysctl -p

#yum update && yum install -y iputils-ping

#diable firewall
#echo "disable firewall !"
# sudo systemctl stop firewalld
# sudo systemctl disable firewalld

echo "setting firewall, add swarm port to firewall !"
# 例如在centos 7下执行以下命令开放端口
firewall-cmd --add-port=2376/tcp --permanent
firewall-cmd --add-port=2377/tcp --permanent
firewall-cmd --add-port=7946/tcp --permanent
firewall-cmd --add-port=7946/udp --permanent
firewall-cmd --add-port=4789/udp --permanent
firewall-cmd --add-port=4789/tcp --permanent
sudo firewall-cmd --reload
#sudo reboot
echo "set firewall ok !"

# update os kernel
echo "update kernel to 4.x !"


sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sudo yum --enablerepo=elrepo-kernel install kernel-ml -y 

yum update -y

#如果没有安装ntp服务器，刚需要先执行以下命令：
echo "set date !"
sudo yum install ntp
#同步时间使用ntpdate命令如下:
sudo ntpdate cn.pool.ntp.org

echo "install system utils & tools!"
sudo yum install net-tools -y
sudo yum install psmisc -y
sudo yum install wget -y
sudo yum install yum-plugin-ovl -y
sudo yum install yum-utils -y

# install java
#echo "install java 1.8.0 openjdk !"
#sudo yum install java-1.8.0-openjdk -y
# install java
#echo "install maven !"
#sudo yum install maven -y

#install git
echo "install git !"
sudo yum install git -y
echo "git install ok !"
# install docker
echo "install docker engine ！"

sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
sudo yum install docker-ce -y

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

echo "{
    "insecure-registries": [
        "192.168.5.101:5000",
        "124.133.33.114:3101"
    ],
    "registry-mirrors": [
        "https://um1k3l1w.mirror.aliyuncs.com"
    ],
    "storage-driver": "overlay2",
    "storage-opts": [
        "overlay2.override_kernel_check=true"
    ],
    "log-driver": "fluentd",
    "log-opts": {
        "fluentd-address": "192.168.5.113:24224"
    }
}" > /etc/docker/daemon.json

echo "write daemon.json setting success ! "


systemctl daemon-reload && systemctl restart docker
echo "restart docker ok! "

# docker-compose
echo "install docker-compose ! "
curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "install docker-compose ok !"

#install node
#echo "install node js !"
#curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
curl -sL https://rpm.nodesource.com/setup_10.x | bash -
#sudo yum -y install nodejs

curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
#sudo yum install yarn -y
#npm install -g grunt-cli


# install tomcat
#echo "install tomcat !"
#cd /opt
#wget http://mirrors.shu.edu.cn/apache/tomcat/tomcat-8/v8.5.34/bin/apache-tomcat-8.5.34.tar.gz

#tar -xvf apache-tomcat-8.5.34.tar.gz

# /opt/run_npm.sh
#!/usr/bin/env bash
# sudo killall node

# cd /opt/schoolbus/code/schoolBus_vue
# sudo git pull
# nohup npm run dev &

# install golang 
### Debian 9 / Ubuntu 16.04 / 14.04 ###
# apt-get install wget
### CentOS / RHEL / Fedora ###
# yum -y install wget

wget https://storage.googleapis.com/golang/go1.11.5.linux-amd64.tar.gz
tar -zxvf  go1.11.5.linux-amd64.tar.gz -C /usr/local/
export PATH=$PATH:/usr/local/go/bin
mkdir -p /opt/work
export GOPATH=/opt/work 
echo -e "export PATH=$PATH:/usr/local/go/bin  " >> /etc/profile
echo -e "export GOPATH=/opt/work " >> /etc/profile

#echo -e "export GOROOT=/usr/local/go export PATH=$PATH:$GOROOT/bin export GOPATH=/usr/local/go" >> /etc/profile
go version
go env
echo "init golang lib success ! "

# ----over !
echo "init os lib success ok! "


