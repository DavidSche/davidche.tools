# Portainer 运行命令操作远程主机

  1、添加一个容器，使用 容器镜像 "busybox:latest" 来创建一个新的容器示例；
  2、在 高级容器设置 中的控制台模式中选择 " Interactive & TTY"
  3、在 存储卷部分添加一个卷绑定映射 设置 主机的 / 目录映射为容器的 /host 目录
  4、在权限设置部分(permissions) 选择  "privileged" 
  5、部署创建容器
  6、使用 docker exec -it busybox /bin/bash  命令进入容器
  7、执行 chroot /host  命令将默认根路径更改为 /host
  8、容器现在以 root 用户身份在主机上运行，您可以对主机运行命令。

  >> 例如，您可以键入“echo 3 > /proc/sys/vm/drop_caches”来刷新内存缓存。或者您可以使用“reboot now ”来重新引导主机

  危险？是的，或者当然，以及为什么（默认情况下）在Portainer中我们为非管理员用户禁用此功能。

docker run -d -i -t  --privileged -v /:/host busybox:latest   --restart unless-stopped 

