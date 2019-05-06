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

docker run -v portainer_data:/volume -v /home/backup:/backup --rm loomchild/volume-backup restore portainer_data_archive
```

使用不同的压缩算法来改善性能

``` bash
docker run -v [volume-name]:/volume --rm loomchild/volume-backup backup -c gz - > [archive-name]
```

[脚本出处](https://github.com/loomchild/volume-backup#miscellaneous)

scp 传输文件

拷贝文件到本地

scp -r root@43.224.34.73:/home/lk /root

拷贝文件到远程机器

scp -r /root/lk root@43.224.34.73:/home/lk/cpfile
