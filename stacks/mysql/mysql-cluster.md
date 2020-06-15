# General_log 详解

开启 general log 将所有到达MySQL Server的SQL语句记录下来。
相关参数一共有3：general_log、log_output、general_log_file

``` bash
show variables like 'general_log';  -- 查看日志是否开启
set global general_log=on; -- 开启日志功能
```

https://devopscube.com/setup-mysql-master-slave-replication/