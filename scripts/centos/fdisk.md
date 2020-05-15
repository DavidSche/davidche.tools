# 挂载硬盘常见操作
$ sudo fdisk -l
查看硬盘信息

## 创建 XFS格式分区

先准备一个分区来创建XFS。假设你的分区在/dev/sdb,如下：

$ sudo fdisk /dev/sda2 

输入n新建一个分区，输入p 建立分区，输入分区编号 1
然后一路默认
输入w保存

##  格式化分区

假设此创建的分区叫/dev/sdb1。

接下来，格式化分区为XFS，使用mkfs.xfs命令。如果已有其他文件系统创建在此分区，必须加上"-f"参数来覆盖它。

$ sudo mkfs.xfs -f /dev/sda1
$ sudo mkfs.xfs -f /dev/sda2


至此你已经准备好格式化后分区来挂载。假设 /home/cqy 是XFS本地挂载点。使用下述命令挂载：

$ sudo mount -t xfs /dev/sda2 /home/cqy  

## 验证XFS挂载是否成功：

$ df -Th /home/cqy

## 自动挂载

如果你想要启动时自动挂载XFS分区在/storage上，加入下列行到/etc/fstab：0

/dev/sdb1 /home/cqy   xfs defaults 0 0
/dev/sda2 /home/cqy                              xfs     defaults        0 0
 

mount 命令------记一次数据盘挂载mount: wrong fs type, bad option, bad superblock on /dev/vdb1的排查

https://yq.aliyun.com/articles/120155


————————————————
版权声明：本文为CSDN博主「MarxYong」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/marxyong/article/details/88703416