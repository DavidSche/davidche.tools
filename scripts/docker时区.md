# 修改 Docker 镜像中的默认时区

## 
 基础镜像包含alpine、centos、ubuntu三种。特意整理一下不同系统的修改方法。

## Alpine
``` Dockerfile

RUN apk --no-cache add tzdata  && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone 
```

--no-cache参数不缓存文件，有助于减少最终体积。

##Ubuntu
``` Dockerfile
RUN echo "Asia/Hong_Kong" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata
```

##CentOS

``` Dockerfile
RUN echo "Asia/Shanghai" > /etc/timezone;
```

当然也可以将时区作为构建镜像的参数处理，这样可以带来更大的灵活性。

-----
Asia/Hong_Kong


apk add --update nodejs nodejs-npm


apk add --update nodejs nodejs-npm


cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime


  RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
  
  dockerfile 中增加一行
  
  RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
  
  ubuntu 
  
$ RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

$ dpkg-reconfigure --frontend noninteractive tzdata
  