# Docker之Redis哨兵

## 1. 环境搭建

```
version: '3.7'
services:
  master:
    image: redis
    container_name: redis-master
    restart: always
    command: redis-server --port 6379 --requirepass 123456  --appendonly yes
    ports:
      - 6379:6379
    volumes:
      - ./redis/master/data:/data
    networks:
      - redis-sentinel

  slave1:
    image: redis
    container_name: redis-slave-1
    restart: always
    command: redis-server --slaveof redis-master 6379 --port 6379  --requirepass 123456 --masterauth 123456  --appendonly yes
    ports:
      - 6380:6379
    volumes:
      - ./redis/slave1/data:/data
    networks:
      - redis-sentinel


  slave2:
    image: redis
    container_name: redis-slave-2
    restart: always
    command: redis-server --slaveof redis-master 6379 --port 6379  --requirepass 123456 --masterauth 123456  --appendonly yes
    ports:
      - 6381:6379
    volumes:
      - ./redis/slave2/data:/data
    networks:
      - redis-sentinel

networks:
  redis-sentinel:
    driver: bridge
```

**启动redis**

```
docker-compose -f docker-compose-redis.yml up -d
```

**查看启动日志**

```
docker logs -f 11f4bd6af2ba
```

**主从测试**

1、 在master中写入数据

```
➜  docker docker exec -it 9e4091def317 bash
root@9e4091def317:/data# redis-cli
127.0.0.1:6379> keys *
(error) NOAUTH Authentication required.
127.0.0.1:6379> auth 123456
OK
127.0.0.1:6379> keys *
(empty list or set)
127.0.0.1:6379> set name admin
OK
127.0.0.1:6379> keys *
1) "name"
127.0.0.1:6379>
```

2、 在slave中读取数据

```
➜  docker docker exec -it a8d8621693ba bash
root@a8d8621693ba:/data# redis-cli
127.0.0.1:6379> auth 123456
OK
127.0.0.1:6379> keys *
1) "name"
127.0.0.1:6379> get name
"admin"
127.0.0.1:6379>
```

3、 在slave中写数据

```
➜  docker docker exec -it cec356c920f7 bash
root@cec356c920f7:/data# redis-cli
127.0.0.1:6379> auth 123456
OK
127.0.0.1:6379> keys *
1) "name"
127.0.0.1:6379> set test admin
(error) READONLY You can't write against a read only replica.
127.0.0.1:6379>
```

4、查看映射持久化文件

```
➜  redis tree
.
├── master
│   └── data
│       ├── appendonly.aof
│       └── dump.rdb
├── slave1
│   └── data
│       ├── appendonly.aof
│       └── dump.rdb
└── slave2
    └── data
        ├── appendonly.aof
        └── dump.rdb
```

至此,redis一主二从完毕。(可以查看aof和rdb中内容)



## 2. 哨兵环境搭建

docker-compose-sentinel.yml

```
version: '3.7'
services:

  sentinel1:
    image: redis
    container_name: redis-sentinel-1
    ports:
      - "26379:26379"
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    volumes:
      - "./sentinel1.conf:/usr/local/etc/redis/sentinel.conf"
    networks:
      - redis-sentinel

  sentinel2:
    image: redis
    container_name: redis-sentinel-2
    ports:
      - "26380:26379"
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    volumes:
      - "./sentinel2.conf:/usr/local/etc/redis/sentinel.conf"
    networks:
      - redis-sentinel

  sentinel3:
    image: redis
    container_name: redis-sentinel-3
    ports:
      - "26381:26379"
    command: redis-sentinel /usr/local/etc/redis/sentinel.conf
    volumes:
      - ./sentinel3.conf:/usr/local/etc/redis/sentinel.conf
    networks:
      - redis-sentinel
      
networks:
  redis-sentinel:
    driver: bridge

```

sentinel.conf

```conf
port 26379
dir /tmp
# Redis监控一个叫做mymaster的运行在redis-master的master，投票达到2则表示master以及挂掉了
sentinel monitor mymaster redis-master 6379 2
# 设置主节点的密码
sentinel auth-pass mymaster 123456
# 在5s内sentinel向master发送的心跳PING没有回复则认为master不可用了,默认是30
sentinel down-after-milliseconds mymaster 5000
# parallel-syncs表示设置在故障转移之后，同时可以重新配置使用新master的slave的数量。数字越低，更多的时间将会用故障转移完成，但是如果slaves配置为服务旧数据，你可能不希望所有的slave同时重新同步master。因为主从复制对于slave是非阻塞的，当停止从master加载批量数据时有一个片刻延迟。通过设置选项为1，确信每次只有一个slave是不可到达的。
sentinel parallel-syncs mymaster 1
# 如果5秒以上连接不上主库同步，则在5秒后进行选举，对其他的从服务器进行角色转换
sentinel failover-timeout mymaster 5000
sentinel deny-scripts-reconfig yes
```

执行如下命令,复制3份redis-sentinel配置文件

```
cp sentinel.conf sentinel1.conf
cp sentinel.conf sentinel2.conf
cp sentinel.conf sentinel3.conf
```

**启动哨兵**

```
docker-compose -f docker-compose-sentinel.yml up -d
```

**查看redis-master**

```
➜  docker docker exec -it b935da217b3c bash
root@b935da217b3c:/data# redis-cli -p 26379
127.0.0.1:26379> sentinel master mymaster
 1) "name"
 2) "mymaster"
 3) "ip"
 4) "172.21.0.4"
 5) "port"
 6) "6379"
 7) "runid"
 8) "85903ac71d02e98675b4554796b86e24bd0626e4"
 9) "flags"
10) "master"
11) "link-pending-commands"
12) "0"
13) "link-refcount"
14) "1"
15) "last-ping-sent"
16) "0"
17) "last-ok-ping-reply"
18) "510"
19) "last-ping-reply"
20) "510"
21) "down-after-milliseconds"
22) "5000"
23) "info-refresh"
24) "3320"
25) "role-reported"
26) "master"
27) "role-reported-time"
28) "93566"
29) "config-epoch"
30) "0"
31) "num-slaves"
32) "2"
33) "num-other-sentinels"
34) "2"
35) "quorum"
36) "2"
37) "failover-timeout"
38) "5000"
39) "parallel-syncs"
40) "1"
127.0.0.1:26379>
```

**查看redis-slave**

```
127.0.0.1:26379> sentinel slaves mymaster
1)  1) "name"
    2) "172.21.0.2:6379"
    3) "ip"
    4) "172.21.0.2"
    5) "port"
    6) "6379"
    7) "runid"
    8) "696ef84649bd1b7c90df48282a9236526d11bf7b"
    9) "flags"
   10) "slave"
   11) "link-pending-commands"
   12) "0"
   13) "link-refcount"
   14) "1"
   15) "last-ping-sent"
   16) "0"
   17) "last-ok-ping-reply"
   18) "689"
   19) "last-ping-reply"
   20) "689"
   21) "down-after-milliseconds"
   22) "5000"
   23) "info-refresh"
   24) "5627"
   25) "role-reported"
   26) "slave"
   27) "role-reported-time"
   28) "246380"
   29) "master-link-down-time"
   30) "0"
   31) "master-link-status"
   32) "ok"
   33) "master-host"
   34) "172.21.0.4"
   35) "master-port"
   36) "6379"
   37) "slave-priority"
   38) "100"
   39) "slave-repl-offset"
   40) "51245"
2)  1) "name"
    2) "172.21.0.3:6379"
    3) "ip"
    4) "172.21.0.3"
    5) "port"
    6) "6379"
    7) "runid"
    8) "cf00da0a0978d302166dc89497ec548d6f1bff0c"
    9) "flags"
   10) "slave"
   11) "link-pending-commands"
   12) "0"
   13) "link-refcount"
   14) "1"
   15) "last-ping-sent"
   16) "0"
   17) "last-ok-ping-reply"
   18) "689"
   19) "last-ping-reply"
   20) "689"
   21) "down-after-milliseconds"
   22) "5000"
   23) "info-refresh"
   24) "5626"
   25) "role-reported"
   26) "slave"
   27) "role-reported-time"
   28) "246380"
   29) "master-link-down-time"
   30) "0"
   31) "master-link-status"
   32) "ok"
   33) "master-host"
   34) "172.21.0.4"
   35) "master-port"
   36) "6379"
   37) "slave-priority"
   38) "100"
   39) "slave-repl-offset"
   40) "51245"
127.0.0.1:26379>
```

**模拟故障**

停掉主redis，查看日志，哨兵进行了重新选主。

```
➜  docker docker stop redis-master
redis-master
➜  docker docker logs -f b935da217b3c
1:X 02 Jan 2020 19:32:16.886 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
1:X 02 Jan 2020 19:32:16.886 # Redis version=5.0.7, bits=64, commit=00000000, modified=0, pid=1, just started
1:X 02 Jan 2020 19:32:16.886 # Configuration loaded
1:X 02 Jan 2020 19:32:16.887 * Running mode=sentinel, port=26379.
1:X 02 Jan 2020 19:32:16.887 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:X 02 Jan 2020 19:32:16.898 # Sentinel ID is 68950d8be1846c49e42b9595c2b74edccf344fdd
1:X 02 Jan 2020 19:32:16.898 # +monitor master mymaster 172.21.0.4 6379 quorum 2
1:X 02 Jan 2020 19:32:16.904 * +slave slave 172.21.0.2:6379 172.21.0.2 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:32:16.914 * +slave slave 172.21.0.3:6379 172.21.0.3 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:32:18.944 * +sentinel sentinel b14662d71e8e9f5f8974692df87ffb14007bfd3f 172.21.0.6 26379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:32:19.103 * +sentinel sentinel 7df84033b192ee0bcdb7db3bc9799ff256b59c7d 172.21.0.7 26379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:32:27.003 * +fix-slave-config slave 172.21.0.2:6379 172.21.0.2 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:32:27.003 * +fix-slave-config slave 172.21.0.3:6379 172.21.0.3 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:32:46.024 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
1:X 02 Jan 2020 19:32:46.025 # Redis version=5.0.7, bits=64, commit=00000000, modified=0, pid=1, just started
1:X 02 Jan 2020 19:32:46.025 # Configuration loaded
1:X 02 Jan 2020 19:32:46.026 * Running mode=sentinel, port=26379.
1:X 02 Jan 2020 19:32:46.026 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:X 02 Jan 2020 19:32:46.027 # Sentinel ID is 68950d8be1846c49e42b9595c2b74edccf344fdd
1:X 02 Jan 2020 19:32:46.027 # +monitor master mymaster 172.21.0.4 6379 quorum 2
1:X 02 Jan 2020 19:32:47.987 * +sentinel-address-switch master mymaster 172.21.0.4 6379 ip 172.21.0.5 port 26379 for b14662d71e8e9f5f8974692df87ffb14007bfd3f
1:X 02 Jan 2020 19:39:07.407 # +sdown master mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:07.483 # +odown master mymaster 172.21.0.4 6379 #quorum 2/2
1:X 02 Jan 2020 19:39:07.483 # +new-epoch 1
1:X 02 Jan 2020 19:39:07.483 # +try-failover master mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:07.489 # +vote-for-leader 68950d8be1846c49e42b9595c2b74edccf344fdd 1
1:X 02 Jan 2020 19:39:07.498 # 7df84033b192ee0bcdb7db3bc9799ff256b59c7d voted for 68950d8be1846c49e42b9595c2b74edccf344fdd 1
1:X 02 Jan 2020 19:39:07.501 # b14662d71e8e9f5f8974692df87ffb14007bfd3f voted for 68950d8be1846c49e42b9595c2b74edccf344fdd 1
1:X 02 Jan 2020 19:39:07.561 # +elected-leader master mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:07.561 # +failover-state-select-slave master mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:07.617 # +selected-slave slave 172.21.0.2:6379 172.21.0.2 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:07.617 * +failover-state-send-slaveof-noone slave 172.21.0.2:6379 172.21.0.2 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:07.679 * +failover-state-wait-promotion slave 172.21.0.2:6379 172.21.0.2 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:08.341 # +promoted-slave slave 172.21.0.2:6379 172.21.0.2 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:08.341 # +failover-state-reconf-slaves master mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:08.387 * +slave-reconf-sent slave 172.21.0.3:6379 172.21.0.3 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:08.610 # -odown master mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:09.363 * +slave-reconf-inprog slave 172.21.0.3:6379 172.21.0.3 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:09.363 * +slave-reconf-done slave 172.21.0.3:6379 172.21.0.3 6379 @ mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:09.453 # +failover-end master mymaster 172.21.0.4 6379
1:X 02 Jan 2020 19:39:09.453 # +switch-master mymaster 172.21.0.4 6379 172.21.0.2 6379
1:X 02 Jan 2020 19:39:09.454 * +slave slave 172.21.0.3:6379 172.21.0.3 6379 @ mymaster 172.21.0.2 6379
1:X 02 Jan 2020 19:39:09.454 * +slave slave 172.21.0.4:6379 172.21.0.4 6379 @ mymaster 172.21.0.2 6379
1:X 02 Jan 2020 19:39:14.505 # +sdown slave 172.21.0.4:6379 172.21.0.4 6379 @ mymaster 172.21.0.2 6379
```

**测试故障转移**

测试新选主是否生效,如果可以写则生效。

```
➜  docker docker exec -it redis-slave-1 bash
root@9e88c1231cd4:/data# redis-cli
127.0.0.1:6379> auth 123456
OK
127.0.0.1:6379> keys *
1) "name"
127.0.0.1:6379> set test 123456
OK
127.0.0.1:6379>
```

**redis-master重新上线**

该节点作为slave节点加入集群

```
➜  docker docker exec -it redis-master bash
root@90a4a5ca9273:/data# redis-cli
127.0.0.1:6379> auth 123456
OK
127.0.0.1:6379> info replication
# Replication
role:slave
master_host:172.21.0.2
master_port:6379
master_link_status:down
master_last_io_seconds_ago:-1
master_sync_in_progress:0
slave_repl_offset:1
master_link_down_since_seconds:1577994813
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:6f1728a305b8a0bd2340740696c56ebd5717820a
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:0
second_repl_offset:-1
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
127.0.0.1:6379>
```

此外，由于哨兵不支持平滑的扩容，增加节点，那么自己要手动迁移数据。这里存在几个问题:

1. master下线后有新写入的数据;
2. master数据未完全同步到slave下线，造成数据丢失
3. 脑裂，也就是说，某个master所在机器突然脱离了正常的网络，跟其他slave机器不能连接，但是实际上master还运行着。

