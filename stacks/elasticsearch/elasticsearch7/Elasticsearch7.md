# Elasticsearch 7

Docker-compose for Elasticsearch 7.8.1. This cluster consists of five nodes, but only three are master eligible ones.

```yml

# Docker-compose for Elasticsearch 7.8.1. This cluster consists of five nodes, but only three are master eligible ones.

version: "3.3"
services:
  elasticsearch-tapir:
    image: elasticsearch:7.8.1
    environment:
      node.name: elasticsearch-tapir
      cluster.name: elasticsearch-cluster
      discovery.seed_hosts: elasticsearch-tetra,elasticsearch-tiger
      cluster.initial_master_nodes: elasticsearch-tapir,elasticsearch-tetra,elasticsearch-tiger
      bootstrap.memory_lock: "true"
      ES_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - elasticsearch_data_tapir:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elasticsearch-internal-network
    labels:
      - stack=elasticsearch7
      - traefik.http.routers.elasticsearch.rule=PathPrefix(`/`)
      - traefik.http.services.elasticsearch.loadbalancer.server.port=9200
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.path=/_cluster/health?local=true
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.interval=15s
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.timeout=10s
  elasticsearch-tetra:
    image: elasticsearch:7.8.1
    environment:
      node.name: elasticsearch-tetra
      cluster.name: elasticsearch-cluster
      discovery.seed_hosts: elasticsearch-tapir,elasticsearch-tiger
      cluster.initial_master_nodes: elasticsearch-tapir,elasticsearch-tetra,elasticsearch-tiger
      bootstrap.memory_lock: "true"
      ES_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - elasticsearch_data_tetra:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elasticsearch-internal-network
    labels:
      - stack=elasticsearch7
      - traefik.http.routers.elasticsearch.rule=PathPrefix(`/`)
      - traefik.http.services.elasticsearch.loadbalancer.server.port=9200
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.path=/_cluster/health?local=true
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.interval=15s
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.timeout=10s
  elasticsearch-tiger:
    image: elasticsearch:7.8.1
    environment:
      node.name: elasticsearch-tiger
      cluster.name: elasticsearch-cluster
      discovery.seed_hosts: elasticsearch-tapir,elasticsearch-tetra
      cluster.initial_master_nodes: elasticsearch-tapir,elasticsearch-tetra,elasticsearch-tiger
      ES_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - elasticsearch_data_tiger:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elasticsearch-internal-network
    labels:
      - stack=elasticsearch7
      - traefik.http.routers.elasticsearch.rule=PathPrefix(`/`)
      - traefik.http.services.elasticsearch.loadbalancer.server.port=9200
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.path=/_cluster/health?local=true
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.interval=15s
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.timeout=10s
  elasticsearch-trout:
    image: elasticsearch:7.8.1
    environment:
      node.name: elasticsearch-trout
      cluster.name: elasticsearch-cluster
      discovery.seed_hosts: elasticsearch-tapir,elasticsearch-tetra,elasticsearch-tiger
      cluster.initial_master_nodes: elasticsearch-tapir,elasticsearch-tetra,elasticsearch-tiger
      bootstrap.memory_lock: "true"
      node.master: "false"
      ES_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - elasticsearch_data_trout:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elasticsearch-internal-network
    labels:
      - stack=elasticsearch7
      - traefik.http.routers.elasticsearch.rule=PathPrefix(`/`)
      - traefik.http.services.elasticsearch.loadbalancer.server.port=9200
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.path=/_cluster/health?local=true
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.interval=15s
      - traefik.http.services.elasticsearch.loadbalancer.healthcheck.timeout=10s
  elasticsearch-tayra:
    image: elasticsearch:7.8.1
    environment:
      node.name: elasticsearch-tayra
      cluster.name: elasticsearch-cluster
      discovery.seed_hosts: elasticsearch-tapir,elasticsearch-tetra,elasticsearch-tiger
      cluster.initial_master_nodes: elasticsearch-tapir,elasticsearch-tetra,elasticsearch-tiger
      bootstrap.memory_lock: "true"
      node.master: "false"
      ES_JAVA_OPTS: "-Xmx512m -Xms512m"
    volumes:
      - elasticsearch_data_tayra:/usr/share/elasticsearch/data
    ulimits:
      memlock:
        soft: -1
        hard: -1
    networks:
      - elasticsearch-internal-network
    labels:
      - stack=elasticsearch7
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
      - --providers.docker.constraints=Label(`stack`,`elasticsearch7`)
      - --api.insecure
      - --accesslog=true
    depends_on:
      - elasticsearch-tapir
      - elasticsearch-tetra
      - elasticsearch-tiger
      - elasticsearch-trout
      - elasticsearch-tayra
    ports:
      - 9200:9200
      - 8080:8080
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - elasticsearch-internal-network
      - traefik-external-network
volumes:
  elasticsearch_data_tapir:
  elasticsearch_data_tetra:
  elasticsearch_data_tiger:
  elasticsearch_data_trout:
  elasticsearch_data_tayra:
networks:
  elasticsearch-internal-network:
    internal: true
  traefik-external-network:


```

Cluster status.

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

Node list.

```shell

$ curl http://localhost:9200/_cat/nodes?v

ip         heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
172.30.0.4           20          97  26    6.13    3.95     3.75 dilmrt    *      elasticsearch-tetra
172.30.0.5           47          97  26    6.13    3.95     3.75 dilrt     -      elasticsearch-tayra
172.30.0.3           62          97  26    6.13    3.95     3.75 dilrt     -      elasticsearch-trout
172.30.0.6           20          97  26    6.13    3.95     3.75 dilmrt    -      elasticsearch-tiger
172.30.0.2           33          97  26    6.13    3.95     3.75 dilmrt    -      elasticsearch-tapir


```

Please read about node roles in Elasticsearch 7.