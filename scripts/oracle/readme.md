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
