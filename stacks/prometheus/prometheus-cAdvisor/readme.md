# 使用 CADVISOR 监控 DOCKER CONTAINER 指标

cAdvisor（container Advisor 的缩写）分析并公开来自正在运行的容器的资源使用情况和性能数据。cAdvisor开箱即用地公开了Prometheus指标。在本指南中，我们将：

- 创建一个本地多容器 Docker Compose 部署测试，包括运行 Prometheus、cAdvisor 和 Redis 服务器的容器
- 检查 Redis 容器生成的一些容器指标，由 cAdvisor 收集，并由 Prometheus 抓取

## Prometheus配置

首先，您需要配置 Prometheus 以从 cAdvisor 抓取指标。创建一个prometheus.yml文件并使用以下配置填充它：

```yml
scrape_configs:
- job_name: cadvisor
  scrape_interval: 5s
  static_configs:
  - targets:
    - cadvisor:8080
```

## Docker Compose 配置

创建一个 Docker Compose 配置，指定容器镜像以及每个容器公开端口、使用的存储卷等。

在创建 prometheus.yml 文件的同一文件夹中，创建一个Docker-Compose.yml 文件并使用以下配置：docker-compose.yml

```yml
version: '3.2'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
    - 9090:9090
    command:
    - --config.file=/etc/prometheus/prometheus.yml
    volumes:
    - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    depends_on:
    - cadvisor
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    ports:
    - 8080:8080
    volumes:
    - /:/rootfs:ro
    - /var/run:/var/run:rw
    - /sys:/sys:ro
    - /var/lib/docker/:/var/lib/docker:ro
    depends_on:
    - redis
  redis:
    image: redis:latest
    container_name: redis
    ports:
    - 6379:6379
```

此Docker Compose配置会运行三个服务，每个服务对应于一个 Docker 容器：

- 该服务使用本地配置文件（通过参数导入到容器中） prometheus prometheus.yml  volumes
- 该服务公开端口 8080（cAdvisor 指标的默认端口），并依赖于各种本地卷（, , 等）。cadvisor//var/run
- 该服务是标准的 Redis 服务器。cAdvisor 将自动从此容器收集容器指标，即无需任何进一步配置。redis

运行安：

```shell
docker-compose up
```

运行后先试一下内容

```shell

```

你可以运行以下命令查看三个运行容器的信息

```shell
docker-compose ps
```

可以看到结果为

```shell
 Name                 Command               State           Ports
----------------------------------------------------------------------------
cadvisor     /usr/bin/cadvisor -logtostderr   Up      8080/tcp
prometheus   /bin/prometheus --config.f ...   Up      0.0.0.0:9090->9090/tcp
redis        docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
```
