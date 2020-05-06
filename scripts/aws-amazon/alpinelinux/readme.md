# alpine 使用

## 配置国内镜像源

``` Dockerfile
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
```

测试一下：

``` Dockewrfile
FROM alpine:latest
LABEL maintainer="Davidche@outlook.com"

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk add --update curl && rm -rf /var/cache/apk/*
```

测试docker-compose.yml

``` yml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost"]
  interval: 1m30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

-------
