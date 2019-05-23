# Keepalived

While having a self-healing, scalable docker swarm is great for availability and scalability, none of that is any good if nobody can connect to your cluster.

In order to provide seamless external access to clustered resources, regardless of which node they're on and tolerant of node failure, you need to present a single IP to the world for external access.

Normally this is done using a HA loadbalancer, but since Docker Swarm aready provides the load-balancing capabilities (routing mesh), all we need for seamless HA is a virtual IP which will be provided by more than one docker node.

This is accomplished with the use of keepalived on at least two nodes.

假定条件:

- 至少 2 x swarm nodes
- 低延迟网络 (i.e., no WAN links)

新:

- 至少 3 个 IPv4 地址 (两个节点个使用一个，一个用于虚拟 IP)

## 准备工作

启用/激活 IPVS 模块

要想允许服务不绑定本地接口的地址，需要 keepalived 中所有参与的节点，都需要启用 "ip_vs" 内核模块

在主节点和辅节点分别设置启用ip_vs 内核模块，运行以下命令：

```bash
echo "modprobe ip_vs" >> /etc/rc.local
modprobe ip_vs
```

## 设置节点

假定分配以下 IPs 地址:

- 192.168.4.1 : 主节点
- 192.168.4.2 : 辅节点
- 192.168.4.3 : 虚拟节点

在主节点运行以下命令：

``` bash
docker run -d --name keepalived --restart=always \
  --cap-add=NET_ADMIN --net=host \
  -e KEEPALIVED_UNICAST_PEERS="#PYTHON2BASH:['192.168.9.26', '192.168.9.27']" \
  -e KEEPALIVED_VIRTUAL_IPS=192.168.9.144 \
  -e KEEPALIVED_PRIORITY=200 \
  osixia/keepalived:2.0.15
```

在辅节点运行以下命令

``` bash
docker run -d --name keepalived --restart=always \
  --cap-add=NET_ADMIN --net=host \
  -e KEEPALIVED_UNICAST_PEERS="#PYTHON2BASH:['192.168.9.26', '192.168.9.27']" \
  -e KEEPALIVED_VIRTUAL_IPS=192.168.9.144 \
  -e KEEPALIVED_PRIORITY=100 \
  osixia/keepalived:2.0.15 
```

### 服务

每个节点将通过单播与另一个节点通信（不需要防火墙多播地址），并且具有最高优先级的节点将成为主节点。当入口流量通过VIP到达主节点时，docker的路由网格将把它传送到适当的docker节点。

> 笔记

  - 一些托管平台（OpenStack，一个）将不允许您简单地“声称”虚拟IP。除非云管理员禁用某些安全控制，否则每个节点仅能够接收以其唯一IP为目标的流量。在这种情况下，keepalived不是正确的解决方案，应该使用特定于平台的负载平衡解决方案。在OpenStack中，这是Neutron的“负载平衡器即服务”（LBAAS）组件。AWS，GCP和Azure可能包含类似的保护措施。
  - 超过2个节点可以参与keepalived。只需确保每个节点都具有适当的优先级集，并且具有最高优先级的节点将成为主节点。

[出处](https://geek-cookbook.funkypenguin.co.nz/ha-docker-swarm/keepalived/#preparation)

--------

## Keepalived实现廉价HA

Posted on May 14, 2019

最近在dockerize各种home lab上的服务，其中遇到的一个问题就是如何实现HA。最方便的实现方式是打开eBay.com搜索F5 Big IP 购买硬件Load Balancer。最廉价的方式是多个设备间跑VRRP协议实现自动Fail over切换。Keepalived 就是一个精细生活VRRP的软件实现。

具体用例为两台Docker node上各跑了一个container运行unbound提供recursive DNS服务。任意一台机器下线（不管是container下线或是node下线）都由另一台机器在同一个IP地址下继续提供服务。切换期间网络不不会中断。

既然已经有了两台运转正常的Docker node，显然Keepalived跑在Container里是最经济且便于管理的。这里用到的docker image是 https://github.com/osixia/docker-keepalived

需要注意的是两台机器的sysctl需要设置 net.ipv4.ip_nonlocal_bind=1 在Ubuntu上可以通过修改 /etc/sysctl.conf 并运行 sysctl -p /etc/sysctl.conf 实现。在RancherOS上需要修改cloud-config.yml 具体参考官方文档

并且这两个container需要跑在host network上且赋予 CAP_NET_ADMIN (--cap-add NET_ADMIN)

以下是用docker-composer 和直接运行docker run的两种配置。

### docker-composer.yml

``` yml
keepalived:
     container_name: keepalived
     image: arcts/keepalived:latest
     environment:
       - KEEPALIVED_AUTOCONF=true
       - KEEPALIVED_STATE=MASTER
       - KEEPALIVED_INTERFACE=eth0
       - KEEPALIVED_VIRTUAL_ROUTER_ID=2
       - KEEPALIVED_UNICAST_SRC_IP=10.2.1.10
       - KEEPALIVED_UNICAST_PEER_0=10.2.1.11
       - KEEPALIVED_TRACK_INTERFACE_1=eth0
       - KEEPALIVED_VIRTUAL_IPADDRESS_1="10.2.1.12/24 dev eth0"
     network_mode: "host"
     cap_add:
       - NET_ADMIN
```

### docker run command

``` bash
docker run -d --name keepalived --net=host --cap-add NET_ADMIN \
-e KEEPALIVED_AUTOCONF=true               	\
-e KEEPALIVED_STATE=BACKUP           		\
-e KEEPALIVED_INTERFACE=eth0                \
-e KEEPALIVED_VIRTUAL_ROUTER_ID=2           \
-e KEEPALIVED_UNICAST_SRC_IP=10.2.1.11    	\
-e KEEPALIVED_UNICAST_PEER_0=10.2.1.10     \
-e KEEPALIVED_TRACK_INTERFACE_1=eth0        \
-e KEEPALIVED_VIRTUAL_IPADDRESS_1="10.2.1.12/24 dev eth0" \
arcts/keepalived

```

至此 IP地址 10.2.1.12 就由 10.2.1.10 为master ，10.2.1.10下线 则10.2.1.11 自动由backup转为master继续提供服务
