<center><h1>kubernetes搭建</h1><center/>

### 1.环境准备

```中文
OS：cenos7
CPU：最低要求，2 CPU
内存：最低要求，2GB
磁盘：最低要求，20GB
至少准备两台虚拟机，一主一从
每台虚拟机的要求    
    关闭swap交换空间（kubernetes不支持交换空间）
    关闭防火墙
    关闭selinux安全机制
```

### 2.准备搭建环境（每台虚拟机都需要执行操作）

```shell
 关闭防火墙
	systemctl stop firewalld
	systemctl disable firewalld
 关闭selinux
    setenforce 0
    #这一步可以进入/etc/selinux/config 把SELINUX=enforcing改为SELINUX=disabled
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 
 关闭swap交换空间
    swapoff -a
    #同理只需要进入/etc/fstab注释掉最后一行即可
    sed -ri 's/.*swap.*/#&/' /etc/fstab
 加入节点，显示的节点名字，可以不加
 	echo "192.168.38.172 master
	192.168.38.173 node" >> /etc/hosts
 设置节点间的通信
    echo "1" >/proc/sys/net/bridge/bridge-nf-call-iptables
```

### 3.安装docker

	#先卸载以前的docker
	yum remove docker \
	      docker-client \
	      docker-client-latest \
	      docker-common \
	      docker-latest \
	      docker-latest-logrotate \
	      docker-logrotate \
	      docker-engine
		  yum install -y yum-utils \
	#docker 依赖
		device-mapper-persistent-data lvm2
	#docker源
		yum-config-manager \
		--add-repo \
		https://download.docker.com/linux/centos/docker-ce.repo
	#安装docker
		yum install docker-ce docker-ce-cli containerd.io
	#添加开机启动
		systemctl enable docker
		systemctl start docker
### 4.修改镜像
    #在国内不翻墙无法下载到谷歌的镜像，所以把镜像改成阿里云的镜像
    cat <<EOF > /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
    https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
    EOF
### 5.下载镜像

```docker
#就是下载国内的镜像然后换个名字而已
docker pull registry.cn-beijing.aliyuncs.com/musker/kube-apiserver:v1.14.1
docker pull registry.cn-beijing.aliyuncs.com/musker/kube-controller-manager:v1.14.1
docker pull registry.cn-beijing.aliyuncs.com/musker/kube-scheduler:v1.14.1
docker pull registry.cn-beijing.aliyuncs.com/musker/kube-proxy:v1.14.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1
docker pull registry.cn-beijing.aliyuncs.com/musker/flannel:v0.11.0-amd64

docker tag registry.cn-beijing.aliyuncs.com/musker/kube-apiserver:v1.14.1 k8s.gcr.io/kube-apiserver:v1.14.1
docker tag registry.cn-beijing.aliyuncs.com/musker/kube-controller-manager:v1.14.1 k8s.gcr.io/kube-controller-manager:v1.14.1
docker tag registry.cn-beijing.aliyuncs.com/musker/kube-scheduler:v1.14.1 k8s.gcr.io/kube-scheduler:v1.14.1
docker tag registry.cn-beijing.aliyuncs.com/musker/kube-proxy:v1.14.1 k8s.gcr.io/kube-proxy:v1.14.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10 k8s.gcr.io/etcd:3.3.10
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1 k8s.gcr.io/coredns:1.3.1
docker tag registry.cn-beijing.aliyuncs.com/musker/flannel:v0.11.0-amd64 quay.io/coreos/flannel:v0.11.0-amd64

docker rmi registry.cn-beijing.aliyuncs.com/musker/kube-apiserver:v1.14.1
docker rmi registry.cn-beijing.aliyuncs.com/musker/kube-controller-manager:v1.14.1
docker rmi registry.cn-beijing.aliyuncs.com/musker/kube-scheduler:v1.14.1
docker rmi registry.cn-beijing.aliyuncs.com/musker/kube-proxy:v1.14.1
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.3.10
docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.3.1
docker rmi registry.cn-beijing.aliyuncs.com/musker/flannel:v0.11.0-amd64
```

### 6. 安装kubernetes主键


```shell
yum install -y kubeadm kubectl kubelet
```

### 到此从节点可以不用配置了。其实在这里可以只用一台虚拟机。然后复制出其他的几台即可

### 1.主节点master配置
    #固定格式 --apiserver-advertise-address=192.168.38.172写自己的master ip地址，因为这里用flannel网络，所有--pod-network-cidr=10.224.0.0/16为固定格式（kubernetes有很多网络模式，但是用的比较多的还是这flannel模式。）想了解更多的伙伴可以去kubernetes官网
    https://kubernetes.io/zh/docs/tutorials/kubernetes-basics/学习
    
    kubeadm init --apiserver-advertise-address=192.168.38.172 --pod-network-cidr=10.224.0.0/16
    
    #kubeadm会为我们做绝大部分工作，这一步及其容易出错，如果出错了可以按照error一步一步排查
        (1) kubeadm执行初始化前的检查
        (2) 生成token和证书。
        (3) 生成Kube Config文件，kubelet需要用这个文件与Master通信。
        (4) 安装Master组件，会从你设置的yum源中的 Registry下载组件的 Docker镜像。
        (5) 安装附加组件kube-proxy和kube-dns。
        (6) Kubernetes Master初始化成功。
        (7) 提示如何配置kubectl。
        (8) 提示如何安装Pod 网络。
        (9) 提示如何注册其他节点到Cluster。
### 这一步很重要的东西在最后

      kubeadm join 192.168.38.172:6443 --token gsl5pp.88m3bomhhasq30pf \
        --discovery-token-ca-cert-hash sha256:0a715d2595a235fd54070e57cf60229350f73790533625cc889688ccc7071ded
    
    每个人的都是唯一的，记得备份，这个是从节点加入主节点的认证。以后找不回来的

### 2.配置kubectl
     mkdir -p $HOME/.kube
     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
     sudo chown $(id -u):$(id -g) $HOME/.kube/config
    #验证一下是否成功部署master节点
        kubectl get node 
    #master节点现在的状态是NotReady，说明成功部署节点
### 3.配置网络模式flannel
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    #可以再次执行 kubectl get node 看到节点变为Ready
### 4.从节点加入主节点
    #每个人的不一样，这条命令在配置master节点的时候出现过
        kubeadm join 192.168.38.172:6443 --token gsl5pp.88m3bomhhasq30pf \
        --discovery-token-ca-cert-hash sha256:0a715d2595a235fd54070e57cf60229350f73790533625cc889688ccc7071ded
    #在master节点查看 kubectl get node 看到从节点成功加入
### 5.配置Dashboard可视化界面
```shell
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml
#修改为Type=NodePort模式
    kubectl patch svc -n kube-system kubernetes-dashboard -p '{"spec":{"type":"NodePort"}}'
#这一步很多人肯定会出错，因为在yml文件中的镜像是google的。我们无法获取，因此我们需要换名字
    docker pull registry.cn-qingdao.aliyuncs.com/charleslee1120/kubernetes-dashboard-amd64:v版本号 （我用的版本号是1.10.0）
    docker tag registry.cn-qingdao.aliyuncs.com/charleslee1120/kubernetes-dashboard-amd64:v版本号 k8s.gcr.io/kubernetes-dashboard-amd64:v版本号
#看服务在那个端口被启动
    kubectl get svc -n kube-system
#查看服务运行在哪个node
	kubectl get pods -A -o wide
#Dashboard可视化界面使用令牌登录的，因此我们需要加入一个管理员
#创建一个管理员
    kubectl create serviceaccount dashboard-admin -n kube-system
#绑定用户为集群管理用户
    kubectl create clusterrolebinding dashboard-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
#生成一个token
    kubectl describe secret -n kube-system dashboard-admin-token
#Dashboard可视化界面需要使用https加密传输，因此在输入ip和端口号的时候指定https协议
    例如 https://192.168.38.172:30001
```