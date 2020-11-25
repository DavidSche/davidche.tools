```yml
version: '2'
services:
  zoo1:
    image: wurstmeister/zookeeper
    restart: unless-stopped
    hostname: zoo1
    ports:
      - "2181:2181"
    container_name: zookeeper
  kafka1:
    image: wurstmeister/kafka
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 192.168.124.5                   ## 修改:宿主机IP
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://192.168.124.5:9092    ## 修改:宿主机IP
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181"
      KAFKA_ADVERTISED_PORT: 9092
      KAFKA_BROKER_ID: 1
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    depends_on:
      - zoo1
    container_name: kafka1
  kafka2:
    image: wurstmeister/kafka
    ports:
      - "9093:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 192.168.124.5                 ## 修改:宿主机IP
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://192.168.124.5:9093   ## 修改:宿主机IP
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181"
      KAFKA_ADVERTISED_PORT: 9093
      KAFKA_BROKER_ID: 2
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    depends_on:
      - zoo1
    container_name: kafka2
  kafka-manager:
    image: sheepkiller/kafka-manager              ## 镜像：开源的web管理kafka集群的界面
    environment:
        ZK_HOSTS: 192.168.124.5                 ## 修改:宿主机IP
    ports:
      - "9000:9000"                               ## 暴露端口
```