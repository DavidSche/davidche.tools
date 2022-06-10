# Golang 相关知识

## 代理

```shell
# /etc/sysconfig/network-scripts/ifcfg-eth0
# /etc/resolv.conf
#https://goproxy.io/

go env -w GOPROXY=https://goproxy.cn

```


## github 各种资源拉取加速

### 加速 clone
```shell
# 方法一：手动替换地址
#原地址
$ git clone https://github.com/kubernetes/kubernetes.git
#改为
$ git clone https://github.com.cnpmjs.org/kubernetes/kubernetes.git
#或者
$ git clone https://hub.fastgit.xyz/kubernetes/kubernetes.git
#或者
$ git clone https://gitclone.com/github.com/kubernetes/kubernetes.git

# 方法二：配置git自动替换
$ git config --global url."https://hub.fastgit.xyz".insteadOf https://github.com
# 测试
$ git clone https://github.com/kubernetes/kubernetes.git
# 查看git配置信息
$ git config --global --list
# 取消设置
$ git config --global --unset url.https://github.com/.insteadof
```

加速 release

```shell
# 原地址
wget https://github.com/goharbor/harbor/releases/download/v2.0.2/harbor-offline-installer-v2.0.2.tgz
# 加速下载方法一
wget https://download.fastgit.org/goharbor/harbor/releases/download/v2.0.2/harbor-offline-installer-v2.0.2.tgz
# 加速下载方法二
wget https://hub.fastgit.org/goharbor/harbor/releases/download/v2.0.2/harbor-offline-installer-v2.0.2.tgz

```


###  加速 raw
```shell
#hub.fastgit.xyz

# 原地址
$ wget https://raw.githubusercontent.com/kubernetes/kubernetes/master/README.md
# 加速下载方法一
$ wget https://raw.staticdn.net/kubernetes/kubernetes/master/README.md
# 加速下载方法二
$ wget https://raw.fastgit.org/kubernetes/kubernetes/master/README.md
```



