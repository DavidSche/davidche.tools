# 挂载硬盘常见操作
$ sudo fdisk -l
查看硬盘信息

## 创建 XFS格式分区

先准备一个分区来创建XFS。假设你的分区在/dev/sdb,如下：

$ sudo fdisk /dev/sda2 


输入p 
输入o

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
/dev/sda2 /home/cqy   xfs defaults 0 0
 

mount 命令------记一次数据盘挂载mount: wrong fs type, bad option, bad superblock on /dev/vdb1的排查

https://yq.aliyun.com/articles/120155


————————————————
版权声明：本文为CSDN博主「MarxYong」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/marxyong/article/details/88703416

--------

### Centos7.6 格式化分区 报错 /dev/sda3 --- No such file or directory

一个懵懂的年轻人 2020-03-19 15:23:47  437  收藏
分类专栏： Linux
版权
[root@localhost ~]# fdisk -l

Disk /dev/sda: 536.9 GB, 536870912000 bytes, 1048576000 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk label type: dos
Disk identifier: 0x000af3ce

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200   209715199   103808000   8e  Linux LVM
/dev/sda3       209715200  1048575999   419430400   83  Linux            //说明：此处sda3是新划分的分区

Disk /dev/mapper/centos-root: 53.7 GB, 53687091200 bytes, 104857600 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos-swap: 8455 MB, 8455716864 bytes, 16515072 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/centos-home: 44.1 GB, 44149243904 bytes, 86228992 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

[root@localhost ~]# mkfs.xfs /dev/sda3         //说明：使用mkfs.xfs命令格式化磁盘分区sda3
/dev/sda3: No such file or directory                
Usage: mkfs.xfs
/* blocksize */             [-b log=n|size=num]
/* metadata */             [-m crc=0|1,finobt=0|1,uuid=xxx]
/* data subvol */          [-d agcount=n,agsize=n,file,name=xxx,size=num,
                                        (sunit=value,swidth=value|su=num,sw=num|noalign),
                                        sectlog=n|sectsize=num
/* force overwrite */     [-f]
/* inode size */            [-i log=n|perblock=n|size=num,maxpct=n,attr=0|1|2,
                                       projid32bit=0|1]
/* no discard */            [-K]
/* log subvol */            [-l agnum=n,internal,size=num,logdev=xxx,version=n
                                       sunit=value|su=num,sectlog=n|sectsize=num,
                                       lazy-count=0|1]
/* label */                    [-L label (maximum 12 characters)]
/* naming */                [-n log=n|size=num,version=2|ci,ftype=0|1]
/* no-op info only */    [-N]
/* prototype file */       [-p fname]
/* quiet */                    [-q]
/* realtime subvol */    [-r extsize=num,size=num,rtdev=xxx]
/* sectorsize */            [-s log=n|size=num]
/* version */                 [-V]
                                   devicename
<devicename> is required unless -d name=xxx is given.
<num> is xxx (bytes), xxxs (sectors), xxxb (fs blocks), xxxk (xxx KiB),
            xxxm (xxx MiB), xxxg (xxx GiB), xxxt (xxx TiB) or xxxp (xxx PiB).
<value> is xxx (512 byte blocks).


解决这个问题可以使用partprobe 命令,

partprobe包含在parted的rpm软件包中。

partprobe可以修改kernel中分区表，使kernel重新读取分区表。

因此，使用该命令就可以创建分区并且在不重新启动机器的情况下系统能够识别这些分区。

//第一步，检查是否安装了partprobe软件包

[root@localhost ~]# rpm -q parted   //说明：检查是否安装了partprobe软件包
parted-3.1-29.el7.x86_64
[root@localhost ~]# partprobe   //说明：通知操作系统分区表的变化
Warning: Unable to open /dev/sr0 read-write (Read-only file system).  /dev/sr0 has been opened read-only.
[root@localhost ~]# mkfs.xfs /dev/sda3
meta-data=/dev/sda3              isize=512        agcount=4, agsize=26214400 blks
                 =                              sectsz=512     attr=2, projid32bit=1
                 =                              crc=1               finobt=0, sparse=0
data          =                               bsize=4096     blocks=104857600, imaxpct=25
                 =                               sunit=0            swidth=0 blks
naming    =version 2               bsize=4096      ascii-ci=0 ftype=1
log           =internal log            bsize=4096      blocks=51200, version=2
                =                                sectsz=512     sunit=0 blks, lazy-count=1
realtime =none                       extsz=4096      blocks=0, rtextents=0

 

下面附录partprobe命令的官方帮助文档：

[root@localhost ~]# partprobe -h
Usage: partprobe [OPTION] [DEVICE]...
Inform the operating system about partition table changes.

  -d, --dry-run       do not actually inform the operating system
  -s, --summary    print a summary of contents
  -h, --help            display this help and exit
  -v, --version       output version information and exit

When no DEVICE is given, probe all partitions.

Report bugs to <bug-parted@gnu.org>.

 

probe单词的意思：

probe	英[prəʊb]	美[proʊb]
v.	盘问; 追问; 探究; (用细长工具) 探查，查看;
n.	探究; 详尽调查; (不载人) 航天探测器，宇宙探测航天器; (医生用的) 探针;
