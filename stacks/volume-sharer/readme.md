# volume-sharer

On my windows 10 laptop from work it is possible to make use of Docker, but due to security restrctions that are in place, I am not able to bind mount a windows folder in a container.

In order to be able to still work easily with data volumes and access the content of them from within my windows environment I updated the dperson/samba container image to not only contain a Docker installation to check all data volumes, but also keep on refreshing the list of shares whenever a data volumes are added/removed.

## Usage

Most important is that we need to volume mount the docker volumes directory, as well as the docker socket.

This means that we will need the following:

-v /var/lib/docker/volumes:/docker_volumes to bind mount the directory holding all docker volumes
-v /var/run/docker.sock:/var/run/docker.sock to bind mount the docker socket, allowing the docker within the container to query information about the volumes

## Windows

When running under windows, it will typically already run the SMB shares on the ports 139 and 445 so you cannot use these ports. In order to work around this, you can state that you do not want to bind the ports to the windows host system, but that I want to bind them to the docker image running in Hyper-V.

This is achieved by giving it the same net as the Hyper-V by using the following commandline: docker run --name volume-sharer --rm -v /var/lib/docker/volumes:/docker_volumes -p 139:139 -p 445:445 -v /var/run/docker.sock:/var/run/docker.sock --net=host -d gdiepen/volume-sharer

## Linux

If you don't have samba running on your host-system, you can bind the ports. The complete commandline will be:

docker run --name volume-sharer --rm -v /var/lib/docker/volumes:/docker_volumes -p 139:139 -p 445:445 -v /var/run/docker.sock:/var/run/docker.sock -d gdiepen/volume-sharer

> More details I have placed more information on my blog article: https://www.guidodiepen.nl/2017/08/sharing-all-your-docker-data-volumes-via-samba/

[github](https://github.com/gdiepen/volume-sharer/blob/master/README.md)

``` bash
docker run --name volume-sharer \
           --rm \
           -d \
           -v /var/lib/docker/volumes:/docker_volumes \
           -p 139:139 \
           -p 445:445 \
           -v /var/run/docker.sock:/var/run/docker.sock \
           --net=host \
           gdiepen/volume-sharer
```

提供给Docker的不同参数如下：

--name volume-sharer：为容器提供可识别的名称
--rm：停止后清理容器
-d：使容器在后台运行
-v / var / lib / docker / volumes：/ docker_volumes：将保存Docker主机上本地Docker数据卷的目录安装到正在运行的容器中的本地文件夹/ docker_volumes
-p 139：139 -p 445：445：将用于Samba的端口发布到主机
-v /var/run/docker.sock:/var/run/docker.sock：将主机系统的Docker套接字安装在容器中，以允许容器访问Docker信息（即创建/删除卷）
--net = host：在Windows下运行时，需要使用此参数将SMB端口发布到Hyper-V虚拟机。

gdiepen/volume-sharer：DockerHub 上 镜像的名称
