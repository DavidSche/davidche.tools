# entos7 忘记密码

## 解决方式一

entos7采用的是grub2，和centos6.x进入单用户的方法不同。但是因为用的是真机环境无法截图，所以只是大概描述以下思路。

### init方法

1、centos7的grub2界面会有两个入口，正常系统入口和救援模式；

2、修改grub2引导

    在正常系统入口上按下"e"，会进入edit模式，搜寻ro那一行，以linux16开头的；

    把ro更改成rw；（把只读更改成可写）

    把rhgb quiet删除；（quiet模式没有代码行唰唰的走，可以删除）

    增加init=/bin/bash；（或init=/bin/bash,指定shell环境)

    按下ctrl+x来启动系统。

3、修改root密码

    #passwd                       #修改密码

    #touch /.autorelabel      #据说是selinux在重启后更新label

    #exec /sbin/init              #正常启动init进程

 
##  第二种

另外还有一种rd.break方法（尝试但不成功）

1、启动的时候，在启动界面，相应启动项，内核名称上按“e”；

2、进入后，找到linux16开头的地方，按“end”键到最后，输入rd.break，按ctrl+x进入；

3、进去后输入命令mount，发现根为/sysroot/，并且不能写，只有ro=readonly权限；

4、mount -o remount,rw /sysroot/，重新挂载，之后mount，发现有了r,w权限；

5、chroot /sysroot/ 改变根；

（1）echo redhat|passwd –stdin root 修改root密码为redhat，或者输入passwd，交互修改；

（2）还有就是先cp一份，然后修改/etc/shadow文件

6、touch /.autorelabel 这句是为了selinux生效

7、ctrl+d 退出

8、然后reboot

 

[root@chenghy ~]# vi /etc/pam.d/login

#将如下行：

session required /lib/security/pam_limits.so

#修改成：

session required /lib64/security/pam_limits.so




https://www.cnblogs.com/zxs-onestar/p/6247059.html


