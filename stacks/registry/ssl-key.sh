#!/bin/bash
cd /opt
pwd
# /opt/certs/
# 生成证书
#mkdir -p certs -f
if [ ! -d certs ]; then
  mkdir -p certs
  echo " mkdir certs success ! "
fi

openssl req \
 -newkey rsa:4096 \
 -nodes -sha256 \
 -keyout certs/hub.mpaas.com.key \
 -x509 -days 3600 -subj "/CN=hub.mpaas.com"  \
 -out certs/hub.mpaas.com.crt
# 将证书复制到系统证书中
cat certs/hub.mpaas.com.crt >> /etc/ssl/certs/ca-certificates.crt

# 将域名写入/etc/hosts
HOSTNAME=`hostname`
hub_url="hub.mpaas.com"
#hub_ip="127.0.0.1"
#获取主机IP 地址
hub_ip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

hub_ip_map="${hub_ip} ${hub_url}"
#inner_ip_map="${in_ip} ${in_url}"
echo ${hub_ip_map} >> /etc/hosts

#echo "127.0.0.1  hub.mpaas.com" >> /etc/hosts

echo "${hub_ip_map} wrrite to hosts success !"
#设置docker engine 的证书信息
#mkdir -p /etc/docker/certs.d/
if [ ! -d /etc/docker/certs.d/ ];then
  mkdir -p /etc/docker/certs.d/
  echo " mkdir /etc/docker/certs.d/ success ! "
fi
#exit
cp certs/hub.mpaas.com.crt /etc/docker/certs.d/
echo "copy hub.mpaas.com.crt to /etc/docker/certs.d/ success ! "
