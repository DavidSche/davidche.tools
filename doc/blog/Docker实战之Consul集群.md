# 前言

最近参加了几场Java面试，发现大多数的微服务实践还是Eureka偏多，鉴于笔者的单位选型Consul，这里对Consul做简单总结。

该篇是Docker实战系列的第三篇。传送门:

* [Docker实战之MySQL主从复制](https://mp.weixin.qq.com/s/3FbY6jT-PdgUHsRwHBSWBw)
* [Docker实战之Redis-Cluster集群](https://mp.weixin.qq.com/s/ksKeH8uVMuqL6LMbJwGEYw)

# 为什么选Consul？

首先Consul有以下几个关键特性:

* 服务发现：支持服务发现。你可以通过 DNS 或 HTTP 的方式获取服务信息。
* 健康检查：支持健康检查。可以提供与给定服务相关联的任何数量的健康检查（如 web 状态码或 cpu 使用率）。
* K/V 存储：键/值对存储。你可用通过 consul 存储如动态配置之类的相关信息。
* 多数据中心：支持多数据中心，开箱即用。
* WEB-UI：支持WEB-UI。点点点，你就能够了解你的服务现在的运行情况，一目了然，对开发运维是非常友好的。


作为高频的提问方式，面试官永远从十万个为什么开始。但是最为程序员，还是需要`知其然，知其所以然`。以下是几个常用的服务发现组件的对比。

![](https://gitee.com/idea360/oss/raw/master/images/service-discovery-vs.png)

服务发现组件的选型主要从以下几个方面进行。CAP理论、一致性算法、多数据中心、健康检查、是否支持k8s等。

**1. CAP**

一致性的强制数据统一要求，必然会导致在更新数据时部分节点处于被锁定状态，此时不可对外提供服务，影响了服务的可用性。


**2. 一致性算法**

`Raft`算法将Server分为三种类型：Leader、Follower和Candidate。Leader处理所有的查询和事务，并向Follower同步事务。Follower会将所有的RPC查询和事务转发给Leader处理，它仅从Leader接受事务的同步。数据的一致性以Leader中的数据为准实现。

以下是几种常见的一致性算法

![](https://gitee.com/idea360/oss/raw/master/images/consensus-algorithm%20.png)


**3. 多数据中心**

Consul 通过 WAN 的Gossip协议，完成跨数据中心的同步；而其他的产品则需要额外的开发工作来实现；

> 注意多数据中心和多节点是2个概念

Gossip协议是P2P网络中比较成熟的协议。Gossip协议的最大的好处是，即使集群节点的数量增加，每个节点的负载也不会增加很多，几乎是恒定的。这就允许Consul管理的集群规模能横向扩展到数千个节点。

Consul的每个Agent会利用Gossip协议互相检查在线状态，本质上是节点之间互Ping，分担了服务器节点的心跳压力。如果有节点掉线，不用服务器节点检查，其他普通节点会发现，然后用Gossip广播给整个集群。

![](https://gitee.com/idea360/oss/raw/master/images/gossip.png)

# Consul架构

consul 的架构是什么，官方给出了一个很直观的图片

![](https://gitee.com/idea360/oss/raw/master/images/consul-architecture.png)

单独看数据中心1，可以看出consul的集群是由N个SERVER，加上M个CLIENT组成的。而不管是SERVER还是CLIENT，都是consul的一个节点，所有的服务都可以注册到这些节点上，正是通过这些节点实现服务注册信息的共享。除了这两个，还有一些小细节，一一简单介绍。

**CLIENT**

CLIENT表示consul的client模式，就是客户端模式。是consul节点的一种模式，这种模式下，所有注册到当前节点的服务会被转发到SERVER，本身是不持久化这些信息。

**SERVER**

SERVER表示consul的server模式，表明这个consul是个server，这种模式下，功能和CLIENT都一样，唯一不同的是，它会把所有的信息持久化的本地，这样遇到故障，信息是可以被保留的。

**SERVER-LEADER**

中间那个SERVER下面有LEADER的字眼，表明这个SERVER是它们的老大，它和其它SERVER不一样的一点是，它需要负责同步注册的信息给其它的SERVER，同时也要负责各个节点的健康监测。

# Docker环境搭建

docker-compose-consul-cluster.yml

```yaml
version: '3'
services:
  consul-server1:
    image: consul:latest
    hostname: "consul-server1"
    ports:
      - "8500:8500"
      - "53"
    volumes:
      - ./consul/data1:/consul/data
    command: "agent -server -bootstrap-expect 3 -ui -disable-host-node-id -client 0.0.0.0"
  consul-server2:
    image: consul:latest
    hostname: "consul-server2"
    ports:
      - "8501:8500"
      - "53"
    volumes:
      - ./consul/data2:/consul/data
    command: "agent -server -ui -join consul-server1 -disable-host-node-id -client 0.0.0.0"
    depends_on:
      - consul-server1
  consul-server3:
    image: consul:latest
    hostname: "consul-server3"
    ports:
      - "8502:8500"
      - "53"
    volumes:
      - ./consul/data3:/consul/data
    command: "agent -server -ui -join consul-server1 -disable-host-node-id -client 0.0.0.0"
    depends_on:
      - consul-server1
  consul-node1:
    image: consul:latest
    hostname: "consul-node1"
    command: "agent -join consul-server1 -disable-host-node-id"
    depends_on:
      - consul-server1
  consul-node2:
    image: consul:latest
    hostname: "consul-node2"
    command: "agent -join consul-server1 -disable-host-node-id"
    depends_on:
      - consul-server1

```

执行 `docker-compose -f docker-compose-consul-cluster.yml up -d` 启动，然后访问
[http://localhost:8500](http://localhost:8500)

看到下图即启动成功

![](https://gitee.com/idea360/oss/raw/master/images/docker-consul-cluster-start.png)

# 最后

Docker实战系列皆以快速搭建学习环境为主，Consul的特性学习及生产环境配置还任重道远。阅读过程中如有疑问或错误，还望多多指正。

