## 背景
为什么要用Docker Swarm, 相比 Kubernetes 有什么好处
Docker Swarm可以看作是docker自带的一个简化版的Kubernetes, 拥有Kubernetes的基本功能如:

-更新
-回滚
-动态扩容
-分布式部署

而 Docker Swarm 的优势在于:

-Docker 自带， 无需另外安装。学习成本低
-单机也能很好的使用，也可以很方便的进行实例扩容与设备扩容
-Swarm 只有2层网络封装，而 Kubernetes 有5层网络封装
-Swarm 本身占用的内存只有100M左右，而 Kubernetes 的简化版 k3s 也需要512M的内存空间，对小资源机器友好
## Traefik 是什么, 为什么要使用它

Traefik官方文档
Traefik 是一个反向代理软件，类似 Nginx但对于微服务有很好的优化。可以搭配各种分布式发现服务而无需另外配置。在本篇文章中我们会使用 Docker Provider 作为服务发现。

虽然 Docker Swarm 自带了http请求的分发，但是无法实现 sticky 功能(即同一用户的请求会分发到同一后端实例)，因此需要Traefik 作为请求的中间件来分发请求

##搭建 Docker Swarm 环境
Docker Swarm 环境非常好搭建，因为已经集成到Docker中了。我们安装好Docker以后就可以直接使用了

### 依赖:

Docker 1.12+
# 初始化swarm, 并将当前节点作为manager
$ docker swarm init
# 或者使用--advertise-addr 和 --listen-addr参数来指定使用哪个IP作为沟通IP
# 两个参数一般保持一致即可
$ docker swarm init --advertise-addr 10.0.0.1:2377 --listen-addr 10.0.0.1:2377
使用Docker快速搭建Traefik

```
version: '3'

services:
  reverse-proxy:
    # The official v2.0 Traefik docker image
    image: traefik:v2.0
    # Enables the web UI and tells Traefik to listen to docker
    command: --api.insecure=true --providers.docker.endpoint=tcp://127.0.0.1:2377 --providers.docker.swarmMode=true
    ports:
      # The HTTP port
      - "80:80"
      # The Web UI (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
```

api.insecure参数用于打开WEB UI. 可以访问127.0.0.1:8080/api/rawdata获取当前可以连接到的服务的相关信息
providers.docker.endpoint指向docker的沟通端口。默认端口为2377
providers.docker.swarmMode 表示为swarm模式

### 创建测试服务
此处使用 whoami 镜像提供的HTTP服务用于打印出集群连接相关信息

将以下文件保存为docker-compose.yml
```yml
version: '3'

services:
  whoami:
    # A container that exposes an API to show its IP address
    image: containous/whoami
    deploy:
      replicas: 3
      labels:
        - "traefik.http.routers.whoami.rule=Host(`whoami.docker.localhost`)"
        - "traefik.http.services.whoami.loadbalancer.server.port=80"
        - "traefik.http.services.whoami.loadbalancer.sticky=true"
        - "traefik.http.services.whoami.loadbalancer.sticky.cookie.name=foosession"
```
version: '3'


### 启动集群:
```shell
docker stack deploy -c ./docker-compose.yml whoami

```

### 测试命令:

```shell
$ curl -vs -c cookie.txt -b cookie.txt -H "Host: whoami.docker.localhost" http://127.0.0.1
```

注意需要带上 header Host 这样才能成功反向代理