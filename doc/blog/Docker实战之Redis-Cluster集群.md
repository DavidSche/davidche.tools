# 概述

接上一篇[Docker实战之MySQL主从复制](https://mp.weixin.qq.com/s/3FbY6jT-PdgUHsRwHBSWBw), 这里是Docker实战系列的第二篇，主要进行Redis-Cluster集群环境的快速搭建。Redis作为基于键值对的NoSQL数据库，具有高性能、丰富的数据结构、持久化、高可用、分布式等特性，同时Redis本身非常稳定，已经得到业界的广泛认可和使用。

在Redis中，集群的解决方案有三种

1. 主从复制
2. 哨兵机制
3. Cluster

Redis Cluster是Redis的分布式解决方案，在 3.0 版本正式推出。

# 集群方案的对比

**1. 主从复制**

同Mysql主从复制的原因一样，Redis虽然读取写入的速度都特别快，但是也会产生读压力特别大的情况。为了分担读压力，Redis支持主从复制，读写分离。一个Master可以有多个Slaves。

![](https://gitee.com/idea360/oss/raw/master/images/redis-master-slave.jpg)

优点

- 数据备份
- 读写分离，提高服务器性能

缺点

- 不能自动故障恢复,RedisHA系统（需要开发）
- 无法实现动态扩容

**2. 哨兵机制**

Redis Sentinel是社区版本推出的原生`高可用`解决方案，其部署架构主要包括两部分：Redis Sentinel集群和Redis数据集群。

其中Redis Sentinel集群是由若干Sentinel节点组成的分布式集群，可以实现故障发现、故障自动转移、配置中心和客户端通知。Redis Sentinel的节点数量要满足2n+1（n>=1）的奇数个。

![](https://gitee.com/idea360/oss/raw/master/images/redis-sentinel.png)

优点

- 自动化故障恢复

缺点

- Redis 数据节点中 slave 节点作为备份节点不提供服务
- 无法实现动态扩容


**3. Redis-Cluster**

Redis Cluster是社区版推出的Redis分布式集群解决方案，主要解决Redis分布式方面的需求，比如，当遇到单机内存，并发和流量等瓶颈的时候，Redis Cluster能起到很好的负载均衡的目的。

Redis Cluster着眼于`提高并发量`。

群集至少需要3主3从，且每个实例使用不同的配置文件。

在redis-cluster架构中，`redis-master节点一般用于接收读写，而redis-slave节点则一般只用于备份`， 其与对应的master拥有相同的slot集合，若某个redis-master意外失效，则再将其对应的slave进行升级为临时redis-master。 

在redis的官方文档中，对redis-cluster架构上，有这样的说明：在cluster架构下，默认的，一般redis-master用于接收读写，而redis-slave则用于备份，`当有请求是在向slave发起时，会直接重定向到对应key所在的master来处理`。 但如果不介意读取的是redis-cluster中有可能过期的数据并且对写请求不感兴趣时，则亦可通过`readonly`命令，将slave设置成可读，然后通过slave获取相关的key，达到读写分离。具体可以参阅redis[官方文档](https://redis.io/commands/readonly)等相关内容

![](https://gitee.com/idea360/oss/raw/master/images/redis-cluster.jpg)

优点

- 解决分布式负载均衡的问题。具体解决方案是分片/虚拟槽slot。
- 可实现动态扩容
- P2P模式，无中心化

缺点

- 为了性能提升，客户端需要缓存路由表信息
- Slave在集群中充当“冷备”，不能缓解读压力

# 网络规划

这里没有搭建虚拟机环境，全部在本地部署。本机的ip为 `192.168.124.5`

| ip            | port |
| ------------- | ---- |
| 192.168.124.5 | 7001 |
| 192.168.124.5 | 7002 |
| 192.168.124.5 | 7003 |
| 192.168.124.5 | 7004 |
| 192.168.124.5 | 7005 |
| 192.168.124.5 | 7006 |

# Redis配置文件

在docker环境中，配置文件映射宿主机的时候，(宿主机)必须有配置文件。[附件](https://raw.githubusercontent.com/antirez/redis/5.0.7/redis.conf)在这里。大家可以根据自己的需求定制配置文件。

下边是我的配置文件 `redis-cluster.tmpl`

```text
# redis端口
port ${PORT}
# 关闭保护模式
protected-mode no
# 开启集群
cluster-enabled yes
# 集群节点配置
cluster-config-file nodes.conf
# 超时
cluster-node-timeout 5000
# 集群节点IP host模式为宿主机IP
cluster-announce-ip 192.168.124.5
# 集群节点端口 7001 - 7006
cluster-announce-port ${PORT}
cluster-announce-bus-port 1${PORT}
# 开启 appendonly 备份模式
appendonly yes
# 每秒钟备份
appendfsync everysec
# 对aof文件进行压缩时，是否执行同步操作
no-appendfsync-on-rewrite no
# 当目前aof文件大小超过上一次重写时的aof文件大小的100%时会再次进行重写
auto-aof-rewrite-percentage 100
# 重写前AOF文件的大小最小值 默认 64mb
auto-aof-rewrite-min-size 64mb
```

由于节点IP相同，只有端口上的差别，现在通过脚本 `redis-cluster-config.sh` 批量生成配置文件

```bash
for port in `seq 7001 7006`; do \
  mkdir -p ./redis-cluster/${port}/conf \
  && PORT=${port} envsubst < ./redis-cluster.tmpl > ./redis-cluster/${port}/conf/redis.conf \
  && mkdir -p ./redis-cluster/${port}/data; \
done
```

生成的配置文件如下图

![](https://gitee.com/idea360/oss/raw/master/images/redis-cluster-config-tree.png)


# Docker环境搭建

这里还是通过docker-compose进行测试环境的docker编排。

```yaml
version: '3.7'

services:
  redis7001:
    image: 'redis'
    container_name: redis7001
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis-cluster/7001/conf/redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7001/data:/data
    ports:
      - "7001:7001"
      - "17001:17001"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai


  redis7002:
    image: 'redis'
    container_name: redis7002
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis-cluster/7002/conf/redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7002/data:/data
    ports:
      - "7002:7002"
      - "17002:17002"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai


  redis7003:
    image: 'redis'
    container_name: redis7003
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis-cluster/7003/conf/redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7003/data:/data
    ports:
      - "7003:7003"
      - "17003:17003"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai


  redis7004:
    image: 'redis'
    container_name: redis7004
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis-cluster/7004/conf/redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7004/data:/data
    ports:
      - "7004:7004"
      - "17004:17004"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai


  redis7005:
    image: 'redis'
    container_name: redis7005
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis-cluster/7005/conf/redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7005/data:/data
    ports:
      - "7005:7005"
      - "17005:17005"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai


  redis7006:
    image: 'redis'
    container_name: redis7006
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis-cluster/7006/conf/redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7006/data:/data
    ports:
      - "7006:7006"
      - "17006:17006"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai

```

启动结果如图

![](https://gitee.com/idea360/oss/raw/master/images/docker-redis-up.png)

# 集群配置

redis集群官方提供了配置脚本，4.x和5.x略有不同，具体可参见[集群配置](https://redis.io/topics/cluster-tutorial)

下边是我自己的环境

```bash
docker exec -it redis7001 redis-cli -p 7001 -a 123456 --cluster create 192.168.124.5:7001 192.168.124.5:7002 192.168.124.5:7003 192.168.124.5:7004 192.168.124.5:7005 192.168.124.5:7006 --cluster-replicas 1
```

看到如下结果说明集群配置成功

![](https://gitee.com/idea360/oss/raw/master/images/docker-redis-cluster-success.png)

# 集群测试

接下来进行一些集群的基本测试

**1. 查看集群通信是否正常**

redis7001主节点对它的副本节点redis7005进行ping操作。

> -h host -p port -a pwd  

```bash
➜  docker docker exec -it redis7001 redis-cli -h 192.168.124.5 -p 7005 -a 123456 ping

Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
PONG
```

**2. 测试简单存储**

redis7001主节点客户端操作redis7003主节点

```bash
➜  docker docker exec -it redis7001 redis-cli -h 192.168.124.5 -p 7003 -a 123456

Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
192.168.124.5:7003> set name admin
(error) MOVED 5798 192.168.124.5:7002
```
由于Redis Cluster会根据key进行hash运算，然后将key分散到不同slots，name的hash运算结果在redis7002节点上的slots中。所以我们操作redis7003写操作会自动路由到7002。然而error提示无法路由？没关系，差一个 `-c` 参数而已。

再次运行查看结果如下:

```bash
➜  docker docker exec -it redis7001 redis-cli -h 192.168.124.5 -p 7003 -a 123456 -c

Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
192.168.124.5:7003> set name admin
-> Redirected to slot [5798] located at 192.168.124.5:7002
OK
192.168.124.5:7002> get name
"admin"
192.168.124.5:7002>
```

**3. 查看集群状态**

![](https://gitee.com/idea360/oss/raw/master/images/redis-cluster-node.png)


**4. 查看slots分片**

![](https://gitee.com/idea360/oss/raw/master/images/redis-cluster-slots-info.png)

**5. 查看集群信息**

![](https://gitee.com/idea360/oss/raw/master/images/redis-cluster-info.png)

**6. 测试读写分离**

![](https://gitee.com/idea360/oss/raw/master/images/redis-cluster-slave-readonly.png)

试试看，发现读不到，原来在redis cluster中，如果你要在slave读取数据，那么需要带先执行 `readonly` 指令，然后 `get key`

**7. 简单压测**


| 选项  | 描述                         |
| ---- | --------------------------- |
| -t   |指定命令                       |
| -c   |客户端连接数                    |
| -n   |总请求数                       |
| -d   |set、get的value大小(单位byte)   |


测试如下

```bash
➜  docker docker exec -it redis7001 bash
root@cbc6e76a3ed2:/data# redis-benchmark -h 192.168.124.5 -p 7001 -t set -c 100 -n 50000 -d 20
====== SET ======
  50000 requests completed in 10.65 seconds
  100 parallel clients
  20 bytes payload
  keep alive: 1

0.00% <= 2 milliseconds
0.01% <= 3 milliseconds
...
100.00% <= 48 milliseconds
100.00% <= 49 milliseconds
4692.63 requests per second
```

这里没啥实际意义，在工作业务上大家可以根据QPS和主机配置进行压测，计算规划出节点数量。

# 容灾演练

现在我们杀掉主节点redis7001，看从节点redis7005是否会接替它的位置。

```bash
docker stop redis7001
```

![](https://gitee.com/idea360/oss/raw/master/images/redis-clsuter-stop-master.png)

再试着启动7001，它将自动作为slave挂载到7005

![](https://gitee.com/idea360/oss/raw/master/images/redis-cluster-slave-restart.png)

# SpringBoot配置Redis集群

在SpringBoot2.x版本中，redis默认的连接池已经更换为Lettuce，而不再是jedis。

**1. 在pom.xml中引入相关依赖**

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-pool2</artifactId>
        </dependency>
```

**2. application.yml**

```yaml
spring:
  redis:
    timeout: 6000
    password: 123456
    cluster:
      max-redirects: 3 # 获取失败 最大重定向次数 
      nodes:
        - 192.168.124.5:7001
        - 192.168.124.5:7002
        - 192.168.124.5:7003
        - 192.168.124.5:7004
        - 192.168.124.5:7005
        - 192.168.124.5:7006
    lettuce:
      pool:
        max-active: 1000 #连接池最大连接数（使用负值表示没有限制）
        max-idle: 10 # 连接池中的最大空闲连接
        min-idle: 5 # 连接池中的最小空闲连接
        max-wait: -1 # 连接池最大阻塞等待时间（使用负值表示没有限制）
  cache:
    jcache:
      config: classpath:ehcache.xml
```

**3. redis配置**

```java
@Configuration
@AutoConfigureAfter(RedisAutoConfiguration.class)
public class RedisConfig {
    @Bean
    public RedisTemplate<String, Object> redisCacheTemplate(LettuceConnectionFactory redisConnectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setKeySerializer(new StringRedisSerializer());
        template.setValueSerializer(new GenericJackson2JsonRedisSerializer());
        template.setConnectionFactory(redisConnectionFactory);
        return template;
    }
}
```

**4. 基本测试**

```java
@SpringBootTest
public class RedisTest {

    @Autowired
    private RedisTemplate<String, String> redisTemplate;

    @Test
    public void test() {
        redisTemplate.opsForValue().set("name", "admin");
        String name = redisTemplate.opsForValue().get("name");
        System.out.println(name); //输出admin
    }
}
```



# 总结

通过以上演示，基本上可以在本地环境下用我们的Redis Cluster集群了。最后再上一张本地映射文件的最终样子，帮助大家了解Redis持久化及集群相关的东西。感兴趣的小伙伴可以自行测试并查看其中的内容。

![](https://gitee.com/idea360/oss/raw/master/images/docker-redis-cluster-map-file.png)

内容如有错漏，还望大家不吝赐教，同时，欢迎大家关注公众号【当我遇上你】,你们的支持就是我写作的最大动力。

# 参考

- https://redis.io/topics/cluster-tutorial




