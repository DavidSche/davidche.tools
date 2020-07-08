#!/usr/bin/env bash

# 使用 *hostnamectl* 命令设置主机名称信息
#查看Linux 版本信息：

# 设置阿里云yum源仓库
#curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
#wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

echo " RedHat Linux 版本信息 !"

cat  /etc/redhat-release
#查看Linux内核版本信息
echo "Linux虚拟机内核版本信息 !"
cat /proc/version
# DNS
#vi或者vim /etc/resolv.conf    #一般情况下是设置nameserver 114.114.114.114

echo "setting hostname !"
hostnamectl --static set-hostname cqy-devlop-db 

# for 
echo "setting vm.max_map_count=262144 !"
sysctl -w vm.max_map_count=262144

echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sudo sysctl -p

#yum update && yum install -y iputils-ping

#diable firewall
#echo "disable firewall !"
# sudo systemctl stop firewalld
# sudo systemctl disable firewalld

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

firewall-cmd --add-port=8400/tcp --permanent
firewall-cmd --add-port=8500/tcp --permanent
firewall-cmd --add-port=8600/tcp --permanent


firewall-cmd --add-port=7474/tcp --permanent
firewall-cmd --add-port=7373/tcp --permanent
firewall-cmd --add-port=7687/tcp --permanent
# docker run --name neo4j -p 7474:7474 -p 7373:7373 -p 7687:7687 bitnami/neo4j:3

firewall-cmd --add-port=10050/tcp --permanent
# 批量开放端口
# firewall-cmd --permanent --zone=public --add-port=100-500/tcp
# firewall-cmd --permanent --zone=public --add-port=100-500/udp

sudo firewall-cmd --reload
sudo systemctl restart  firewalld

firewall-cmd --zone=public --list-ports
 
#sudo reboot
echo "set firewall ok !"

yum install epel-release -y

# scp  root@192.168.9.127:~/setfirewall.sh  ./
# cqyMASS2019

# update os kernel
echo "update kernel to 4.x !"


sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
sudo rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
sudo yum --enablerepo=elrepo-kernel install kernel-ml -y 

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
sudo yum install curl -y
sudo yum install yum-plugin-ovl -y
sudo yum install yum-utils -y
sudo yum -y install psmisc -y
# install java
# rpm -qa | grep java
#echo "install java 1.8.0 openjdk !"
#sudo yum install java-1.8.0-openjdk -y
#sudo yum install java-1.8.0-openjdk-devel
#sudo yum install java-11-openjdk-devel -y
# install java
#echo "install maven !"
#sudo yum install maven -y
#------
# wget https://www-us.apache.org/dist/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz -P /tmp
# sudo tar xf /tmp/apache-maven-3.6.3-bin.tar.gz -C /opt
# sudo ln -s /opt/apache-maven-3.6.3 /opt/maven
# sudo nano /etc/profile.d/maven.sh
#

# export JAVA_HOME=/usr/lib/jvm/jre-openjdk
# export M2_HOME=/opt/maven
# export MAVEN_HOME=/opt/maven
# export PATH=${M2_HOME}/bin:${PATH}
# sudo chmod +x /etc/profile.d/maven.sh
# source /etc/profile.d/maven.sh
# mvn install -DskipTests=false
#----------------
# Get yum repo
# cat << EOF > /etc/yum.repos.d/td-agent-bit.repo
# [td-agent-bit]
# name = TD Agent Bit
# baseurl = http://packages.fluentbit.io/centos/7
# gpgcheck=1
# gpgkey=http://packages.fluentbit.io/fluentbit.key
# enabled=1
# EOF

# # Install
# yum -y install td-agent-bit

#!/usr/bin/env bash
echo "install td-agent-bit " 

echo "[td-agent-bit]
name = TD Agent Bit
baseurl = http://packages.fluentbit.io/centos/7
gpgcheck=1
gpgkey=http://packages.fluentbit.io/fluentbit.key
enabled=1" > /etc/yum.repos.d/td-agent-bit.repo

yum install td-agent-bit -y

# service td-agent-bit start
# service td-agent-bit status


#/etc/td-agent-bit/td-agent-bit.conf
#The configuration file

echo "td-agent-bit install ok" 

echo "

[INPUT]
    Name              tail
    Tag               docker.*
    path              /var/lib/docker/containers/**/*.log
    Parser            docker
    DB                /var/log/flb_kube.db
    Mem_Buf_Limit     5MB
    Skip_Long_Lines   On
    Refresh_Interval  10
    Docker_Mode       on

[OUTPUT]
    Name         file
    Match        *
    Path         /tmp/logoutput.txt " >> /etc/td-agent-bit/td-agent-bit.conf

# systemctl
systemctl enable td-agent-bit
systemctl restart td-agent-bit
systemctl status td-agent-bit

#sudo systemctl start td-agent-bit
#----------------
#install git
echo "install git !"
sudo yum install git -y
echo "git install ok !"
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
        "192.168.5.101:5000",
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
curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
#
#curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose
# scp 192.168.9.20:/usr/local/bin/docker-compose  /usr/local/bin/
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


# Extra Packages for Enterprise Linux 
# python 3 

echo "Get Extra Packages for Enterprise Linux !"
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#sudo yum install python36 -y 
#curl -O https://bootstrap.pypa.io/get-pip.py
#sudo /usr/bin/python3 get-pip.py
# pip install -U pip

history -c

## install
##  rpm -ivh httpd-2.4.6-67.el7.centos.x86_64.rpm 
## update
##  rpm -Uvh 包全名
## 卸载
## rpm -e 包名
## rpm -q 包名   查询包是否安装
## rpm -qi 包名  查询软件包的详细信息
## rpm -ql 包名  查询包中文件安装位置
##  rpm -qR 包名 查询软件包的依赖性 