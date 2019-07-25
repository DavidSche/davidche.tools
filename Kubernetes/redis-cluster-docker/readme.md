配置文件
首先要编写Redis的配置文件(redis.conf，文件名和位置随意)，开启集群支持。

port 6379
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
启动6个Redis容器
编写启动脚本并将配置文件所在目录挂载，每个Redis实例都需要能访问到。我这里是放在NAS服务器中并挂载到了每个节点的/mnt/data目录，根据实际情况修改。

REDIS_NUM=6
for i in $( seq 1 $REDIS_NUM )
do
  docker service create \
  --name "redis-$i" \
  --network swarm-net \
  --mount type=bind,src=/mnt/data/redis-cluster/config,target=/usr/local/etc/redis/ \
  redis redis-server /usr/local/etc/redis/redis.conf
done
建立Redis集群
管理Redis集群的脚本redis-trib.rb需要在Ruby环境中运行，而官方的Redis镜像中是没有Ruby环境的。由于管理脚本只需要执行初始化一次，而且Redis集群运行时不需要执行脚本，所以将脚本放在另外一个Ruby环境中执行。

部署Ruby环境并安装相应的库等。
docker service create \
--name redis-boot \
--mount type=bind,source=/mnt/data/redis-cluster/,target=/mnt/ \
--network swarm-net ruby sh -c '\
  gem install redis \
  && wget http://download.redis.io/redis-stable/src/redis-trib.rb \
  && sleep 3600'
初始化Redis集群
编写初始化脚本setup.sh，并将所在目录挂载到容器中。

REDIS_NUM=6
list=""
for i in $( seq 1 $REDIS_NUM )
do
  addr=$(getent hosts "redis-$i" | awk '{ print $1 }')
  list="$list $addr:6379 "
done

ruby /redis-trib.rb create --replicas 1 $list
进入ruby容器redis-boot，执行setup.sh即可创建集群。

因为docker swarm中ip是运行前分配的，不能提前指定，而且redis集群不支持使用host，所以初始化时利用getent命令解析出redis-X对应的ip

root@48c09cc1b6f0:/# bash /mnt/setup.sh 
>>> Creating cluster
>>> Performing hash slots allocation on 6 nodes...
Using 3 masters:
10.0.1.3:6379
10.0.1.7:6379
10.0.1.25:6379
......


测试
进入任意一个redis容器实例。

root@4a33c8e03279:/data# redis-cli -c -h redis-1
redis-1:6379> get a
-> Redirected to slot [15495] located at 10.0.1.26:6379
(nil)
10.0.1.26:6379> set b 1
-> Redirected to slot [3300] located at 10.0.1.5:6379
OK
10.0.1.5:6379> get b
"1"
10.0.1.5:6379> quit
root@4a33c8e03279:/data# 
root@4a33c8e03279:/data# redis-cli -c -h redis-1
redis-1:6379> get b
"1"
redis-1:6379> set c 1
-> Redirected to slot [7365] located at 10.0.1.19:6379
OK
10.0.1.19:6379> quit
root@4a33c8e03279:/data# redis-cli -c -h redis-1
redis-1:6379> get c
-> Redirected to slot [7365] located at 10.0.1.19:6379
"1"
需要设置 -c 参数表示开启集群模式，即自动跟随重定向

-c Enable cluster mode (follow -ASK and -MOVED redirections).

缺陷与改进
部署完成之后，除了测试可用性之外，还顺便研究了一下HA以及原有程序迁移的难度等等。发现了几个问题/不足。

不支持host
Redis集群中的节点都必须是IP，不能是类似redis-1这种host，而docker swarm的ip不能指定且每次失败重启后IP会变化，这就会导致节点实效后无法自动恢复，且手工干涉的话也只能是先删除实效节点原ID，并重新加入。
这个问题可以通过几个措施来解决/缓解：

利用端口映射，不同实例使用不同端口，然后建立集群时用外部IP，缺点是占用了很多端口
利用脚本，定时将失效节点删除并将新节点（失败重启）以slave身份加入
改造redis代码，见https://github.com/antirez/redis/pull/2323。没试过
slot失效导致整个集群不可用
集群运行过程中当某一个主节点失效并且该节点没有从节点时，分配到该节点的slot数据就会丢失，redis cluster一旦出现slot丢失的情况就会停止整个集群的服务，既不能读取也不能写入数据。
感觉这个设计不合理，有的场景下redis只是作为缓存使用，丢失了数据也没关系。这种情况下，更希望的是忽略错误，重新分片，继续提供服务，同时在日志中给出警告。不过，redis cluster似乎没有实现自动reshard。
这种情况下只能是保证每一个主节点在任意时刻都至少有一个从节点。不过，相比而言，使用性能强劲、运行稳定的服务器显然更加方便。

https://blog.newnius.com/setup-redis-cluster-based-on-docker-swarm.html

https://github.com/newnius/scripts/tree/master/redis-cluster

