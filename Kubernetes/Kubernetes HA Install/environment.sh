#!/usr/bin/bash

# 生成 EncryptionConfig 所需的加密 key
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

# 最好使用 当前未用的网段 来定义服务网段和 Pod 网段

# 服务网段，部署前路由不可达，部署后集群内路由可达(kube-proxy 和 ipvs 保证)
export SERVICE_CIDR="10.254.0.0/16"

# Pod 网段，建议 /16 段地址，部署前路由不可达，部署后集群内路由可达(flanneld 保证)
export CLUSTER_CIDR="172.30.0.0/16"

# 服务端口范围 (NodePort Range)
export NODE_PORT_RANGE="8400-9000"

# 集群各机器 IP 数组
export K8S_IPS=(192.168.80.61 192.168.80.62 192.168.80.63 192.168.80.64 192.168.80.65 192.168.80.66 192.168.80.67)
export MASTER_IPS=(192.168.80.61 192.168.80.62 192.168.80.63)
export NODE_IPS=(192.168.80.64 192.168.80.65 192.168.80.66 192.168.80.67)

# 集群各 IP 对应的 主机名数组
export K8S_NAMES=(master01 master02 master03 node01 node02 node03 node04)
export MASTER_NAMES=(master01 master02 master03)
export NODE_NAMES=(node01 node02 node03 node04)

# kube-apiserver 的 VIP（HA 组件 keepalived 发布的 IP）
export MASTER_VIP=192.168.80.61

# kube-apiserver VIP 地址（HA 组件 haproxy 监听 8443 端口）
#export KUBE_APISERVER="https://${MASTER_VIP}:8443"
export KUBE_APISERVER="https://${MASTER_VIP}:6443"

# HA 节点，配置 VIP 的网络接口名称
#export VIP_IF="eth0"
export VIP_IF="ens33"

#  flanneld的网络接口名称
export FLANNEL_IFACE="ens33"

# etcd 集群服务地址列表
export ETCD_ENDPOINTS="https://192.168.80.61:2379,https://192.168.80.62:2379,https://192.168.80.63:2379"

# etcd 集群间通信的IP和端口
export ETCD_NODES="master01=https://192.168.80.61:2380,master02=https://192.168.80.62:2380,master03=https://192.168.80.63:2380"

# flanneld 网络配置前缀
export FLANNEL_ETCD_PREFIX="/kubernetes/network"

# kubernetes 服务 IP (一般是 SERVICE_CIDR 中第一个IP)
export CLUSTER_KUBERNETES_SVC_IP="10.254.0.1"

# 集群 DNS 服务 IP (从 SERVICE_CIDR 中预分配)
export CLUSTER_DNS_SVC_IP="10.254.0.2"

# 集群 DNS 域名
export CLUSTER_DNS_DOMAIN="cluster.local."

# 将二进制目录 /opt/k8s/bin 加到 PATH 中
#export PATH=/opt/k8s/bin:$PATH




