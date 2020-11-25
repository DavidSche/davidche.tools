# Docker之Mysql主从

## 准备好文件

### docker-compose-mysql.yml

```yml
version: '3'
services:
  mysql-master:
    image: mysql:5.7
    container_name: mysql-master
    environment:
      - MYSQL_ROOT_PASSWORD=root
    ports:
      - "3306:3306"
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
      - "3406:3306"
    volumes:
      - "./mysql/slave/my.cnf:/etc/my.cnf"
      - "./mysql/slave/data:/var/lib/mysql"

```



### docker/mysql/master/my.cnf

```conf
[mysqld]
# [必须]启用二进制日志
log-bin=mysql-bin 
# [必须]服务器唯一ID，默认是1，一般取IP最后一段  
server-id=1
## 复制过滤：也就是指定哪个数据库不用同步（mysql库一般不同步）
binlog-ignore-db=mysql
```



### docker/mysql/slave/my.cnf

```conf
[mysqld]
# [必须]服务器唯一ID，默认是1，一般取IP最后一段  
server-id=2
```



## 启动容器

```shell
docker-compose -f docker-compose-mysql.yml up -d
```



## MySQL 主从设置

### 进入 MySQL Master

#### 进入docker容器

```
docker exec -it mysql-master bash
# 连接MySQL Server
mysql -uroot -p
```

#### 创建同步用户

```sql
create user repl;
```

#### 设置同步用户的权限

```sql
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'repl';
```

#### 显示 master 状态

```sql
mysql> show master status;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000003 |      635 |              | mysql            |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```

记住 `File` 和 `Position` 里面的值，比如 `mysql-bin.000003 和 `635`。



### 进入 MySQL Slave

#### 进入docker容器

```
docker exec -it mysql-slave bash
```

#### 设置连接 Master 的参数

记得修改 `MASTER_LOG_FILE` 和 `MASTER_LOG_POS` 的值。

```sql
CHANGE MASTER TO
    MASTER_HOST='mysql-master',
    MASTER_USER='repl',
    MASTER_PASSWORD='repl',
    MASTER_LOG_FILE='mysql-bin.000003',
    MASTER_LOG_POS=635;
```

#### 启动 slave 服务

```sql
start slave;
```

#### 显示 slave 状态

```sql
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: mysql-master
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000004
          Read_Master_Log_Pos: 405
               Relay_Log_File: mysqld-relay-bin.000002
                Relay_Log_Pos: 283
        Relay_Master_Log_File: mysql-bin.000004
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 405
              Relay_Log_Space: 457
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
                  Master_UUID: fb3ba1b4-2fd5-11ea-a01e-0242ac160005
             Master_Info_File: /var/lib/mysql/master.info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
           Master_Retry_Count: 86400
                  Master_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Master_SSL_Crl:
           Master_SSL_Crlpath:
           Retrieved_Gtid_Set:
            Executed_Gtid_Set:
                Auto_Position: 0
1 row in set (0.00 sec)
```

当 `Slave_IO_Running` 和 `Slave_SQL_Running` 为 `Yes` 时，说明同步服务正常。

这时候就可以运行一些 `SQL` 语句来验证同步服务是否正常了。



### 验证主从复制

#### master创建db

```
mysql> create database test;
Query OK, 1 row affected (0.01 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
5 rows in set (0.00 sec)
```

#### slave查看db是否同步

```
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
5 rows in set (0.01 sec)
```

