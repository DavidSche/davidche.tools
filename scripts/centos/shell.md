CQY_2019@redis$cluster

#  centOS 禁用IPv6

1 进入 vi /etc/sysctl.conf

后面添加

```bash
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```
 

执行生效：

``` bash
sysctl -p
```

## centos 查看所有运行中的服务ip和端口信息

```bash
netstat -tunpl
```

## centos 6.5 查看、开启，关闭 端口 (iptables)

 
查看所有端口
 
netstat -ntlp
 
1、开启端口（以80端口为例）
 

方法一：

```bash
         /sbin/iptables -I INPUT -p tcp --dport 端口号 -j ACCEPT   写入修改
 
         /etc/init.d/iptables save   保存修改
 
        service iptables restart    重启防火墙，修改生效
```
 
       方法二：

``` 
       vi /etc/sysconfig/iptables  打开配置文件加入如下语句:
 
       -A INPUT -p tcp -m state --state NEW -m tcp --dport 端口号 -j ACCEPT   重启防火墙，修改完成
``` 
 
2、关闭端口
 
     方法一：
``` 
         /sbin/iptables -I INPUT -p tcp --dport 端口号 -j DROP   写入修改 
         /etc/init.d/iptables save   保存修改 
        service iptables restart    重启防火墙，修改生效
``` 
       方法二：

``` 
       vi /etc/sysconfig/iptables  打开配置文件加入如下语句: 
       -A INPUT -p tcp -m state --state NEW -m tcp --dport 端口号 -j DROP   重启防火墙，修改完成
``` 
 
3、查看端口状态

``` 
      /etc/init.d/iptables status
```


##  mysql 远程访问 

```
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'massrep2019' WITH GRANT OPTION;
 
FLUSH   PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY 'massrep2019';  

flush privileges;
```

------

## mysql 初始化

登录数据库

        注意：初始化时随机生成了密码，可以去/mysql下的mysql.log 里查看

     【root】# cat mysql.log | grep password
               2018-09-12T06:28:43.374399Z 1 [Note] A temporary password is generated for root@localhost: dHuSP!;y.3ef
       #临时密码登录数据库  （会提示要你修改密码）

                /usr/local/mysql57/bin/mysql -uroot  -p "dHuSP!;y.3ef"  

      修改密码方法：（建议方法二）

       方法一：

           mysql>update mysql.user set authentication_string=password("新密码");
           mysql>flush privileges;     

       方法二：

            mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '新密码';  
            mysql> flush privileges;
忘记MySQL的root密码如何登录

       1、在配置文件my.cnf的mysqld端下加skip-grant-tables跳过密码认证

		[mysqld]
		skip-grant-tables=1

等价于

         [mysqld]
         skip-grant-tables

       2、重启服务或重装配置文件

            /usr/local/mysql57/support-files/mysql.server  restart

           /usr/local/mysql57/support-files/mysql.server reload   

       3、无密码登录       

          /usr/local/mysql57/bin/mysql 

      4、无密码登陆后修改密码

            mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY '新密码';  
            mysql> flush privileges;

     5、删除配置文件里skip-grant-tables （重点：不删除，密码不会生效）

           #skip-grant-tables

    6、重启服务，或加载配置文件就生效了

 
设置无密码登录

     #修改配置文件my.cnf的client段，添加如下参数

           password=123123   #你设置密码

     在登录时候就不用输入：mysql -uroot -p 输入密码登录数据库了
授权其他主机能登录mysql数据库

     #授权10.10.10.1主机用root用户，密码为123123 登录数据库         

      grant all on *.* to "root"@"10.10.10.1" identified by "123123"；

     #授权所有主机可以用root用户远程登陆 ，密码是root

     grant all privileges on *.* to 'root'@'%' identified by 'root' with grant option；



（1）修改validate_password_policy参数值为0（1为开启复杂策略）
注意：此参数（policy）必须优先修改，因为policy策略不修改为0会影响下面的length参数。


------

## mysql 密码强度

（1）修改validate_password_policy参数值为0（1为开启复杂策略）
注意：此参数（policy）必须优先修改，因为policy策略不修改为0会影响下面的length参数。

set global validate_password_policy=0;

（2）修改validate_password_length参数值为1

set global validate_password_length=1;

最后执行修改密码测试：

alter user 'root'@'localhost' identified by '@wjb13191835106';
 
validate_password_policy取值：
Policy 	Tests Performed
0 or LOW 	Length
1 or MEDIUM 	Length; numeric, lowercase/uppercase, and special characters
2 or STRONG 	Length; numeric, lowercase/uppercase, and special characters; dictionary file

------
防火墙有关

firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --reload

------

使用“ps -e|grep mysql”命令，查看mysql程序的对应的pid号。结果如下图：


使用“kill -9 2891”命令，可以结束掉mysqld_safe进程。

使用"killall mysqld"命令，可以杀掉所有已mysqld命名的进程。

------
MySQL数据库使用命令行备份|MySQL数据库备份命令

例如：

数据库地址：127.0.0.1

数据库用户名：root

数据库密码：pass

数据库名称：myweb

 

备份数据库到D盘跟目录

mysqldump -h127.0.0.1 -uroot -ppass myweb > d:/backupfile.sql

 

备份到当前目录 备份MySQL数据库为带删除表的格式，能够让该备份覆盖已有数据库而不需要手动删除原有数据库

mysqldump --add-drop-table -h127.0.0.1 -uroot -ppass myweb > backupfile.sql

 

直接将MySQL数据库压缩备份  备份到D盘跟目录

mysqldump -h127.0.0.1 -uroot -ppass myweb | gzip > d:/backupfile.sql.gz

 

备份MySQL数据库某个(些)表。此例备份table1表和table2表。备份到linux主机的/home下
mysqldump -h127.0.0.1 -uroot -ppass myweb table1 table2 > /home/backupfile.sql

 

同时备份多个MySQL数据库

mysqldump -h127.0.0.1 -uroot -ppass --databases myweb myweb2 > multibackupfile.sql

 

仅仅备份数据库结构。同时备份名为myweb数据库和名为myweb2数据库

mysqldump --no-data -h127.0.0.1 -uroot -ppass --databases myweb myweb2 > structurebackupfile.sql

 

备份服务器上所有数据库

mysqldump --all-databases -h127.0.0.1 -uroot -ppass > allbackupfile.sql

 

还原MySQL数据库的命令。还原当前备份名为backupfile.sql的数据库

mysql -h127.0.0.1 -uroot -ppass myweb < backupfile.sql

 

还原压缩的MySQL数据库

gunzip < backupfile.sql.gz | mysql -h127.0.0.1 -uroot -ppass myweb

 

将数据库转移到新服务器。此例为将本地数据库myweb复制到远程数据库名为serweb中，其中远程数据库必须有名为serweb的数据库

mysqldump -h127.0.0.1 -uroot -ppass myweb | mysql --host=***.***.***.*** -u数据库用户名 -p数据库密码 -C serweb


------

用MySQL的source命令导入SQL文件实战记录。

进入 CMD
执行 mysql -uroot -p 输入密码后进入 MySQL 命令提示符
依次执行：

```
use XXXdatabase;
set charset utf8;
source d:/xxx.sql;
```

本以为这样就可以挂机等待 sql 文件如期导入了，但是事与愿违，当过一段时间在打开时发现命令行提示链接超时,等待重新链接。
这时候需要再执行以下 sql：

```
set global max_allowed_packet=100000000;
set global net_buffer_length=100000;
set global interactive_timeout=28800000;
set global wait_timeout=28800000;
```

------

ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass';

UPDATE mysql.user
    SET authentication_string = PASSWORD('MyNewPass'), password_expired = 'N'
    WHERE User = 'root' AND Host = 'localhost';
FLUSH PRIVILEGES;

-------

第一个是全拼，第二个是第一个的缩写

mysql --host=localhost --user=myname --password=password mydb

mysql -h localhost -u myname -ppassword mydb

------

sudo mysqld --skip-grant-tables  --skip-networking &

--skip-grant-tables：此选项会让MySQL服务器跳过验证步骤，允许所有用户以匿名的方式，无需做密码验证直接登陆MySQL服务器，并且拥有所有的操作权限。

--skip-networking：此选项会关门MySQL服务器的远程连接。这是因为以--skip-grant-tables方式启动MySQL服务器会有很大的安全隐患，为了降低风险，需要禁止远程客户端的连接。

------

https://tecadmin.net/install-mysql-on-centos-redhat-and-fedora/


------

Centos7开放及查看端口
1、开放端口

firewall-cmd --zone=public --add-port=5672/tcp --permanent   # 开放5672端口

firewall-cmd --zone=public --remove-port=5672/tcp --permanent  #关闭5672端口

firewall-cmd --reload   # 配置立即生效


2、查看防火墙所有开放的端口

firewall-cmd --zone=public --list-ports


3.、关闭防火墙

如果要开放的端口太多，嫌麻烦，可以关闭防火墙，安全性自行评估

systemctl stop firewalld.service


4、查看防火墙状态

 firewall-cmd --state

 查看防火墙zone 

 firewall-cmd --list-all-zones

删除zone 删除以下目录的zonename.xml

/etc/firewalld/zones 


通过zone 设置防火墙信息

sudo firewall-cmd --new-zone=mysqlzone --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --permanent --zone=mysqlzone --add-source=10.8.0.5/32
sudo firewall-cmd --permanent --zone=mysqlzone --add-source=192.168.6.0/24
sudo firewall-cmd --permanent --zone=mysqlzone --add-source=192.168.16.0/24
sudo firewall-cmd --permanent --zone=mysqlzone --add-source=192.168.18.0/24
sudo firewall-cmd --permanent --zone=mysqlzone --add-source=192.168.231.0/24
sudo firewall-cmd --permanent --zone=mysqlzone --add-port=3307/tcp
sudo firewall-cmd --reload

1.添加公开端口,所有的IP地址都能访问(安全性低)
firewall-cmd --zone=public --add-port=5002/tcp --permanent
2.删除公开端口
firewall-cmd --zone=public --remove-port=5002/tcp --permanent
3.添加可以访问的IP地址
firewall-cmd --permanent --add-rich-rule 'rule family=ipv4 source address=192.168.0.3 port port=32768 protocol=tcp accept'
4.删除规则
firewall-cmd --permanent --remove-rich-rule 'rule family=ipv4 source address=192.168.0.3 port port=56800 protocol=tcp accept'


5、查看监听的端口

netstat -lnpt


PS:centos7默认没有 netstat 命令，需要安装 net-tools 工具，yum install -y net-tools


6、检查端口被哪个进程占用

netstat -lnpt |grep 5672


7、查看进程的详细信息

ps 6832


8、中止进程

kill -9 6832

------

linux下查询当前所有连接的ip

netstat -ntu , 找出通过 tcp 和 udp 连接服务器的 IP 地址列表 :

netstat -ntu | grep tcp

netstat -ntu | grep 3306

也可以使用 egrep 过滤多个条件 # netstat -ntu | egrep ‘tcp|udp’

------

### ----常见的权限表示形式有

``` bash
-rw------- (600) 只有拥有者有读写权限。
-rw-r--r-- (644) 只有拥有者有读写权限；而属组用户和其他用户只有读权限。
-rwx------ (700) 只有拥有者有读、写、执行权限。
-rwxr-xr-x (755) 拥有者有读、写、执行权限；而属组用户和其他用户只有读、执行权限。
-rwx--x--x (711) 拥有者有读、写、执行权限；而属组用户和其他用户只有执行权限。
-rw-rw-rw- (666) 所有用户都有文件读、写权限。
-rwxrwxrwx (777) 所有用户都有读、写、执行权限。

```

[source](https://www.cnblogs.com/monjeo/p/12191673.html)