#!/bin/sh

## 创建自签名根证书，生成一个私钥及自签名证书

openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=IT/OU=devops/CN=vapicloud.com" \
    -key ca.key \
    -out ca.crt

## 创建镜像库主机秘钥
openssl genrsa -out reg.vapicloud.com.key 4096

## 生成镜像库主机证书申请文件
openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=IT/OU=devops/CN=reg.vapicloud.com" \
    -key reg.vapicloud.com.key \
    -out reg.vapicloud.com.csr

## 生成镜像库主机证书

cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=reg.vapicloud.com
DNS.2=vapicloud
DNS.3=myharbor
EOF

openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in reg.vapicloud.com.csr \
    -out reg.vapicloud.com.crt

## 为docker配置密钥、证书与ca

openssl x509 -inform PEM -in reg.vapicloud.com.crt -out reg.vapicloud.com.cert
