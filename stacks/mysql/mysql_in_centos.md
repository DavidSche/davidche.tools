# In MySQL On Centos  详解

 **1、设置centos 环境，关闭selinux**
 
 **检查 SELinux Status 状态**
 
   ```shell script
 # sestatus

 SELinux status:                 enabled
 SELinuxfs mount:                /sys/fs/selinux
 SELinux root directory:         /etc/selinux
 Loaded policy name:             targeted
 Current mode:                   enforcing
 Mode from config file:          enforcing
 Policy MLS status:              enabled
 Policy deny_unknown status:     allowed
 Max kernel policy version:      31
 You can see from the output above that SELinux is enabled and set to enforcing mode.
```

 
 **临时禁用 SELinux**
 
 You can temporarily change the SELinux mode from targeted to permissive with the following command:
 
 ```shell script
# sudo setenforce 0
```

 **永久禁用 SELinux**
 
 打开 /etc/selinux/config 文件并设置 SELINUX mod 为 disabled:
 
 /etc/selinux/config
 
 ```shell script
 # This file controls the state of SELinux on the system.
 # SELINUX= can take one of these three values:
 #       enforcing - SELinux security policy is enforced.
 #       permissive - SELinux prints warnings instead of enforcing.
 #       disabled - No SELinux policy is loaded.
 SELINUX=disabled
 # SELINUXTYPE= can take one of these two values:
 #       targeted - Targeted processes are protected,
 #       mls - Multi Level Security protection.
 SELINUXTYPE=targeted                     
 ```

 保存文件并重启 CentOS 系统:
 
```shell script
 sudo shutdown -r now
```

 一旦重启完成, 就可以用以下命令验证:

```shell script
 sestatus

SELinux status:                 disabled

```

https://linuxize.com/post/how-to-disable-selinux-on-centos-7/

 防火墙设置
 
 **FirewallD**
 
 开放端口
 
```shell script
 sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
 sudo firewall-cmd --reload
```

限制IP访问

```shell script
 sudo firewall-cmd --new-zone=mysqlzone --permanent
 sudo firewall-cmd --reload
 sudo firewall-cmd --permanent --zone=mysqlzone --add-source=10.8.0.5/32
 sudo firewall-cmd --permanent --zone=mysqlzone --add-port=3306/tcp
 sudo firewall-cmd --reload

```

 **2、安装MySQL**
 
 - **第一步 – Enable MySQL Repository**
 
 ```shell script
-- On CentOS and RHEL 7 -- 
yum localinstall https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm

```

- **第一步 – Install MySQL 5.7 Server**
 
On CentOS and RHEL 7/6
```shell script
yum install mysql-community-server
```

查看root 临时密码

```shell script
grep 'A temporary password' /var/log/mysqld.log |tail -1

2017-03-30T02:57:10.981502Z 1 [Note] A temporary password is generated for root@localhost: Nm(!pKkkjo68e

```
 Start MySQL Service
After installing rpms use following command to start MySQL Service.
```shell script
service mysqld start
```

**Step – Login to MySQL**

```shell script
mysql -h localhost -u root -p 
/* 修改密码 */
mysql> SET PASSWORD = PASSWORD('yVdtgwHC8/m2');
/* 查看密码规则 */
mysql> SHOW VARIABLES LIKE 'validate_password%';
/* 设置密码规则--临时--永久修改/etc/my.cnf */
mysql> SET GLOBAL validate_password_policy = 0;
/* 设置密码 */
mysql> SET PASSWORD = PASSWORD('hjroot2019');
/* 开放远程访问 */
mysql> GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'hjroot2019'with grant option;
/* 重新加载权限 */
mysql> FLUSH PRIVILEGES;




```
CQY@mass2019

```shell script
mysql -h localhost -u root -p 
/* 修改密码 */
mysql> SET PASSWORD = PASSWORD('yVdtgwHC8/m2');
/* 查看密码规则 */
mysql> SHOW VARIABLES LIKE 'validate_password%';
/* 设置密码规则--临时--永久修改/etc/my.cnf */
mysql> SET GLOBAL validate_password_policy = 0;
/* 设置密码 */
mysql> SET PASSWORD = PASSWORD('CQY@mass2019');
/* 开放远程访问 */
mysql> GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'CQY@mass2019'with grant option;
/* 重新加载权限 */
mysql> FLUSH PRIVILEGES;

```

https://tecadmin.net/install-mysql-5-7-centos-rhel/

https://www.howtoforge.com/tutorial/how-to-install-mysql-57-on-linux-centos-and-ubuntu/


 3、设置MySQL
 
 ```shell script
 mysql -h localhost -u root -p 
 
 mysql> SET PASSWORD = PASSWORD('hjgnjdl!ha6cG');
 
 
 mysql> SHOW VARIABLES LIKE 'validate_password%';
 
 mysql> SET GLOBAL validate_password_policy = 0;
 
 mysql> SET PASSWORD = PASSWORD('hjroot2019');
 mysql> GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'hjroot2019'with grant option;
 mysql> FLUSH PRIVILEGES;
 
 /* CREATE NEW DATABASE */
 mysql> CREATE DATABASE mydb;
  
 /* CREATE MYSQL USER FOR DATABASE */
 mysql> CREATE USER 'db_user'@'localhost' IDENTIFIED BY 'password';
  
 /* GRANT Permission to User on Database */
 mysql> GRANT ALL ON mydb.* TO 'db_user'@'localhost';
  
 /* RELOAD PRIVILEGES */
 mysql> FLUSH PRIVILEGES;
 
 
 # mysql -V
 
 mysql  Ver 14.14 Distrib 5.7.17, for Linux (x86_64) using  EditLine wrapper\
 ```     

 4、设置密码

**修改 MySQL Password Policy Level**

```shell script
vi /etc/my.cnf
```
add 
```mysql.cnf

[mysqld]
validate_password_policy=LOW

```
```mysql
mysql> SET GLOBAL validate_password_policy=LOW;
 
Query OK, 0 rows affected (0.02 sec)

```

https://tecadmin.net/change-mysql-password-policy-level/

 

