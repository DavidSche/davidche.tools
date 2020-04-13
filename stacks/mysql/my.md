# General_log 详解

开启 general log 将所有到达MySQL Server的SQL语句记录下来。
相关参数一共有3：general_log、log_output、general_log_file

``` bash
show variables like 'general_log';  -- 查看日志是否开启
set global general_log=on; -- 开启日志功能
```

``` bash
show variables like 'general_log_file';  -- 看看日志文件保存位置
set global general_log_file='tmp/general.lg'; -- 设置日志文件保存位置
```

``` bash
show variables like 'log_output';  -- 看看日志输出类型  table或file
set global log_output='table'; -- 设置输出类型为 table
set global log_output='file';   -- 设置输出类型为file
```

2.开启数据库general_log步骤
先执行sql指令：show variables like ‘%log%’;

3.开启binlog日志
查看binlog开启状态：

``` bash
mysql> show variables like 'log_bin';

```

``` ini
log_bin=ON  
log_bin_basename=/var/lib/mysql/mysql-bin  
log_bin_index=/var/lib/mysql/mysql-bin.index  
```



--------

# How to Allow Remote Connections to MySQL Database Server

Posted Sep 11, 2019

CONTENTS

- Configuring MySQL Server
- Granting Access to a User from a Remote Machine
- Configuring Firewall
- Iptables
- UFW
- FirewallD
- Verifying the Changes
- Conclusion

By default, the MySQL server listens for connections only from localhost, which means it can be accessed only by applications running on the same host.

However, in some situations, it is necessary to access the MySQL server from remote location. For example, when you want to connect to the remote MySQL server from your local system, or when using a multi-server deployment where the application is running on a different machine from the database server. One option would be to access the MySQL server through SSH Tunnel and another is to configure the MySQL server to accept remote connections.

In this guide, we will go through the steps necessary to allow remote connections to a MySQL server. The same instructions apply for MariaDB.

Configuring MySQL Server
The first step is to set the MySQL server to listen on a specific IP address or all IP addresses on the machine.

If the MySQL server and clients can communicate with each other over a private network, then the best option is to set the MySQL server to listen only on the private IP. Otherwise, if you want to connect to the server over a public network set the MySQL server to listen on all IP addresses on the machine.


To do so, you need to edit the MySQL configuration file and add or change the value of the bind-address option. You can set a single IP address and IP ranges. If the address is 0.0.0.0, the MySQL server accepts connections on all host IPv4 interfaces. If you have IPv6 configured on your system, then instead of 0.0.0.0, use ::.

The location of the MySQL configuration file differs depending on the distribution. In Ubuntu and Debian the file is located at /etc/mysql/mysql.conf.d/mysqld.cnf, while in Red Hat based distributions such as CentOS, the file is located at /etc/my.cnf.


Open the file with your text editor:

sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
Search for a line that begins with bind-address and set its value to the IP address on which a MySQL server should listen.

By default, the value is set to 127.0.0.1 (listens only in localhost).

In this example, we'll set the MySQL server to listen on all IPv4 interfaces by changing the value to 0.0.0.0

mysqld.cnf
bind-address           = 0.0.0.0
# skip-networking
Copy
If there is a line containing skip-networking, delete it or comment it out by adding # at the beginning of the line.


In MySQL 8.0 and higher, the bind-address directive may not be present. In this case, add it under the [mysqld] section.

Once done, restart the MySQL service for changes to take effect. Only root or users with sudo privileges can restart services.

To restart the MySQL service on Debian or Ubuntu, type:

sudo systemctl restart mysql
On RedHat based distributions like CentOS to restart the service run:


sudo systemctl restart mysqld
Granting Access to a User from a Remote Machine
The next step is to allow access to the database to the remote user.

Log in to the MySQL server as the root user by typing:

sudo mysql
If you are using the old, native MySQL authentication plugin to log in as root run the command below and enter the password when prompted:

mysql -uroot -p
From inside the MySQL shell, use the GRANT statement to grant access for the remote user.

GRANT ALL ON database_name.* TO user_name@'ip_address' IDENTIFIED BY 'user_password';
Where:


database_name is the name of the database that the user will connect to.
user_name is the name od the MySQL user.
ip_address is the IP address from which the user will connect. Use % to allow the user to connect from any IP address.
user_password is the user password.
For example, to grant access to a database dbname to a user named foo with password my_passwd from a client machine with IP 10.8.0.5, you would run:


GRANT ALL ON dbname.* TO foo@'10.8.0.5' IDENTIFIED BY 'my_passwd';
Configuring Firewall
The last step is to configure your firewall to allow traffic on port 3306 (MySQL default port) from the remote machines.

### Iptables

If you are using iptables as your firewall, the command bellow will allow access from any IP address on the Internet to the MySQL port. This is very insecure.

```
sudo iptables -A INPUT -p tcp --destination-port 3306 -j ACCEPT
```

Allow access from a specific IP address:

```

sudo iptables -A INPUT -s 10.8.0.5 -p tcp --destination-port 3306 -j ACCEPT
```


### UFW
UFW is the default firewall tool in Ubuntu. To allow access from any IP address on the Internet (very insecure) run:

sudo ufw allow 3306/tcp
Allow access from a specific IP address:

sudo ufw allow from 10.8.0.5 to any port 3306
FirewallD
FirewallD is the default firewall management tool in CentOS. To allow access from any IP address on the Internet (very insecure) type:

```
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload
```

To allow access from a specific IP address on a specific port, you can either create a new FirewallD zone or use a rich rule. Well create a new zone named mysqlzone:
```
sudo firewall-cmd --new-zone=mysqlzone --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --permanent --zone=mysqlzone --add-source=10.8.0.5/32
sudo firewall-cmd --permanent --zone=mysqlzone --add-port=3306/tcp
sudo firewall-cmd --reload
```

Verifying the Changes
To verify that the remote user can connect to the MySQL server run the following command:

```
mysql -u user_name -h mysql_server_ip -p
```

Where user_name is the name of the user you granted access to and mysql_server_ip is the IP address of the host where the MySQL server runs.

If everything is setup up correctly, you will be able to login to the remote MySQL server.

If you get an error like below, then either the port 3306 is not open, or the MySQL server is not listening on the IP address.

ERROR 2003 (HY000): Can't connect to MySQL server on '10.8.0.5' (111)"
The error below is indicating that the user you are trying to log in doesn't have permissions to access the remote MySQL server.

"ERROR 1130 (HY000): Host ‘10.8.0.5’ is not allowed to connect to this MySQL server" 
Conclusion
MySQL, the most popular open-source database server by default, listens for incoming connections only on localhost.

To allow remote connections to a MySQL server, you need to perform the following steps:

Configure the MySQL server to listen on all or a specific interface.
Grant access to the remote user.
Open the MySQL port in your firewall.
If you have questions feel free to leave a comment below.


