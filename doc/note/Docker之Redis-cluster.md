# Docker之Redis-cluster

## 1. 环境搭建

**规划网络配置**

首先创建redis集群的网络

docker network create --subnet=10.0.0.0/16 redisnet

| ip       | port |
| -------- | ---- |
| 10.0.0.2 | 7001 |
| 10.0.0.3 | 7002 |
| 10.0.0.4 | 7003 |
| 10.0.0.5 | 7004 |
| 10.0.0.6 | 7005 |
| 10.0.0.7 | 7006 |



**docker-compose-redis-cluster.yml**

```
version: '3.7'

services:
  redis7001:
    image: 'redis'
    container_name: redis7001
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7001/data:/data
    ports:
      - "7001:6379"
      - "17001:16379"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai
    networks:
      redisnet:
        ipv4_address: 10.0.0.2

  redis7002:
    image: 'redis'
    container_name: redis7002
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7002/data:/data
    ports:
      - "7002:6379"
      - "17002:16379"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai
    networks:
      redisnet:
        ipv4_address: 10.0.0.3

  redis7003:
    image: 'redis'
    container_name: redis7003
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7003/data:/data
    ports:
      - "7003:6379"
      - "17003:16379"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai
    networks:
      redisnet:
        ipv4_address: 10.0.0.4

  redis7004:
    image: 'redis'
    container_name: redis7004
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7004/data:/data
    ports:
      - "7004:6379"
      - "17004:16379"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai
    networks:
      redisnet:
        ipv4_address: 10.0.0.5

  redis7005:
    image: 'redis'
    container_name: redis7005
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7005/data:/data
    ports:
      - "7005:6379"
      - "17005:16379"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai
    networks:
      redisnet:
        ipv4_address: 10.0.0.6

  redis7006:
    image: 'redis'
    container_name: redis7006
    command:
      ["redis-server", "/usr/local/etc/redis/redis.conf"]
    volumes:
      - ./redis.conf:/usr/local/etc/redis/redis.conf
      - ./redis-cluster/7006/data:/data
    ports:
      - "7006:6379"
      - "17006:16379"
    environment:
      # 设置时区为上海，否则时间会有问题
      - TZ=Asia/Shanghai
    networks:
      redisnet:
        ipv4_address: 10.0.0.7

networks:
  redisnet:
    driver: bridge
    ipam:
      config:
        - subnet: 10.0.0.0/16

```



**配置文件**

redis.conf完整配置文件见官网。

<a href="../assets/redis.conf" target="_blank">附件</a>

这里我们用自己的配置文件redis.conf

```conf
port 6379
# 开启集群
cluster-enabled yes
cluster-config-file nodes-6379.conf
cluster-node-timeout 5000
pidfile "/var/run/redis_6379.pid"
dir "/data"
logfile "/data/redis-6379.log"
requirepass "123456"
masterauth 123456
appendonly yes
```

> 重要:  配置文件映射，docker镜像redis 默认无配置文件。



**启动容器**

```
docker docker-compose -f docker-compose-redis-cluster.yml up -d
```

**配置集群**(不同版本详见[官方文档](https://redis.io/topics/cluster-tutorial))

```
docker exec -it redis7001 redis-cli -p 6379 -a 123456 --cluster create 10.0.0.2:6379 10.0.0.3:6379 10.0.0.4:6379 10.0.0.5:6379 10.0.0.6:6379 10.0.0.7:6379 --cluster-replicas 1
```

结果如下

```
➜  docker docker exec -it redis7001 redis-cli -p 6379 -a 123456 --cluster create 10.0.0.2:6379 10.0.0.3:6379 10.0.0.4:6379 10.0.0.5:6379 10.0.0.6:6379 10.0.0.7:6379 --cluster-replicas 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 10.0.0.6:6379 to 10.0.0.2:6379
Adding replica 10.0.0.7:6379 to 10.0.0.3:6379
Adding replica 10.0.0.5:6379 to 10.0.0.4:6379
M: 5a939e259552951e393101ae1bc9072e4bbeb84f 10.0.0.2:6379
   slots:[0-5460] (5461 slots) master
M: afb9cd705091e1bcf644f4e628a0a7451d7ffdf4 10.0.0.3:6379
   slots:[5461-10922] (5462 slots) master
M: f26bcb396a8181f5ca360fd0904c0282f15a221d 10.0.0.4:6379
   slots:[10923-16383] (5461 slots) master
S: 6dc5fc0c09c62d8c8d32c9f9b1e232acc224f00c 10.0.0.5:6379
   replicates f26bcb396a8181f5ca360fd0904c0282f15a221d
S: 8e48a3ebd3082362642d81bd2c52c769e24eec36 10.0.0.6:6379
   replicates 5a939e259552951e393101ae1bc9072e4bbeb84f
S: d7f6f7ae1ad5577856660d35b5aff6c9ae6f0424 10.0.0.7:6379
   replicates afb9cd705091e1bcf644f4e628a0a7451d7ffdf4
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
...
>>> Performing Cluster Check (using node 10.0.0.2:6379)
M: 5a939e259552951e393101ae1bc9072e4bbeb84f 10.0.0.2:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: afb9cd705091e1bcf644f4e628a0a7451d7ffdf4 10.0.0.3:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 6dc5fc0c09c62d8c8d32c9f9b1e232acc224f00c 10.0.0.5:6379
   slots: (0 slots) slave
   replicates f26bcb396a8181f5ca360fd0904c0282f15a221d
M: f26bcb396a8181f5ca360fd0904c0282f15a221d 10.0.0.4:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 8e48a3ebd3082362642d81bd2c52c769e24eec36 10.0.0.6:6379
   slots: (0 slots) slave
   replicates 5a939e259552951e393101ae1bc9072e4bbeb84f
S: d7f6f7ae1ad5577856660d35b5aff6c9ae6f0424 10.0.0.7:6379
   slots: (0 slots) slave
   replicates afb9cd705091e1bcf644f4e628a0a7451d7ffdf4
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

**查看网络配置**

```
docker network ls
docker network inspect docker_redisnet
```

结果

```
[
    {
        "Name": "docker_redisnet",
        "Id": "556b60eb1bb2170c89c203233cd44ff533c69d07c5ec3c9353ff78bbb80a978b",
        "Created": "2020-01-03T08:09:08.3830724Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "10.0.0.0/16"
                }
            ]
        },
        "Internal": false,
        "Attachable": true,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "00993eb1b306ef11195013afe79dd24c77db0923dff660038f88daaa57e4cee5": {
                "Name": "redis7006",
                "EndpointID": "994cfd5509e76bac7a38d494a0aab80ef3556e0de5e4c9f572bea9d8cfd99d23",
                "MacAddress": "02:42:0a:00:00:07",
                "IPv4Address": "10.0.0.7/16",
                "IPv6Address": ""
            },
            "5be0ab87fda70c93659c76547eb4a672ccf99dd6d8511219568f53878ba9492e": {
                "Name": "redis7002",
                "EndpointID": "97b0e0bc5626a489e4cf8a102f489488ce09b1d62027cdc76c3ec6d7cff2cd78",
                "MacAddress": "02:42:0a:00:00:03",
                "IPv4Address": "10.0.0.3/16",
                "IPv6Address": ""
            },
            "80e1f442a488f980c4a774838721d97c989dbec023853ea3010252ab62279453": {
                "Name": "redis7003",
                "EndpointID": "43507e4fd28bb01d821ad20bc6336d97e9925173c55c6a911356e0720bc735a6",
                "MacAddress": "02:42:0a:00:00:04",
                "IPv4Address": "10.0.0.4/16",
                "IPv6Address": ""
            },
            "b2e67931f7542eb399ffb0c9ab988014c5acb4311636697a352fa73f7f6c4c1c": {
                "Name": "redis7005",
                "EndpointID": "1d46c8c6b67ccd54e8ebf4c058708e5a2d9bdd9d719a3f7f28dd96a0e435b617",
                "MacAddress": "02:42:0a:00:00:06",
                "IPv4Address": "10.0.0.6/16",
                "IPv6Address": ""
            },
            "b3f196f958d788a86652e9814589a15f011b7353203d383ece1fe047e6c8a9cf": {
                "Name": "redis7004",
                "EndpointID": "388af22afa0070e72d93ef07fadb7e73c9957810476e2a5819dbb3798a7db2e9",
                "MacAddress": "02:42:0a:00:00:05",
                "IPv4Address": "10.0.0.5/16",
                "IPv6Address": ""
            },
            "da6f83feb829acfad8f1f54be1c8beaa74293bde4ce6484e522298fc2160393d": {
                "Name": "redis7001",
                "EndpointID": "ee8ed8abcfb26425b271093e7b4e8c35f680621aa9457f775f53f1bdf0a3f345",
                "MacAddress": "02:42:0a:00:00:02",
                "IPv4Address": "10.0.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {
            "com.docker.compose.network": "redisnet",
            "com.docker.compose.project": "docker",
            "com.docker.compose.version": "1.24.1"
        }
    }
]
```



## 2. 集群测试

**ping测试**

```
docker exec -it redis7001 redis-cli -h 10.0.0.7 -p 6379 -a 123456 ping
```

**redis测试**

```
docker exec -it redis7001 redis-cli -h 10.0.0.4 -c -p 6379 -a 123456
```

设置key-value结果

```
10.0.0.4:6379> set key1 1
-> Redirected to slot [9189] located at 10.0.0.3:6379
OK
10.0.0.3:6379>
```

> 注意：
>
> -a 代表密码
>
> 如果不用-c参数，则可能会报如下错误: (error) MOVED 9189 10.0.0.3:6379



**查看集群状态**

```
10.0.0.7:6379> cluster nodes
f26bcb396a8181f5ca360fd0904c0282f15a221d 10.0.0.4:6379@16379 master - 0 1578041565000 3 connected 10923-16383
8e48a3ebd3082362642d81bd2c52c769e24eec36 10.0.0.6:6379@16379 slave 5a939e259552951e393101ae1bc9072e4bbeb84f 0 1578041564082 5 connected
5a939e259552951e393101ae1bc9072e4bbeb84f 10.0.0.2:6379@16379 master - 0 1578041565000 1 connected 0-5460
afb9cd705091e1bcf644f4e628a0a7451d7ffdf4 10.0.0.3:6379@16379 master - 0 1578041565104 2 connected 5461-10922
d7f6f7ae1ad5577856660d35b5aff6c9ae6f0424 10.0.0.7:6379@16379 myself,slave afb9cd705091e1bcf644f4e628a0a7451d7ffdf4 0 1578041563000 6 connected
6dc5fc0c09c62d8c8d32c9f9b1e232acc224f00c 10.0.0.5:6379@16379 slave f26bcb396a8181f5ca360fd0904c0282f15a221d 0 1578041565611 4 connected
```

**查看slots**

```
10.0.0.3:6379> cluster slots
1) 1) (integer) 0
   2) (integer) 5460
   3) 1) "10.0.0.2"
      2) (integer) 6379
      3) "4579ff67a2ae08275e66ac72eb5cfdbf6bb6b697"
   4) 1) "10.0.0.6"
      2) (integer) 6379
      3) "0a46bc61364ac7c7a1e42d907b79dfdb72b71bd7"
2) 1) (integer) 10923
   2) (integer) 16383
   3) 1) "10.0.0.4"
      2) (integer) 6379
      3) "659b10c76b723da9caa33b51ad2f087739d481d5"
   4) 1) "10.0.0.5"
      2) (integer) 6379
      3) "08d29202d75af825ebda488f254a29e2b51f8699"
3) 1) (integer) 5461
   2) (integer) 10922
   3) 1) "10.0.0.3"
      2) (integer) 6379
      3) "39d27f77e0e8102ab4d9d46cc9b26ba0d881247d"
   4) 1) "10.0.0.7"
      2) (integer) 6379
      3) "8e6b886399e51e6ca8b096ac63130642e56900a6"
```

**查看集群状态**

```
10.0.0.3:6379> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:2
cluster_stats_messages_ping_sent:3021
cluster_stats_messages_pong_sent:2989
cluster_stats_messages_meet_sent:1
cluster_stats_messages_sent:6011
cluster_stats_messages_ping_received:2985
cluster_stats_messages_pong_received:3022
cluster_stats_messages_meet_received:4
cluster_stats_messages_received:6011
```

**试验读写分离**

试试看，发现读不到，原来在redis cluster中，如果你要在slave读取数据，那么需要带先执行`readonly`指令，再`get key1`。

```
➜  docker docker exec -it redis7001 redis-cli -h 10.0.0.7 -p 6379 -a 123456
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.7:6379> get key1
(error) MOVED 9189 10.0.0.3:6379
10.0.0.7:6379> readonly
OK
10.0.0.7:6379> get key1
"1"
10.0.0.7:6379>
```



## 3. 容灾演练

现在我们杀掉7003，看7006是否会接替它的位置。

```
➜  docker docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                              NAMES
88a5c26a606f        redis               "docker-entrypoint.s…"   5 minutes ago       Up 5 minutes        0.0.0.0:7005->6379/tcp, 0.0.0.0:17005->16379/tcp   redis7005
2e53220c5cac        redis               "docker-entrypoint.s…"   5 minutes ago       Up 5 minutes        0.0.0.0:7001->6379/tcp, 0.0.0.0:17001->16379/tcp   redis7001
9549a3a1cb7f        redis               "docker-entrypoint.s…"   5 minutes ago       Up 5 minutes        0.0.0.0:7006->6379/tcp, 0.0.0.0:17006->16379/tcp   redis7006
9480d7f3a9f2        redis               "docker-entrypoint.s…"   5 minutes ago       Up 5 minutes        0.0.0.0:7002->6379/tcp, 0.0.0.0:17002->16379/tcp   redis7002
33a3eacf8934        redis               "docker-entrypoint.s…"   5 minutes ago       Up 5 minutes        0.0.0.0:7003->6379/tcp, 0.0.0.0:17003->16379/tcp   redis7003
b677ec9f1498        redis               "docker-entrypoint.s…"   5 minutes ago       Up 5 minutes        0.0.0.0:7004->6379/tcp, 0.0.0.0:17004->16379/tcp   redis7004
➜  docker docker stop redis7001
redis7001
➜  docker docker exec -it redis7001 redis-cli -h 10.0.0.4 -c -p 6379 -a 123456
Error response from daemon: Container 2e53220c5cacbf61b97ed15a882c6c712c49a6b87fa88b972e2ac5227d6db8c0 is not running
➜  docker docker exec -it redis7002 redis-cli -h 10.0.0.4 -c -p 6379 -a 123456
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.4:6379> cluster nodes
afb9cd705091e1bcf644f4e628a0a7451d7ffdf4 10.0.0.3:6379@16379 master - 0 1578041915000 2 connected 5461-10922
f26bcb396a8181f5ca360fd0904c0282f15a221d 10.0.0.4:6379@16379 myself,master - 0 1578041914000 3 connected 10923-16383
d7f6f7ae1ad5577856660d35b5aff6c9ae6f0424 10.0.0.7:6379@16379 slave afb9cd705091e1bcf644f4e628a0a7451d7ffdf4 0 1578041915549 6 connected
8e48a3ebd3082362642d81bd2c52c769e24eec36 10.0.0.6:6379@16379 master - 0 1578041914936 7 connected 0-5460
6dc5fc0c09c62d8c8d32c9f9b1e232acc224f00c 10.0.0.5:6379@16379 slave f26bcb396a8181f5ca360fd0904c0282f15a221d 0 1578041913511 4 connected
5a939e259552951e393101ae1bc9072e4bbeb84f 10.0.0.2:6379@16379 master,fail - 1578041714875 1578041713349 1 connected
```



由日志可知，7005(10.0.0.6)已经变成了master。再试着启动7001，它将自动作为slave挂载到7005。如下：

```
➜  docker docker start redis7001
redis7001
➜  docker docker exec -it redis7002 redis-cli -h 10.0.0.4 -c -p 6379 -a 123456
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.4:6379> cluster nodes
afb9cd705091e1bcf644f4e628a0a7451d7ffdf4 10.0.0.3:6379@16379 master - 0 1578042191420 2 connected 5461-10922
f26bcb396a8181f5ca360fd0904c0282f15a221d 10.0.0.4:6379@16379 myself,master - 0 1578042192000 3 connected 10923-16383
d7f6f7ae1ad5577856660d35b5aff6c9ae6f0424 10.0.0.7:6379@16379 slave afb9cd705091e1bcf644f4e628a0a7451d7ffdf4 0 1578042191522 6 connected
8e48a3ebd3082362642d81bd2c52c769e24eec36 10.0.0.6:6379@16379 master - 0 1578042192436 7 connected 0-5460
6dc5fc0c09c62d8c8d32c9f9b1e232acc224f00c 10.0.0.5:6379@16379 slave f26bcb396a8181f5ca360fd0904c0282f15a221d 0 1578042192538 4 connected
5a939e259552951e393101ae1bc9072e4bbeb84f 10.0.0.2:6379@16379 slave 8e48a3ebd3082362642d81bd2c52c769e24eec36 0 1578042191000 7 connected
```

更加详细的容灾演练可参照[官网](https://redis.io/topics/cluster-tutorial)、 [博客](http://www.saily.top/2018/02/15/cache03/) 做水平扩容等演练。



## 4. 宿主机测试

**redis-cluster.tmpl**

```
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

**redis-clsuter-config.sh**

```
for port in `seq 7001 7006`; do \
  mkdir -p ./redis-cluster/${port}/conf \
  && PORT=${port} envsubst < ./redis-cluster.tmpl > ./redis-cluster/${port}/conf/redis.conf \
  && mkdir -p ./redis-cluster/${port}/data; \
done
```

**docker-compose-redis-cluster.yml**

```
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
    networks:
      redisnet:
        ipv4_address: 172.18.0.2

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
    networks:
      redisnet:
        ipv4_address: 172.18.0.3

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
    networks:
      redisnet:
        ipv4_address: 172.18.0.4

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
    networks:
      redisnet:
        ipv4_address: 172.18.0.5

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
    networks:
      redisnet:
        ipv4_address: 172.18.0.6

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
    networks:
      redisnet:
        ipv4_address: 172.18.0.7

networks:
  redisnet:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16

```

**配置集群**

```
docker exec -it redis7001 redis-cli -p 7001 -a 123456 --cluster create 192.168.124.5:7001 192.168.124.5:7002 192.168.124.5:7003 192.168.124.5:7004 192.168.124.5:7005 192.168.124.5:7006 --cluster-replicas 1
```

## 参考

- https://tvzr.com/archives/595