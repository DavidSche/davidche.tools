## 序言

>中国用户在安装k3s的时候会因为网络问题导致无法部署的情况,为此,K3s官网出来一个离线部署的方法.这里做个记录.

<!-- more -->
## k3s master节点安装方法

```shell
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -
# 国内安装脚本，但是未验证
```

1. 在[k3s](https://github.com/rancher/k3s/releases)发布页面下载最新的tar文件和k3s的bin文件
```shell
sudo mkdir -p /var/lib/rancher/k3s/agent/images/ # 递归创建好文件存放的目录
mkdir k3s && cd k3s # 创建一个k3s目录并进入
wget https://github.91chifun.workers.dev//https://github.com/rancher/k3s/releases/download/v1.19.4%2Bk3s1/k3s-airgap-images-amd64.tar #这里直接用了加速镜像
wget https://github.91chifun.workers.dev//https://github.com/rancher/k3s/releases/download/v1.19.4%2Bk3s1/k3s # 下载k3s二进制文件
curl -fL https://get.k3s.io -o install-k3s.sh && sudo chmod +x ./install-k3s.sh # 下载安装脚本
sudo cp k3s-airgap-images-$ARCH.tar /var/lib/rancher/k3s/agent/images/ #将下载文件复制到目标文件夹，如果失败，arch要替换成你的下载文件名
sudo cp k3s /usr/local/bin && sudo chmod 755 /usr/local/bin/k3s # 将下载的K3s二进制文件复制到目标目录并更改权限为755 
INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh # 安装k3s master节点
#INSTALL_K3S_SKIP_DOWNLOAD=true ./install.sh --docker  使用docker替代系统容器命令
sudo kubectl get nodes # 查看结果
```
小结：
1. 下载三个文件，分别是k3s的tar镜像文件、K3s的二进制文件以及k3s的安装脚本
2. 将tar镜像、k3s二进制文件复制到指定位置，并给予可执行权限
3. 使用变更k3s安装脚本可执行权限并且安装

## k3s 代理节点安装方法
1. 获得master节点的令牌
```shell
sudo cat /var/lib/rancher/k3s/server/node-token 
K10bc1b860845c709d9ca29a9997bb28abc9ae4baf51ae7a48e24cfa669f062f6fd::server:6985a3b11e7b4c38479ccd06ad9cf669
# 上面这行是令牌，每台机器都不一样
sudo kubectl get nodes # 查看结果
```
2. 带指定令牌离线安装
然后，要选择添加其他 agent，请在每个 agent 节点上执行以下操作。注意将 myserver 替换为 server 的 IP 或有效的 DNS，并将 mynodetoken 替换 server 节点的 token，通常在/var/lib/rancher/k3s/server/node-token。

```sh
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken ./install.sh
# 下面这行命令会用docker替代系统的容器命令
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken ./install.sh --docker
```
节点安装和Master安装的区别就在于你安装的时候要带好节点的令牌即可。

## 卸载
```shell
# Uninstall Server, running on Server
sudo sh /usr/local/bin/k3s-uninstall.sh
 # Uninstall Agent, run Agent
sudo sh /usr/local/bin/k3s-agent-uninstall.sh

```
## 其他安装方法
**方式1：在每个树莓派板子上单独安装**

在server节点上运行

```
curl -sfL https://get.k3s.io | sh -

```

在每个worker节点上运行

```
curl -sfL https://get.k3s.io | K3S_URL=https://<server_ip>:6443 K3S_TOKEN=<token> sh -

```

PS:**K3S\_TOKEN**:存在server节点的 \*\*/var/lib/rancher/k3s/server/node\-token\*\*.

**方式2：使用Ansible自动化安装**

先在控制机上安装[Ansible](https://github.com/ansible/ansible)

```shell
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

```

下载[k3s\-ansible](https://github.com/rancher/k3s-ansible)

```
git clone https://github.com/rancher/k3s-ansible.git

```

然后按照 [https://github.com/rancher/k3...](https://github.com/rancher/k3s-ansible) 的步骤，在***inventory/my\-cluster/hosts.ini***里配置好server (master) 节点和worker(node)节点的IP地址。

运行如下命令，Ansible会将K3S自动安装在集群的server节点和每个worker节点上

```
ansible-playbook site.yml -i inventory/my-cluster/hosts.ini --ask-become-pass
```
**3.2 连接集群**

### 在控制机上安装kubectl

```
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

```

将配置文件从server节点拷贝至控制机并配置环境变量

```
scp <user_name>@<server_ip>:~/.kube/config ~/.kube/rasp-config
export KUBECONFIG=~/.kube/rasp-config

```

### 连接查看集群

```
kubectl get nodes

```

大功告成，接下来就可以部署服务到集群了。

## 查看日志
```shell 
# All Print
sudo cat /var/log/syslog
 # Print tracking
sudo tail -f /var/log/syslog

```
## 参考状态
```shell
# In the Server running,
sudo k3s kubectl get all --all-namespaces -o wide
sudo systemctl status k3s.service # 查看状态
sudo systemctl enable k3s --now # 设置开机自启
```


## 常见问题
 




 ## 参考链接
 * [Centos K3s集群的脱机安装-程序员](https://www.programmersought.com/article/31165075635/)
 * [离线安装 k3s | Python观察员](https://jiaxin.im/blog/chi-xian-an-zhuang-k3/)
   > 亮点是比较简单的讲述了如何使用docker替代k3s自带容器
 * [K3S +树莓派离线安装-程序员](https://programmersought.com/article/70452937604/)
 * [基于树莓派搭建小型云计算集群_个人文章 - SegmentFault 思否](https://segmentfault.com/a/1190000022923611?utm_source=sf-related)
   > 亮点是树莓派矩阵图片
 * [如何安装一个高可用K3s集群？-技术圈](https://jishuin.proginn.com/p/763bfbd2cfe9)
   >亮点是etcd数据库和Nginx的搭建
 * [K3s常见问题 | Rancher文档](https://docs.rancher.cn/docs/k3s/faq/_index/)
   >这个是中文官方，很好的学习稳定
 * [k3s在实际项目中的落地实践 | 诗与远方](https://sjt157.top/2019/11/08/k3s%E5%9C%A8%E5%AE%9E%E9%99%85%E9%A1%B9%E7%9B%AE%E4%B8%AD%E7%9A%84%E8%90%BD%E5%9C%B0%E5%AE%9E%E8%B7%B5/)
     > 这篇文章非常详细，值得反复阅读
* [k3s 安装小记 | Zindex's blog](http://zxc0328.github.io/2019/06/04/k3s-setup/)
  > 这篇文章虽然浅显，但是写的很简练
* [跨云厂商部署 k3s 集群 - 知乎](https://zhuanlan.zhihu.com/p/149395743)
  > * 安装wireguard
  > * 部署控制平面
  > * 加入计算节点
  > * 内网不互通，修改公网ip的解决方法
  > * metrics-server 问题解决