# Harbor 深入浅出

## Docker Swarm 环境下，离线安装 Harbor 环境

### 下载离线安装包

离线安装包下载地址 <https://github.com/goharbor/harbor/releases>

也可以直接执行以下命令进行下载和解压

``` bash
wget https://storage.googleapis.com/harbor-releases/release-1.7.0/harbor-offline-installer-v1.7.5.tgz

tar xzf harbor-offline-installer-v1.7.5.tgz
```

### 准备环境

准备一台 2核CPU 8G内存 的云主机

Ubuntu1 g.n2.large 通用 标准型

116.196.115.248 （公） 10.1.1.8 （内）

### 配置域名

reg.vapicloud.com 116.196.115.248

安装 Docker 和 docker-compose 环境

执行脚本 [install-docker-ubuntu1604.sh](https://dclingcloud.github.io/rancher-in-action/registry/install-docker-ubuntu1604.sh)

### 配置Harbor支持https

配置Harbor支持https

#### 生成证书和秘钥

生成证书和秘钥的脚本:

[create-cert.sh](https://dclingcloud.github.io/rancher-in-action/registry/create-cert.sh)

执行前修改脚本中域名和证书申请信息

执行 create-cert.sh 生成并配置证书和秘钥

#### 配置证书和秘钥的脚本

[config-ssl.sh](https://dclingcloud.github.io/rancher-in-action/registry/config-ssl.sh)

执行前修改脚本中域名和证书申请信息

执行 config-ssl.sh 生成并配置证书和秘钥

### 配置 Harbor

vi harbor.cfg

``` cfg
hostname = reg.vapicloud.com

ui_url_protocol = https

ssl_cert = /data/cert/reg.vapicloud.com.crt
ssl_cert_key = /data/cert/reg.vapicloud.com.key

```

运行命令

``` bash
./prepare

```

### 安装 Harbor

``` bash
./install.sh
```

### 浏览器访问

登录地址： <https://reg.vapicloud.com>

默认登录用户名：密码 admin : Harbor12345

> 记得登录后记得修改密码

登录后创建名为mytest的项目

### 测试使用 harbor

#### 测试镜像推送

客户端推送镜像到自建的镜像仓库

#### 登录镜像仓库

``` bash
$ docker login reg.vapicloud.com
Authenticating with existing credentials...
Stored credentials invalid or expired
Username (admin): admin
Password:
Login Succeeded
```

### 将要上传的镜像打tag

``` bash
docker tag postgres:9.3.24 reg.vapicloud.com/mytest/postgres:9.3.24
```

### 推送镜像到镜像仓库

``` bash
docker push reg.vapicloud.com/mytest/postgres:9.3.24
```

### 在Harbor 控制台查看推送结果

### 在其他机器配置并使用harbor

config-host.sh

``` bash

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

```
