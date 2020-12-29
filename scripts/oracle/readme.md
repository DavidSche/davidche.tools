# DevOps 环境信息

## DevOps Tools            

相关工具的处理

- GitLab
- Docker Registry (registry+ui)
- Jenkins
- wiki (wiki+postgresql)
- pm (mysql)

- https://vuepress.vuejs.org/guide/#why-not 

-------

## Agent

### Purpose

CentOS上Oracle服务启动


设置环境变量

source /home/oracle/.bash_profile

```
export PATH=$PATH:$HOME/bin
#Oracle Environment
export ORACLE_HOME=/home/oracle/oracle/product/11.2.0/dbhome_1
export ORACLE_BASE=/home/oracle/oracle
export ORACLE_SID=oracle
export ORACLE_TERM=xterm
export NLS_LANG=AMERICAN
export ORA_NLS33=$ORACLE_HOME/ocommon/nls/admin/data
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib:/usr/local/lib
export JAVA_HOME=/opt/java/jdk1.8.0_14/
export PATH=$JAVA_HOME:$PATH:$ORACLE_HOME/bin
alias l='ls -lrt'

```

1.切换用户

su oracle

2.查看监听器

lsnrctl status

3.启动监听器

lsnrctl start

4.连接

sqlplus /nolog

conn / as sysdba

startup

###  Deployment


-------
Installation
docker pull sath89/oracle-ee-11g
Run with 8080 and 1521 ports opened:

docker run -d -p 8080:8080 -p 1521:1521 sath89/oracle-ee-11g
Run with data on host and reuse it:

docker run -d -p 8080:8080 -p 1521:1521 -e WEB_CONSOLE=false --restart=always --name=oracle11g -v /my/oracle/data:/u01/app/oracle sath89/oracle-ee-11g 


docker run -d -p 1521:1521 -e WEB_CONSOLE=false --restart=always --name=oracle11g -v /my/oracle/data:/u01/app/oracle sath89/oracle-ee-11g


Run with Custom DBCA_TOTAL_MEMORY (in Mb):

docker run -d -p 8080:8080 -p 1521:1521 -v /my/oracle/data:/u01/app/oracle -e DBCA_TOTAL_MEMORY=1024 sath89/oracle-11g
Connect database with following setting:

```

hostname: 192.168.6.201
port: 1521
sid: EE
service name: EE.oracle.docker
username: system
password: oracle

```

To connect using sqlplus:

sqlplus system/oracle@//localhost:1521/EE.oracle.docker
Password for SYS & SYSTEM:

oracle
Apex install up to v 5.*

docker run -it --rm --volumes-from ${DB_CONTAINER_NAME} --link ${DB_CONTAINER_NAME}:oracle-database -e PASS=YourSYSPASS sath89/apex install
Details could be found here: https://github.com/MaksymBilenko/docker-oracle-apex

Connect to Oracle Enterprise Management console with following settings:

```
http://localhost:8080/em
user: sys
password: oracle
connect as sysdba: true

```
By Default web management console is enabled. To disable add env variable:

```
docker run -d -e WEB_CONSOLE=false -p 1521:1521 -v /my/oracle/data:/u01/app/oracle sath89/oracle-11g

```
#You can Enable/Disable it on any time
Start with additional init scripts or dumps:

```
docker run -d -p 1521:1521 -v /my/oracle/data:/u01/app/oracle -v /my/oracle/init/SCRIPTSorSQL:docker-entrypoint-initdb.d sath89/oracle-11g
```


By default Import from docker-entrypoint-initdb.d enabled only if you are initializing database(1st run). If you need to run import at any case - add -e IMPORT_FROM_VOLUME=true In case of using DMP imports dump file should be named like ${IMPORT_SCHEME_NAME}.dmp User credentials for imports are ${IMPORT_SCHEME_NAME}/${IMPORT_SCHEME_NAME}

If you have an issue with database init like DBCA operation failed, please reffer to this issue

TODO LIST

 - Web management console HTTPS port
 - Add functionality to run custom scripts on startup, for example User creation
 - Add Parameter that would setup processes amount for database (Currently by default processes=300)
 - Spike with clustering support
 - Spike with DB migration from 11g
 - In case of any issues please post it here.






