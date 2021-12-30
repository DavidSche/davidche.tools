# 安装使用 k3s  kubernetes dashboard

## k3s_master端搭建

### 安装docker
yum install docker

### 安装k3s.service
curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -s - server --docker


查看master token查看

```shell
cat /var/lib/rancher/k3s/server/node-token

K1035d8d7c132a0d53dcca788df6b5ef21da383fb71feef4f32a***************::server:7ed15b9f800d4a54c832*************

```

### 安装 k3s-agent.service

curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL=https://master端ip:6443 K3S_TOKEN=master端tocken INSTALL_K3S_EXEC="--docker"  sh -

curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -

curl -sfL http://rancher-mirror.cnrancher.com/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL=https://192.168.202.167:6443 K3S_TOKEN=K10e76f13a247b3d32e34c410b683ee7b99e2ef017c175c10a25fa4ac76a3a95a3e::server:bcf6f90d75cea106b39230b3c6191956 INSTALL_K3S_EXEC="--docker"  sh -

### 卸载K3S

#### 服务器

/usr/local/bin/k3s-uninstall.sh
#### 工作节点

/usr/local/bin/k3s-agent-uninstall.sh

-----

## kubernetes-dashboard安装

###一，在所有节点下载好docker镜像

#### 1, 标准yaml文件下载地址
https://raw.githubusercontent.com/kubernetes/dashboard/v2.4.0/aio/deploy/recommended.yaml

#### 2，此dashboard.yaml内容如下(只有一处需要更改，就是将kubernetes-dashboard这个service，增加一个Nodeport，本例为31001)：
 
```yaml
# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apiVersion: v1
kind: Namespace
metadata:
  name: kubernetes-dashboard

---

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard

---

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  type: NodePort
#  这里
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 31001
# 修改这里
  selector:
    k8s-app: kubernetes-dashboard
# 
---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-certs
  namespace: kubernetes-dashboard
type: Opaque

---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-csrf
  namespace: kubernetes-dashboard
type: Opaque
data:
  csrf: ""

---

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-key-holder
  namespace: kubernetes-dashboard
type: Opaque

---

kind: ConfigMap
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-settings
  namespace: kubernetes-dashboard

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
rules:
  # Allow Dashboard to get, update and delete Dashboard exclusive secrets.
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs", "kubernetes-dashboard-csrf"]
    verbs: ["get", "update", "delete"]
    # Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["kubernetes-dashboard-settings"]
    verbs: ["get", "update"]
    # Allow Dashboard to get metrics.
  - apiGroups: [""]
    resources: ["services"]
    resourceNames: ["heapster", "dashboard-metrics-scraper"]
    verbs: ["proxy"]
  - apiGroups: [""]
    resources: ["services/proxy"]
    resourceNames: ["heapster", "http:heapster:", "https:heapster:", "dashboard-metrics-scraper", "http:dashboard-metrics-scraper"]
    verbs: ["get"]

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
rules:
  # Allow Metrics Scraper to get metrics from the Metrics server
  - apiGroups: ["metrics.k8s.io"]
    resources: ["pods", "nodes"]
    verbs: ["get", "list", "watch"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kubernetes-dashboard
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kubernetes-dashboard
subjects:
  - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kubernetes-dashboard

---

kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: kubernetes-dashboard
  template:
    metadata:
      labels:
        k8s-app: kubernetes-dashboard
    spec:
      containers:
        - name: kubernetes-dashboard
          image: kubernetesui/dashboard:v2.4.0
          imagePullPolicy: Always
          ports:
            - containerPort: 8443
              protocol: TCP
          args:
            - --auto-generate-certificates
            - --namespace=kubernetes-dashboard
            # Uncomment the following line to manually specify Kubernetes API server Host
            # If not specified, Dashboard will attempt to auto discover the API server and connect
            # to it. Uncomment only if the default does not work.
            # - --apiserver-host=http://my-address:port
          volumeMounts:
            - name: kubernetes-dashboard-certs
              mountPath: /certs
              # Create on-disk volume to store exec logs
            - mountPath: /tmp
              name: tmp-volume
          livenessProbe:
            httpGet:
              scheme: HTTPS
              path: /
              port: 8443
            initialDelaySeconds: 30
            timeoutSeconds: 30
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsUser: 1001
            runAsGroup: 2001
      volumes:
        - name: kubernetes-dashboard-certs
          secret:
            secretName: kubernetes-dashboard-certs
        - name: tmp-volume
          emptyDir: {}
      serviceAccountName: kubernetes-dashboard
      nodeSelector:
        "kubernetes.io/os": linux
      # Comment the following tolerations if Dashboard must not be deployed on master
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule

---

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: dashboard-metrics-scraper
  name: dashboard-metrics-scraper
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 8000
      targetPort: 8000
  selector:
    k8s-app: dashboard-metrics-scraper

---

kind: Deployment
apiVersion: apps/v1
metadata:
  labels:
    k8s-app: dashboard-metrics-scraper
  name: dashboard-metrics-scraper
  namespace: kubernetes-dashboard
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: dashboard-metrics-scraper
  template:
    metadata:
      labels:
        k8s-app: dashboard-metrics-scraper
    spec:
      securityContext:
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: dashboard-metrics-scraper
          image: kubernetesui/metrics-scraper:v1.0.7
          ports:
            - containerPort: 8000
              protocol: TCP
          livenessProbe:
            httpGet:
              scheme: HTTP
              path: /
              port: 8000
            initialDelaySeconds: 30
            timeoutSeconds: 30
          volumeMounts:
          - mountPath: /tmp
            name: tmp-volume
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsUser: 1001
            runAsGroup: 2001
      serviceAccountName: kubernetes-dashboard
      nodeSelector:
        "kubernetes.io/os": linux
      # Comment the following tolerations if Dashboard must not be deployed on master
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
      volumes:
        - name: tmp-volume
          emptyDir: {}

```

#### 3，serviceaccount

上面的rbac的serviceaccount是没有什么权限的，为了能管理整个k8s集群，加入一个cluster admin的角色，
dashborad-admin-rabc.yaml内容如下

```yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard

```

### 二，在master节点应用yaml文件

```shell
kubectl apply -f dashboard.yaml
kubectl apply -f dashborad-admin-rabc.yaml
```
### 三，获取访问的token

```shell
k3s kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

```

### 四，通过web访问dashbaord

```shell
访问https://192.168.1.x:31001/#/login
```

输入对应的token



##

https://huataihuang.gitbooks.io/cloud-atlas/content/os/linux/redhat/system_administration/network/centos7_disable_ipv6.html

###

------


使用 heredoc 語法的 Dockerfile
在 Simon Willison 這邊看到的，在 Dockerfile 裡面使用 heredoc 語法編 Docker image：「Introduction to heredocs in Dockerfiles」，引用的文章是「Introduction to heredocs in Dockerfiles」與「Introduction to heredocs in Dockerfiles」，七月的事情了。

heredoc 指的是可以讓開發者很方便使用多行結構，在 Dockerfile 這邊常見到的 pattern：

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y ...
但這樣會產生出很多層 image，所以先前的 best practice 是：

RUN apt-get update && \
apt-get upgrade -y && \
apt-get install -y ...
而 heredoc 的導入簡化了不少事情，這應該有機會成為新的 best practice：

RUN <<EOF
apt-get update
apt-get upgrade -y
apt-get install -y ...
EOF
要注意的是，開頭要記得加上 #syntax 的宣告，用到 docker/dockerfile:1.3-labs 這組才能使用 heredoc：

# syntax=docker/dockerfile:1.3-labs
然後用 buildkit 去編，用新版的 Docker 已經包 buildkit v0.9.0 進去了：

DOCKER_BUILDKIT=1 docker build .使用 heredoc 語法的 Dockerfile
在 Simon Willison 這邊看到的，在 Dockerfile 裡面使用 heredoc 語法編 Docker image：「Introduction to heredocs in Dockerfiles」，引用的文章是「Introduction to heredocs in Dockerfiles」與「Introduction to heredocs in Dockerfiles」，七月的事情了。

heredoc 指的是可以讓開發者很方便使用多行結構，在 Dockerfile 這邊常見到的 pattern：

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y ...
但這樣會產生出很多層 image，所以先前的 best practice 是：

RUN apt-get update && \
apt-get upgrade -y && \
apt-get install -y ...
而 heredoc 的導入簡化了不少事情，這應該有機會成為新的 best practice：

RUN <<EOF
apt-get update
apt-get upgrade -y
apt-get install -y ...
EOF
要注意的是，開頭要記得加上 #syntax 的宣告，用到 docker/dockerfile:1.3-labs 這組才能使用 heredoc：

# syntax=docker/dockerfile:1.3-labs
然後用 buildkit 去編，用新版的 Docker 已經包 buildkit v0.9.0 進去了：

DOCKER_BUILDKIT=1 docker build .


如何做出好的 Docker Image
Docker 愈來愈紅，而 image 也愈來愈多，於是就有人討論要如何做出好的 Docker image。

在「Building good docker images」這篇文章裡提到了不少現象以及改善的技巧。

首先是 base image 的選用。除非有特別的理由，不然作者建議是基於 debian:wheezy (85MB) 而非 ubuntu:14.04 (195MB)。甚至在某些極端的情況下，你可以選擇 busybox (2MB)。

再來是沒事不要塞 build tools 進去，除非那是之後執行必要的東西。

然後是避免暫存檔的產生，作者舉的例子還蠻容易懂的。這樣是 109MB：

FROM debian:wheezy
RUN apt-get update && apt-get install -y wget
RUN wget http://cachefly.cachefly.net/10mb.test
RUN rm 10mb.test
而這樣只有 99MB，原因是每一個 RUN 都會疊一層上去：

FROM debian:wheezy
RUN apt-get update && apt-get install -y wget
RUN wget http://cachefly.cachefly.net/10mb.test && rm 10mb.test
所以，同樣的道理，要避免暫存檔時，可以考慮這種寫法：

wget -O - http://nodejs.org/dist/v0.10.32/node-v0.10.32-linux-x64.tar.gz | tar zxf -
以及裝完後馬上 clean：

FROM debian:wheezy
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
後面還有一些技巧，不過前面講的空間問題比較重要。
