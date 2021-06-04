# OpenSearch 上手入门

## 安装Open search

单节点服务

### 构建禁用安全插件的opensearch-dashboards 镜像

创建opensearch-dashboards配置文件 opensearch-dashboards.yml

```yaml
server.name: opensearch-dashboards
server.host: "0"
#opensearch.hosts: http://localhost:9200
```
运行 build.sh 命令构建镜像

```shell
docker build --tag=cheshuai/opensearch-dashboards:1.0.0-beta1 .

```

### 部署opensearch 应用
docker stack deploy -c docker-compose.yml search 

docker-compose.yaml的内容如下：

```yaml
version: '3'
# author:David.che
services:

  opensearch-1:
    image: opensearchproject/opensearch
    container_name: opensearch-1
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9200"]
      interval: 15s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    ports:
      - "9200:9200"
      - "9300:9300"
      - "9600:9600"
    environment:
      - "OPENSEARCH_JAVA_OPTS=-Xms1g -Xmx1g"
      - "network.host=0.0.0.0"
      - "http.port=9200"
      - "transport.port=9300"
      - "discovery.type=single-node"
      - "bootstrap.memory_lock=true"
      - opendistro_security.disabled=true
    volumes:
      - search-data:/usr/share/opensearch/data
    networks:
      - search-net
    ulimits:
      memlock:
        soft: -1
        hard: -1
      nofile:
        soft: 65536
        hard: 65536
    cap_add:
      - IPC_LOCK

  opensearch-dashboards:
    image: cheshuai/opensearch-dashboards:1.0.0-beta1
    container_name: opensearch-dashboards
    ports:
      - 5601:5601
    expose:
      - "5601"
    environment:
      OPENSEARCH_HOSTS: http://opensearch-1:9200
    networks:
      - search-net

volumes:
  search-data:

networks:
  search-net:

```

备份数据

```shell

docker run --rm -ti elasticdump/elasticsearch-dump \
  --input=http://192.168.0.1:9200/operationlog \
  --output=http://192.168.0.2:9200/operationlog \
  --type=data
  
  
docker run --rm -ti -v /home/es-data/${date}:/tmp elasticdump/elasticsearch-dump \
  --input=http://192.168.0.1:9200/operationlog \
  --output=/tmp/operationlog.json \
  --type=data
 
```
通过 policy 管理索引 以下策略文件 默认三个备份 ，30天两个备份 ，60天一个备份，90天删除

```json
{
    "policy": {
        "policy_id": "logs_policy",
        "description": "A simple default policy that changes the replica count between hot and cold states.",
        "last_updated_time": 1622794817200,
        "schema_version": 1,
        "error_notification": null,
        "default_state": "hot",
        "states": [
            {
                "name": "hot",
                "actions": [
                    {
                        "replica_count": {
                            "number_of_replicas": 3
                        }
                    },
                    {
                        "rollover": {
                            "min_size": "10gb",
                            "min_doc_count": 10000,
                            "min_index_age": "30d"
                        }
                    }
                ],
                "transitions": [
                    {
                        "state_name": "cold",
                        "conditions": {
                            "min_index_age": "30d"
                        }
                    }
                ]
            },
            {
                "name": "cold",
                "actions": [
                    {
                        "replica_count": {
                            "number_of_replicas": 2
                        }
                    }
                ],
                "transitions": [
                    {
                        "state_name": "warm",
                        "conditions": {
                            "min_index_age": "60d"
                        }
                    }
                ]
            },
            {
                "name": "warm",
                "actions": [
                    {
                        "replica_count": {
                            "number_of_replicas": 1
                        }
                    }
                ],
                "transitions": [
                    {
                        "state_name": "delete",
                        "conditions": {
                            "min_index_age": "90d"
                        }
                    }
                ]
            },
            {
                "name": "delete",
                "actions": [
                    {
                        "delete": {}
                    }
                ],
                "transitions": []
            }
        ],
        "ism_template": null
    }
}

```

设置Index template

我们可以通过如下的方法来建立template:
```
PUT _template/datastream_template
{
"index_patterns": ["logs*"],                 
"settings": {
"number_of_shards": 1,
"number_of_replicas": 1,
"index.lifecycle.name": "logs_policy",
"index.routing.allocation.require.data": "hot",
"index.lifecycle.rollover_alias": "logs"    
}

```

这里的意思是所有以logs开头的index都需要遵循这个规律。这里定义了rollover的alias为“logs ”。
这在我们下面来定义。同时也需要注意的是"index.routing.allocation.require.data": "hot"。
这个定义了我们需要indexing的node的属性是hot。请看一下我们上面的policy里定义的有一个叫做phases里的，
它定义的是"hot"。在这里我们把所有的logs*索引都置于hot属性的node里。在实际的使用中，
hot属性的index一般用作indexing。我们其实还可以定义一些其它phase，比如warm，
这样可以把我们的用作搜索的index置于warm的节点中。这里就不一一描述了。

参考信息

https://github.com/terascope/teraslice


https://github.com/hhko/Learning/blob/58c5cc7216d96e851f984b08134c20728089ad0c/1.Tutorials/OpenSearch/OpenSearch_%EC%BB%A8%ED%85%8C%EC%9D%B4%EB%84%88_%EC%9D%B4%EB%AF%B8%EC%A7%80_%EB%A7%8C%EB%93%A4%EA%B8%B0.md