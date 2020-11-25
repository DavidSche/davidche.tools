# Docker之Zookeeper集群搭建

## 1. 集群搭建

**docker-compose.yml**

```yml
version: '3.7'

networks:
  docker_net:
    external: true
  net:
    driver: bridge

services:
  zoo1:
    image: zookeeper
    restart: unless-stopped
    hostname: zoo1
    container_name: zoo1
    ports:
      - 2182:2181
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=0.0.0.0:2888:3888;2181 server.2=zoo2:2888:3888;2181 server.3=zoo3:2888:3888;2181
    volumes:
      - ./zookeeper/zoo1/data:/data
      - ./zookeeper/zoo1/datalog:/datalog
    networks:
      - net

  zoo2:
    image: zookeeper
    restart: unless-stopped
    hostname: zoo2
    container_name: zoo2
    ports:
      - 2183:2181
    environment:
      ZOO_MY_ID: 2
      ZOO_SERVERS: server.1=zoo1:2888:3888;2181 server.2=0.0.0.0:2888:3888;2181 server.3=zoo3:2888:3888;2181
    volumes:
      - ./zookeeper/zoo2/data:/data
      - ./zookeeper/zoo2/datalog:/datalog
    networks:
      - net

  zoo3:
    image: zookeeper
    restart: unless-stopped
    hostname: zoo3
    container_name: zoo3
    ports:
      - 2184:2181
    environment:
      ZOO_MY_ID: 3
      ZOO_SERVERS: server.1=zoo1:2888:3888;2181 server.2=zoo2:2888:3888;2181 server.3=0.0.0.0:2888:3888;2181
    volumes:
      - ./zookeeper/zoo3/data:/data
      - ./zookeeper/zoo3/datalog:/datalog
    networks:
      - net

```

**校验配置**

```shell
docker-compose -f docker-compose-zk.yml config -q
```

**启动集群**

```shell
docker-compose -f docker-compose-zk.yml up -d
```

**查看容器启动情况**

```shell
➜  docker docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                                                  NAMES
ac21a50f548a        zookeeper           "/docker-entrypoint.…"   About a minute ago   Up 59 seconds       2888/tcp, 3888/tcp, 8080/tcp, 0.0.0.0:2182->2181/tcp   zoo2
901aa4eee887        zookeeper           "/docker-entrypoint.…"   About a minute ago   Up About a minute   2888/tcp, 3888/tcp, 0.0.0.0:2181->2181/tcp, 8080/tcp   zoo1
5e4e87f4aea5        zookeeper           "/docker-entrypoint.…"   About a minute ago   Up 59 seconds       2888/tcp, 3888/tcp, 8080/tcp, 0.0.0.0:2183->2181/tcp   zoo3
```

**查看zookeeper集群状态**

```shell
➜  docker docker exec -it zoo1 /bin/sh
# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /conf/zoo.cfg
Client port found: 2181. Client address: localhost.
Mode: follower
# exit

➜  docker docker exec -it zoo2 /bin/sh
# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /conf/zoo.cfg
Client port found: 2181. Client address: localhost.
Mode: follower
# exit

➜  docker docker exec -it zoo3 /bin/sh
# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /conf/zoo.cfg
Client port found: 2181. Client address: localhost.
Mode: leader
# exit
```

从上边的结果观察得知: zoo3目前位leader。

**检查其他状态**

```shell
➜  docker echo srvr | nc localhost 2182
Zookeeper version: 3.5.6-c11b7e26bc554b8523dc929761dd28808913f091, built on 10/08/2019 20:18 GMT
Latency min/avg/max: 0/0/0
Received: 3
Sent: 2
Connections: 1
Outstanding: 0
Zxid: 0x200000000
Mode: leader
Node count: 5
Proposal sizes last/min/max: -1/-1/-1
```



## 2. 集群测试

**关闭leader**

```shell
➜  docker docker stop zoo3
zoo3
```

**查看选举结果**

```shell
➜  docker docker exec -it zoo1 /bin/sh
# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /conf/zoo.cfg
Client port found: 2181. Client address: localhost.
Mode: follower
# exit

➜  docker docker exec -it zoo2 /bin/sh
# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /conf/zoo.cfg
Client port found: 2181. Client address: localhost.
Mode: leader
# exit
```

zookeeper集群重新选举结果: zoo2被选为leader

**再次启动zoo3**

```shell
➜  docker docker start zoo3
zoo3
```

**查看选举情况**

这里我们主要观察zoo3重新启动后是否会成为follower

```shell
➜  docker docker exec -it zoo3 /bin/sh
# zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /conf/zoo.cfg
Client port found: 2181. Client address: localhost.
Mode: follower
```

**查看yml配置的映射文件**

```shell
➜  docker tree
.
├── docker-compose-zk.yml
└── zookeeper
    ├── zoo1
    │   ├── data
    │   │   ├── myid
    │   │   └── version-2
    │   │       ├── acceptedEpoch
    │   │       ├── currentEpoch
    │   │       └── snapshot.0
    │   └── datalog
    │       └── version-2
    ├── zoo2
    │   ├── data
    │   │   ├── myid
    │   │   └── version-2
    │   │       ├── acceptedEpoch
    │   │       ├── currentEpoch
    │   │       └── snapshot.0
    │   └── datalog
    │       └── version-2
    └── zoo3
        ├── data
        │   ├── myid
        │   └── version-2
        │       ├── acceptedEpoch
        │       ├── currentEpoch
        │       ├── snapshot.0
        │       └── snapshot.200000000
        └── datalog
            └── version-2

16 directories, 14 files
```

打开currentEpoch，存储值为2，代表经过了2次选举。第一次为刚启动时触发选举，第二次为leader宕机后重新选举。



## 3. 基本操作

```shell
➜  docker docker exec -it zoo2 /bin/sh
# ./bin/zkCli.sh -server 127.0.0.1:2181
```



由于yml中配置2181端口和本地zookeeper冲突，暂时将原配置中2181改为2184端口。这里我们用本地的zkCli进行测试。系统环境为mac。

```shell
➜  docker zkCli -server 127.0.0.1:2182
Connecting to 127.0.0.1:2182
Welcome to ZooKeeper!
JLine support is enabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: 127.0.0.1:2182(CONNECTED) 0] ls /
[zookeeper]
[zk: 127.0.0.1:2182(CONNECTED) 1]
```

**创建顺序节点**

顺序节点保证znode路径将是唯一的。

```
[zk: 127.0.0.1:2182(CONNECTED) 1] create -s /zk-test 123
Created /zk-test0000000000
[zk: 127.0.0.1:2182(CONNECTED) 2] ls /
[zk-test0000000000, zookeeper]
```

**创建临时节点**

当会话过期或客户端断开连接时，临时节点将被自动删除

```
[zk: 127.0.0.1:2182(CONNECTED) 7] create -e /zk-temp 123
Created /zk-temp
[zk: 127.0.0.1:2182(CONNECTED) 8] ls /
[zk-test0000000000, zookeeper, zk-temp]
```

临时节点在客户端会话结束后就会自动删除，下面使用quit命令行退出客户端,再次连接后即可验证。

```
[zk: 127.0.0.1:2182(CONNECTED) 10] quit
Quitting...
➜  docker zkCli -server 127.0.0.1:2182
Connecting to 127.0.0.1:2182
Welcome to ZooKeeper!
JLine support is enabled

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: 127.0.0.1:2182(CONNECTED) 0] ls /
[zk-test0000000000, zookeeper]
[zk: 127.0.0.1:2182(CONNECTED) 1]
```

**创建永久节点**

```
[zk: 127.0.0.1:2182(CONNECTED) 1] create /zk-permanent 123
Created /zk-permanent
[zk: 127.0.0.1:2182(CONNECTED) 2] ls /
[zk-permanent, zk-test0000000000, zookeeper]	
```

**读取节点**

```
[zk: 127.0.0.1:2182(CONNECTED) 3] get /

cZxid = 0x0
ctime = Thu Jan 01 08:00:00 CST 1970
mZxid = 0x0
mtime = Thu Jan 01 08:00:00 CST 1970
pZxid = 0x100000006
cversion = 3
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 3
[zk: 127.0.0.1:2182(CONNECTED) 4] ls2 /
[zk-permanent, zk-test0000000000, zookeeper]
cZxid = 0x0
ctime = Thu Jan 01 08:00:00 CST 1970
mZxid = 0x0
mtime = Thu Jan 01 08:00:00 CST 1970
pZxid = 0x100000006
cversion = 3
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 3
```

**更新节点**

```
[zk: 127.0.0.1:2182(CONNECTED) 6] set /zk-permanent 456
cZxid = 0x100000006
ctime = Wed Jan 01 21:33:21 CST 2020
mZxid = 0x100000007
mtime = Wed Jan 01 21:42:00 CST 2020
pZxid = 0x100000006
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0
```

**检查状态**

```
[zk: 127.0.0.1:2182(CONNECTED) 7] stat /zk-permanent
cZxid = 0x100000006
ctime = Wed Jan 01 21:33:21 CST 2020
mZxid = 0x100000007
mtime = Wed Jan 01 21:42:00 CST 2020
pZxid = 0x100000006
cversion = 0
dataVersion = 1
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 3
numChildren = 0
```

**删除节点**

```
[zk: 127.0.0.1:2182(CONNECTED) 8] rmr /zk-permanent
[zk: 127.0.0.1:2182(CONNECTED) 9] ls /
[zk-test0000000000, zookeeper]
```



