# 前言

曾几何时，看着高大上的架构和各位前辈高超的炫技，有没有怦然心动，也想一窥究竟？每当面试的时候，拿着单应用的架构，吹着分库分表的牛X，有没有心里慌的一批？

其实很多时候，我们所缺少的只是对高大上的技术的演练。没有相关的业务需求，没有集群环境，然后便只是Google几篇博文，看下原理，便算是了解了。然而真的明白了吗？众多的复制粘贴中，那篇文章才对我们有用，哪些又是以讹传讹？

所幸容器技术的快速发展，让各种技术的模拟成为现实。接下来Docker相关的一系列文章，将以实战为主，帮助大家快速搭建测试和演练环境。

# Docker文件编排

由于是测试为了演练用，这里用docker-compose进行配置文件的编排，实际的集群环境中并不是这么部署的。

1. 编排docker-compose-mysql-cluster.yml,安装master和slave节点

```yaml
version: '3'
services:
  mysql-master:
    image: mysql:5.7
    container_name: mysql-master
    environment:
      - MYSQL_ROOT_PASSWORD=root
    ports:
      - "3307:3306"
    volumes:
      - "./mysql/master/my.cnf:/etc/my.cnf"
      - "./mysql/master/data:/var/lib/mysql"
    links:
      - mysql-slave

  mysql-slave:
    image: mysql:5.7
    container_name: mysql-slave
    environment:
      - MYSQL_ROOT_PASSWORD=root
    ports:
      - "3308:3306"
    volumes:
      - "./mysql/slave/my.cnf:/etc/my.cnf"
      - "./mysql/slave/data:/var/lib/mysql"

```

2. 配置master配置文件my.cnf

```
[mysqld]
# [必须]启用二进制日志
log-bin=mysql-bin 
# [必须]服务器唯一ID，默认是1，一般取IP最后一段  
server-id=1
## 复制过滤：也就是指定哪个数据库不用同步（mysql库一般不同步）
binlog-ignore-db=mysql
```

3. 配置slave配置文件my.cnf
 
```
[mysqld]
# [必须]服务器唯一ID，默认是1，一般取IP最后一段  
server-id=2
```

4. 启动docker-compose，创建docker镜像文件

```docker
docker-compose -f docker-compose-mysql-cluster.yml up -d
```

`docker ps`查看进程，可以看到2个实例已启动。

```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
1f4ad96b4d5e        mysql:5.7           "docker-entrypoint.s…"   48 seconds ago      Up 46 seconds       33060/tcp, 0.0.0.0:3307->3306/tcp   mysql-master
8e2214aacc43        mysql:5.7           "docker-entrypoint.s…"   49 seconds ago      Up 47 seconds       33060/tcp, 0.0.0.0:3308->3306/tcp   mysql-slave
```


# 配置主从复制

1. 配置master

![](https://gitee.com/idea360/oss/raw/master/images/docker-mysql-master.png)

2. 配置slave

![](https://gitee.com/idea360/oss/raw/master/images/docker-mysql-slave.png)

这时候就可以运行一些 SQL 语句来验证同步服务是否正常了。 


# 验证主从复制

1. master创建db

![](https://gitee.com/idea360/oss/raw/master/images/mysql-master-create-db.png)

2. 查看slave是否同步创建

![](https://gitee.com/idea360/oss/raw/master/images/mysql-slave-sync-db.png)

由结果可知，已完成MySQL主从复制环境的搭建。

# 读写分离

MySQL主从复制是其自己的功能，实现读写分离就得依靠其他组件了，比如`sharding-jdbc`。但是`sharding-jdbc`只是实现读写分离，本身的权限控制还是需要MySQL这边来配置的。

1. 配置master账户及权限

创建帐号并授予读写权限

```mysql
CREATE USER 'master'@'%' IDENTIFIED BY 'Password123';
GRANT select,insert,update,delete ON *.* TO 'master'@'%';
flush privileges;
```

![](https://gitee.com/idea360/oss/raw/master/images/mysql-master-create-user.png)


2. 配置slave账户及权限

创建帐号并授予只读权限

```mysql
use mysql;
CREATE USER 'slave'@'%' IDENTIFIED BY 'Password123';
GRANT select ON *.* TO 'slave'@'%';
FLUSH PRIVILEGES;
```

![](https://gitee.com/idea360/oss/raw/master/images/mysql-slave-create-user.png)

# 最后

这篇文章以搭建环境为主，后续会继续完善故障转移、分库分表、数据平滑迁移等相关演练。菜鸟博客，不尽完善，希望大家不吝赐教。同时欢迎大家关注小生的公众号【当我遇上你】。




