# rabbitmq-consul-cluster

RabbitMQ Cluster on Docker Swarm using Consul-based Discovery

This repository contains the Docker swarm and compose yaml files for Consul and RabbitMQ cluster, as well as the RabbitMQ image.

The RabbitMQ image is stored in DockerHub: busecolak/rabbitmq-consul

## Usage

### Create Docker network

```shell
docker network create --driver=overlay --attachable prod
```

### Update swarm node labels

```shell
docker node update --label-add rabbitmq=true node1
docker node update --label-add rabbitmq=true node2
docker node update --label-add rabbitmq=true node3

docker node update --label-add consul=true node1
docker node update --label-add consul=true node2
docker node update --label-add consul=true node3
```

### Deploy stacks

```shell
docker stack deploy -c consul-swarm-cluster.yml consul
docker stack deploy -c rabbitmq-swarm-cluster.yml rabbitmq
```

### Navigate to below addresses for UIs

 - Consul UI: http://node-ip:8500
 - RabbitMq Management UI: http://node-ip:15672

### Docker Compose

To deploy services locally using docker-compose

```shell
docker-compose -f .\docker-compose.yml up -d
docker-compose -f .\docker-compose.yml down
```
