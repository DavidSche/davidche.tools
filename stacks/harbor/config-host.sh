#!/bin/sh
# 配置证书信息
mkdir -p /etc/docker/certs.d/reg.vapicloud.com/

cp ./reg.vapicloud.com.cert /etc/docker/certs.d/reg.vapicloud.com/
cp ./reg.vapicloud.com.key /etc/docker/certs.d/reg.vapicloud.com/
cp ./ca.crt /etc/docker/certs.d/reg.vapicloud.com/

systemctl restart docker

# 设置域名信息
#!/bin/bash
cat <<EOF >> /etc/hosts

192.168.9.26  reg.vapicloud.com

EOF
