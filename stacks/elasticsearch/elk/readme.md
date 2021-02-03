# ELK STACK

 - Elasticsearch (3 Nodes)
 - Kibana
 - Logstash

## Creating network

```shell
docker network create --driver overlay --attachable elastic
```

## Deploying Stack

```shell
docker stack deploy -c stack.yml elkstack
```


## Remove Stack

```shell
docker stack rm elkstack
```


## Some important notes must be done before stack deploy

[https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html)

[https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration-memory.html](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration-memory.html)

## Source 

[https://github.com/ahmetakyol38/ElkStack](https://github.com/ahmetakyol38/ElkStack)