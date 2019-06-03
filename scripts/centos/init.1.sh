#!/usr/bin/env bash

# 使用 *hostnamectl* 命令设置主机名称信息

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
#!/usr/bin/env bash
sudo systemctl enable  firewalld
sudo systemctl start  firewalld


firewall-cmd --add-port=2376/tcp --permanent
firewall-cmd --add-port=2377/tcp --permanent
firewall-cmd --add-port=7946/tcp --permanent
firewall-cmd --add-port=7946/udp --permanent
firewall-cmd --add-port=4789/udp --permanent
firewall-cmd --add-port=4789/tcp --permanent

firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=9000/tcp --permanent
firewall-cmd --add-port=9001/tcp --permanent
firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --add-port=3307/tcp --permanent
firewall-cmd --add-port=8400/tcp --permanent
firewall-cmd --add-port=8500/tcp --permanent
firewall-cmd --add-port=8600/tcp --permanent

sudo firewall-cmd --reload
sudo systemctl restart  firewalld

firewall-cmd --zone=public --list-ports
 
#sudo reboot
echo "set firewall ok !"



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

# install java
#echo "install java 1.8.0 openjdk !"
#sudo yum install java-1.8.0-openjdk -y
# install java
#echo "install maven !"
#sudo yum install maven -y
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

#wget  https://download.docker.com/linux/static/stable/x86_64/docker-18.09.5.tgz 
#tar xzvf docker-18.09.5.tgz 
#sudo cp -rf docker/* /usr/local/bin/
#sudo dockerd &
#docker version
#sudo docker swarm init --advertise-addr 10.140.0.6 --listen-addr 10.140.0.6:2377

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
#应用最新的BUILDKIT构建架构
export DOCKER_BUILDKIT=1

echo "write daemon.json setting success ! "

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

