systemctl status systemd-timesyncd

systemctl restart systemd-timesyncd


```
# systemctl start ntpd
# systemctl enable ntpd
# systemctl status ntpd

```
查看当前系统时间、时区

```shell


复制代码
$ timedatectl 
      Local time: Thu 2018-10-11 13:03:04 CST
  Universal time: Thu 2018-10-11 05:03:04 UTC
        RTC time: Thu 2018-10-11 01:17:11
       Time zone: Asia/Shanghai (CST, +0800)
     NTP enabled: no
NTP synchronized: no
 RTC in local TZ: no
      DST active: n/a

$ timedatectl status
      Local time: Thu 2018-10-11 13:03:09 CST
  Universal time: Thu 2018-10-11 05:03:09 UTC
        RTC time: Thu 2018-10-11 01:17:16
       Time zone: Asia/Shanghai (CST, +0800)
     NTP enabled: no
NTP synchronized: no
 RTC in local TZ: no
      DST active: n/a

```

```shell
启用|停用自动同步时间
$ timedatectl set-ntp yes|no

# 上面的命令其实是启用、停用时间服务器，若安装了chrony服务，则等同于对该服务启停，若只安装了ntp，则是对ntp服务启停。
# 对chrony服务启停
$ systemctl start|stop chronyd
# 对ntp服务启停
$ systemctl start|stop ntpd

```

同步系统时间到硬件时间

```shell
复制代码
# 方法1：不建议硬件时间随系统时间变化
# 设置硬件时间随系统时间变化
$ timedatectl set-local-rtc 1
# 设置硬件时间不随系统时间变化
$ timedatectl set-local-rtc 0

# 方法2：
$ hwclock --systohc
```

设置时间

```shell


复制代码
# 方法1：使用timedatectl，NTP enabled: yes时，使用了NTP服务器自动同步时间，若坚持要手动修改时间，先timedatectl set-ntp no。
# 设置日期和时间
$ timedatectl set-time '2018-10-11 09:00:00'
# 设置日期
$ timedatectl set-time '2018-10-11'
# 设置时间
$ timedatectl set-time '09:00:00'

# 方法2：使用date
$ date -s '2018-10-11 09:00:00'
```

设置时区

```shell


复制代码
# 方法1：
# 将时区设置为上海
$ timedatectl set-timezone Asia/Shanghai

# 方法2：
# 直接修改符号链接
$ rm /etc/localtime
$ ln -s ../usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```