#  alpine  Dockerfile 

更新Alpine的软件源，切换为阿里云

```shell
#.更新Alpine的软件源，切换为阿里云 
RUN echo http://mirrors.aliyun.com/alpine/v3.10/main/ > /etc/apk/repositories && \
    echo http://mirrors.aliyun.com/alpine/v3.10/community/ >> /etc/apk/repositories
RUN apk update && apk upgrade


```


https://www.hashicorp.com/blog/hashitalks-2021-highlights-nomad-and-consul

