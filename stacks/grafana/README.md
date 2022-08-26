#


## 先决条件

我假设你有Docker运行，并且你已经有如何使用Docker的基本知识。
您已经有 Traefik 作为反向代理运行。

## 言论
它适用于Docker swarm，但您可以轻松地将其转换为Docker组合。
我无法解释yml文件中的每个细节，在这种情况下，请检查该图像的官方页面以获取更多信息。
这已经在 QNAP 上进行了测试，但它可能会在另一个 NAS 系统上工作，如 Synology 或 OMV。
默认情况下，堆栈需要您要运行它的系统提供大量内存和 CPU。该配置经过优化，可在没有太多资源的情况下运行。

### 准备工作

在继续之前，我们将确保文件夹结构是有序的。创建以下文件夹和文件，并复制粘贴内容，如下所述。
###


```
.(your volume)
├── Docker-compose.yml
├── grafana/
├── prometheus/
    └── data/
    └── prometheus.yml
```

prometheus.yml
```
global:
  scrape_interval: 30s
  scrape_timeout: 10s
  evaluation_interval: 30s

scrape_configs:
- job_name: prometheus
  honor_timestamps: true
  scrape_interval: 30s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets:
    - NASip:9090
- job_name: grafana
  honor_timestamps: true
  scrape_interval: 30s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets:
    - grafana:3000
- job_name: node_exporter
  honor_timestamps: true
  scrape_interval: 30s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets:
    - node_exporter:9100
- job_name: traefik
  honor_timestamps: true
  scrape_interval: 30s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets:
    - NASip:8090
- job_name: cadvisor
  honor_timestamps: true
  scrape_interval: 30s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets:
    - cadvisor:8080
- job_name: adguard
  static_configs:
  - targets:
    - adguard_exporter:9617
- job_name: 'speedtest'
  metrics_path: /probe
  params:
    script: [speedtest]
  static_configs:
  - targets:
    - NASip:9469
  scrape_interval: 30m
  scrape_timeout: 60s
- job_name: 'script_exporter'
  metrics_path: /metrics
  static_configs:
  - targets:
    - NASip:9469

```

Docker-compose.yml

```
version: "3"
services:
  grafana:
    image: grafana/grafana:latest
    networks:
      - internal
      - traefik_public
    environment:
      - GF_SERVER_ROOT_URL=https://grafana.yourdomain.com
      - GF_METRICS_ENABLED=true
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    deploy:
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.grafana-rtr.entrypoints=https"
        - "traefik.http.routers.grafana-rtr.rule=Host(`grafana.yourdomain.com`)"
        - "traefik.http.routers.grafana-rtr.middlewares=chain-no-auth@file"
        - "traefik.http.routers.grafana-rtr.service=grafana-svc"
        - "traefik.http.services.grafana-svc.loadbalancer.server.port=3000"
    volumes:
      - /yourvolume/grafana:/var/lib/grafana
 
  prometheus:
    image: prom/prometheus:latest
    ports:
      - 9090:9090
    networks:
      - internal
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - --storage.tsdb.retention.time=7d
      - "--web.console.libraries=/usr/share/prometheus/console_libraries"
      - "--web.console.templates=/usr/share/prometheus/consoles"
    volumes:
      - /yourvolume/prometheus/data:/prometheus
      - /yourvolume/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - /yourvolume/prometheus/rules:/etc/prometheus/rules

  node_exporter:
    image: prom/node-exporter:latest
    networks:
     - internal
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro

  cadvisor:
    image: gcr.io/cadvisor/cadvisor
    ports:
    - 8084:8080
    command:
      - '--housekeeping_interval=30s'
      - '--max_housekeeping_interval=35s'
      - '--store_container_labels=false'
      - '--global_housekeeping_interval=30s'
      - '--Docker_only'
      - '--disable_root_cgroup_stats=false'
      - '--disable_metrics=percpu,process,sched,tcp,udp,diskIO,disk,network'      # enable only cpu, memory
      - '--allow_dynamic_housekeeping=true'
      - '--storage_duration=1m0s'
    networks:
      - internal
    volumes:
      - /var/run/Docker.sock:/var/run/Docker.sock:ro
      - /:/rootfs:ro
      - /var/run:/var/run
      - /sys:/sys:ro
      - /var/lib/Docker/:/var/lib/Docker:ro

  adguard_exporter:
    image: ebrianne/adguard-exporter:latest
    networks:
      - internal
    ports:
      - 9617:9617
    environment:
      - adguard_protocol=http
      - adguard_hostname=AdguardIP
      - adguard_username=username
      - "adguard_password=password
#      - adguard_port= #optional
      - interval=300s #5min
      - log_limit=1000

  speedtest:
    image: billimek/prometheus-speedtest-exporter:1.1.0
    networks:
      - internal
    ports:
      - 9469:9469

networks:
  traefik_public:
    external: true
  internal:
    driver: overlay
    ipam:
      config:
        - subnet: 172.16.84.0/24

```

在保存此文件之前，请确保将“您的卷”更改为正确的位置，即您刚刚创建文件夹和文件的位置。在 Adguard 部分，更改主机名、用户名和密码。最后在traefik标签上更改域名。

### 运行堆栈

使用 SSH 登录到 NAS，然后浏览到您刚刚创建文件夹和文件的“卷”/位置。现在运行命令：Docker-compose up 然后 Docker 将创建所有服务，文件夹将填充应用程序数据。
