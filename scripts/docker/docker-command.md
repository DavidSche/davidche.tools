# 常用 docker 维护脚本信息

## Volume 维护脚本

### 复制 volume

- 方法1: 借助alpine镜像中的 cp 命令

``` bash
docker volume create --name <new_volume>
docker run --rm -it -v <old_volume>:/from -v <new_volume>:/to alpine ash -c "cd /from ; cp -av . /to"
docker volume rm <old_volume>

```

- 方法2: 使用 *docker_clone_volume.sh* 脚本

``` bash
docker_clone_volume.sh www-data www-dev-data
```

[脚本出处](https://www.guidodiepen.nl/2016/05/cloning-docker-data-volumes/)

[脚本源码](https://github.com/gdiepen/docker-convenience-scripts)

### 备份磁盘卷

``` bash
docker run -v a0fcb7f63e96f7baaa0bcc69bf7c39a51aa2fcb756aeb9115f6306702e1e91d9:/volume -v /home/backup/:/backup --rm loomchild/volume-backup backup registry-data
```

说明:  volume a0fcb7f63e96f7baaa0bcc69bf7c39a51aa2fcb756aeb9115f6306702e1e91d9 会备份到 文件/home/backup/目录下的registry-data.tar.bz2

恢复磁盘卷

语法:

``` bash
docker run -v [volume-name]:/volume -v [output-dir]:/backup --rm loomchild/volume-backup restore [archive-name]
```

``` bash
docker run -v some_volume:/volume -v /tmp:/backup --rm loomchild/volume-backup restore some_archive
```

备份及恢复示例（备份及回复的文件目录为 '/home/backup'）：

``` bash
docker run -v portainer_data:/volume -v /home/backup:/backup --rm loomchild/volume-backup backup  -c gz - > portainer_data_archive
docker run -v elk_esdata:/volume -v /data1/backup:/backup --rm loomchild/volume-backup backup  -c gz - > elk_esdata_archive

docker run -v portainer_data:/volume -v /home/backup:/backup --rm loomchild/volume-backup restore portainer_data_archive
```

使用不同的压缩算法来改善性能

``` bash
docker run -v [volume-name]:/volume --rm loomchild/volume-backup backup -c gz - > [archive-name]
```

[脚本出处](https://github.com/loomchild/volume-backup#miscellaneous)

------

### scp 传输文件命令

拷贝文件到本地

scp -r root@43.224.34.73:/home/lk /root

拷贝文件到远程机器

scp -r /root/lk root@43.224.34.73:/home/lk/cpfile

[参考说明](https://www.cnblogs.com/likui360/p/6011769.html)
scp在夸机器复制的时候为了提高数据的安全性，使用了ssh连接和加密方式，如果机器之间配置了ssh免密码登录，那在使用scp的时候密码都不用输入。

命令详解：

scp是secure copy的简写，用于在Linux下进行远程拷贝文件的命令，和它类似的命令有cp，不过cp只是在本机进行拷贝不能跨服务器，而且scp传输是加密的。可能会稍微影响一下速度。当你服务器硬盘变为只读 read only system时，用scp可以帮你把文件移出来。另外，scp还非常不占资源，不会提高多少系统负荷，在这一点上，rsync就远远不及它了。虽然 rsync比scp会快一点，但当小文件众多的情况下，rsync会导致硬盘I/O非常高，而scp基本不影响系统正常使用。

1．命令格式：

scp [参数] [原路径] [目标路径]

2．命令功能：

scp是 secure copy的缩写, scp是linux系统下基于ssh登陆进行安全的远程文件拷贝命令。linux的scp命令可以在linux服务器之间复制文件和目录。

3．命令参数：

-1  强制scp命令使用协议ssh1  

-2  强制scp命令使用协议ssh2  

-4  强制scp命令只使用IPv4寻址  

-6  强制scp命令只使用IPv6寻址  

-B  使用批处理模式（传输过程中不询问传输口令或短语）  

-C  允许压缩。（将-C标志传递给ssh，从而打开压缩功能）  

-p 保留原文件的修改时间，访问时间和访问权限。  

-q  不显示传输进度条。  

-r  递归复制整个目录。  

-v 详细方式显示输出。scp和ssh(1)会显示出整个过程的调试信息。这些信息用于调试连接，验证和配置问题。   

-c cipher  以cipher将数据传输进行加密，这个选项将直接传递给ssh。   

-F ssh_config  指定一个替代的ssh配置文件，此参数直接传递给ssh。  

-i identity_file  从指定文件中读取传输时使用的密钥文件，此参数直接传递给ssh。    

-l limit  限定用户所能使用的带宽，以Kbit/s为单位。     

-o ssh_option  如果习惯于使用ssh_config(5)中的参数传递方式，   

-P port  注意是大写的P, port是指定数据传输用到的端口号   

-S program  指定加密传输时所使用的程序。此程序必须能够理解ssh(1)的选项。

4．使用实例：

scp命令的实际应用概述：  

从本地服务器复制到远程服务器： 

(1) 复制文件：  

命令格式：  

scp local_file remote_username@remote_ip:remote_folder  

或者  

scp local_file remote_username@remote_ip:remote_file  

或者  

scp local_file remote_ip:remote_folder  

或者  

scp local_file remote_ip:remote_file  

第1,2个指定了用户名，命令执行后需要输入用户密码，第1个仅指定了远程的目录，文件名字不变，第2个指定了文件名  

第3,4个没有指定用户名，命令执行后需要输入用户名和密码，第3个仅指定了远程的目录，文件名字不变，第4个指定了文件名   

(2) 复制目录：  

命令格式：  

scp -r local_folder remote_username@remote_ip:remote_folder  

或者  

scp -r local_folder remote_ip:remote_folder  

第1个指定了用户名，命令执行后需要输入用户密码；  

第2个没有指定用户名，命令执行后需要输入用户名和密码；