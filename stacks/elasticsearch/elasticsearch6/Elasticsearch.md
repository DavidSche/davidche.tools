# How to create Elasticsearch cluster using docker

author  By milosz October 28, 2020

Create an Elasticsearch cluster using docker to learn how it behaves during specific operations.


## Preparation

Tune system settings to deal with initial bootstrap issues.

elasticsearch-emu | ERROR: [2] bootstrap checks failed
elasticsearch-emu | [1]: memory locking requested for elasticsearch process but memory is not locked
elasticsearch-emu | [2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

### Enable memory locking to prevent storing JVM heap on the disk.

```shell
$ sudo mkdir /etc/systemd/system/docker.service.d
$ echo -e "[Service]\nLimitMEMLOCK=infinity" | sudo tee /etc/systemd/system/docker.service.d/memlock.conf
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker

```

### Increase the maximum number of memory map areas a process may have.

$ echo vm.max_map_count=262144 | sudo tee /etc/sysctl.d/99-max_map_count.conf
$ echo vm.max_map_count=262144 | sudo tee /etc/sysctl.d/99-max_map_count.conf
$ sudo sysctl --system

## Elasticsearch 6

Docker-compose for Elasticsearch 6.8.11. This cluster consists of five nodes, 
but only three are master eligible ones.

```yaml
version: "3.3"

services:
  elasticsearch-eel:
    image: elasticsearch:6.8.11
    environment:
      node.name: elasticsearch-eel
      cluster.name: elasticsearch-cluster
      discovery.zen.ping.unicast.hosts: elasticsearch-eel,elasticsearch-elk,elasticsearch-emu,elasticsearch-ewe,elasticsearch-ewt
      bootstrap.memory_lock: "true"
      discovery.zen.minimum_master_nodes: 2
      ES_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - elasticsearch_data_eel:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elasticsearch-internal-network
    labels:
      - stack=elasticsearch6
      - traefik.http.routers.elasticsearch.rule=PathPrefix(`/`)
      - traefik.http.services.elasticsearch.loadbalancer.server.port=9200
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.path=/_cluster/health?local=true
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.interval=15s
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.timeout=10s
  elasticsearch-elk:
    image: elasticsearch:6.8.11
    environment:
      node.name: elasticsearch-elk
      cluster.name: elasticsearch-cluster
      discovery.zen.ping.unicast.hosts: elasticsearch-eel,elasticsearch-elk,elasticsearch-emu,elasticsearch-ewe,elasticsearch-ewt
      bootstrap.memory_lock: "true"
      discovery.zen.minimum_master_nodes: 2
      ES_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - elasticsearch_data_elk:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elasticsearch-internal-network
    labels:
      - stack=elasticsearch6
      - traefik.http.routers.elasticsearch.rule=PathPrefix(`/`)
      - traefik.http.services.elasticsearch.loadbalancer.server.port=9200
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.path=/_cluster/health?local=true
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.interval=15s
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.timeout=10s
  elasticsearch-emu:
    image: elasticsearch:6.8.11
    environment:
      node.name: elasticsearch-emu
      cluster.name: elasticsearch-cluster
      discovery.zen.ping.unicast.hosts: elasticsearch-eel,elasticsearch-elk,elasticsearch-emu,elasticsearch-ewe,elasticsearch-ewt
      bootstrap.memory_lock: "true"
      discovery.zen.minimum_master_nodes: 2
      ES_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - elasticsearch_data_emu:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elasticsearch-internal-network
    labels:
      - stack=elasticsearch6
      - traefik.http.routers.elasticsearch.rule=PathPrefix(`/`)
      - traefik.http.services.elasticsearch.loadbalancer.server.port=9200
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.path=/_cluster/health?local=true
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.interval=15s
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.timeout=10s
  elasticsearch-ewe:
    image: elasticsearch:6.8.11
    environment:
      node.name: elasticsearch-ewe
      cluster.name: elasticsearch-cluster
      discovery.zen.ping.unicast.hosts: elasticsearch-eel,elasticsearch-elk,elasticsearch-emu,elasticsearch-ewe,elasticsearch-ewt
      bootstrap.memory_lock: "true"
      node.master: "false"
      discovery.zen.minimum_master_nodes: 2
      ES_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - elasticsearch_data_ewe:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elasticsearch-internal-network
    labels:
      - stack=elasticsearch6
      - traefik.http.routers.elasticsearch.rule=PathPrefix(`/`)
      - traefik.http.services.elasticsearch.loadbalancer.server.port=9200
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.path=/_cluster/health?local=true
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.interval=15s
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.timeout=10s
  elasticsearch-ewt:
    image: elasticsearch:6.8.11
    environment:
      node.name: elasticsearch-ewt
      cluster.name: elasticsearch-cluster
      discovery.zen.ping.unicast.hosts: elasticsearch-eel,elasticsearch-elk,elasticsearch-emu,elasticsearch-ewe,elasticsearch-ewt
      bootstrap.memory_lock: "true"
      node.master: "false"
      discovery.zen.minimum_master_nodes: 2
      ES_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - elasticsearch_data_ewt:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elasticsearch-internal-network
    labels:
      - stack=elasticsearch6
      - traefik.http.routers.elasticsearch.rule=PathPrefix(`/`)
      - traefik.http.services.elasticsearch.loadbalancer.server.port=9200
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.path=/_cluster/health?local=true
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.interval=15s
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.timeout=10s
  traefik:
    image: traefik:2.3
    command:
      - --entrypoints.web.address=:9200
      - --providers.docker=true
      - --providers.docker.constraints=Label(`stack`,`elasticsearch6`)
      - --api.insecure
      - --accesslog=true
    depends_on:
      - elasticsearch-eel
      - elasticsearch-elk
      - elasticsearch-emu
      - elasticsearch-ewe
      - elasticsearch-ewt
    ports:
      - 9200:9200
      - 8080:8080
      - 8000:8000
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - elasticsearch-internal-network
      - traefik-external-network
volumes:
  elasticsearch_data_eel:
  elasticsearch_data_elk:
  elasticsearch_data_emu:
  elasticsearch_data_ewe:
  elasticsearch_data_ewt:
networks:
  elasticsearch-internal-network:
    internal: true
  traefik-external-network:

```

#### Cluster status.

```shell
$ curl http://localhost:9200/_cluster/health?pretty
```

```json
{
    "cluster_name" : "elasticsearch-cluster",
    "status" : "green",
    "timed_out" : false,
    "number_of_nodes" : 5,
    "number_of_data_nodes" : 5,
    "active_primary_shards" : 0,
    "active_shards" : 0,
    "relocating_shards" : 0,
    "initializing_shards" : 0,
    "unassigned_shards" : 0,
    "delayed_unassigned_shards" : 0,
    "number_of_pending_tasks" : 0,
    "number_of_in_flight_fetch" : 0,
    "task_max_waiting_in_queue_millis" : 0,
    "active_shards_percent_as_number" : 100.0
}
```

#### Node list.

```shell
$ curl http://localhost:9200/_cat/nodes?v

ip         heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
172.30.0.3           75          99  27    1.62    2.87     3.45 di        -      elasticsearch-ewt
172.30.0.2           68          99  27    1.62    2.87     3.45 di        -      elasticsearch-ewe
172.30.0.4           35          99  27    1.62    2.87     3.45 mdi       *      elasticsearch-emu
172.30.0.6           69          99  27    1.62    2.87     3.45 mdi       -      elasticsearch-elk
172.30.0.5           46          99  27    1.62    2.87     3.45 mdi       -      elasticsearch-eel

```

Please read about node roles in Elasticsearch 6.

Elasticsearch 7 

[来源](https://blog.sleeplessbeastie.eu/2020/10/28/how-to-create-elasticsearch-cluster-using-docker/)