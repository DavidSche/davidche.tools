# -bash 病毒木马的处理
参考文章
[https://blog.csdn.net/weixin_45284355/article/details/110728620](https://blog.csdn.net/weixin_45284355/article/details/110728620)
## 使用top命令查看进程占用情况

树形显示进程
```shell
# https://blog.51cto.com/11347436/2065138
ps -axjf

##通过管道显示前10个结果
ps -aux --sort -pcpu,+pmem| head -n 10

##根据内存使用来升序排序
ps -aux --sort -pmem| less

##根据用户过滤进程：
ps -u fy123


```



## 使用crontab -l 查看定时任务情况,如果存在，使用crontab -e 删除定时任务
查看行程序的符号链接
```shell
ls -l /proc/34783/exe   # 34783为当时进程号
lrwxrwxrwx 1 root root 0 Nov  5 13:04 /proc/34783/exe -> /usr/bin/-bash (deleted)
查看/etc/cron.hourly等目录下内容，发现都有个脚本sync
```

查看  /etc/cron.hourly/  /etc/cron.daily/ 等目录下是否存在 sync 的执行脚本，内容参考：
```shell
cd -- /usr/tmp/.systemd
mkdir -- .-bash
cp -f -- x86_64 .-bash/-bash
./.-bash/-bash -c
rm -rf -- .-bash

```

## kill 杀死相关进程，并清除病毒源头

## 删除相关文件的命令参考：

```shell
chattr -R -i /bin/sysdrr
rm -rf /bin/sysdrr
chattr -R -i /etc/cron.hourly/sync
rm -rf /etc/cron.hourly/sync
chattr -R -i /etc/cron.daily/sync
rm -rf /etc/cron.daily/sync
chattr -R -i /etc/cron.monthly/sync
rm -rf /etc/cron.monthly/sync
chattr -R -i /etc/cron.weekly/sync
rm -rf /etc/cron.weekly/sync

chattr -R -i /var/tmp
rm -rf /var/tmp

chattr -R -i /etc/cron.**/sync
rm -f /etc/cron.**/sync

```


参考做法

目前做过的操作：
1.防火墙阻止已知所有木马IP
2.删除所有木马文件
3.删除木马用户和定时任务
4.清除木马进程
5.取消该主机的dns解析（这个后续看情况可打开）

快速清理流程



假设的名字是wobprwmnqhzbve，如果top看不到，可以在/etc/init.d目录下面查看



1、首先锁定三个目录，不能让新文件产生

禁止该文件执行
```shell
chmod 000 /usr/bin/wobprwmnqhzbve
```

锁定
```shell
chattr +i /usr/bin
chattr +i /bin
chattr +i /tmp
```

2、锁定crontab文件，不让任何进程写入数据。
```shell
chattr +i /etc/crontab
```

3、删除定时任务及文件以及开机启动文件

删除定时任务及文件

```shell
rm -f /etc/init.d/wobprwmnqhzbve

rm -f /etc/rc#.d/连接文件

rm /etc/cron.hourly/gcc.sh

rm -rf /lib/libkill.so.6

rm -rf /lib/libkill.so
```
快速清理***流程

假设***的名字是nshbsjdy，如果top看不到，可以在/etc/init.d目录下面查看

1、首先锁定三个目录，不能让新***文件产生
```
chmod 000 /usr/bin/nshbsjdy
chattr +i /usr/bin
chattr +i /bin
chattr +i /tmp
```


2、删除定时任务及文件以及开机启动文件

删除定时任务及文件
```shell
rm -f /etc/init.d/nshbsjdy
rm -f /etc/rc#.d/*** 连接文件
```
