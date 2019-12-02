# Open Distro for Elasticsearch Docker image

来自亚马逊的 Elasticsearch 镜像，100% Apache 协议开源

## 下载镜像

[地址](https://hub.docker.com/r/amazon/opendistro-for-elasticsearch)

``` bash
docker pull amazon/opendistro-for-elasticsearch:0.8.0
docker pull amazon/opendistro-for-elasticsearch-kibana:0.8.0
```

> Open Distro for Elasticsearch images 使用 centos:7 作为基础镜像.

## 单节点运行命令

``` bash
docker run -p 9200:9200 -p 9600:9600 -e "discovery.type=single-node" amazon/opendistro-for-elasticsearch:0.8.0
```

使用以下命令发送请求来验证是否安装成功:

``` bash
curl -XGET https://localhost:9200 -u admin:admin --insecure
curl -XGET https://localhost:9200/_cat/nodes?v -u admin:admin --insecure
curl -XGET https://localhost:9200/_cat/plugins?v -u admin:admin --insecure
```

## 集群化安装

> 建议在4 GB RAM 以上的机器环境中运行.

使用以下部署文件来部署opendistro-for-elasticsearch 集群

``` yaml
version: '3'
services:
  odfe-node1:
    image: amazon/opendistro-for-elasticsearch:0.8.0
    container_name: odfe-node1
    environment:
      - cluster.name=odfe-cluster
      - bootstrap.memory_lock=true # along with the memlock settings below, disables swapping
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m" # minimum and maximum Java heap size, recommend setting both to 50% of system RAM
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - odfe-data1:/usr/share/elasticsearch/data
    ports:
      - 9200:9200
      - 9600:9600 # required for Performance Analyzer
    networks:
      - odfe-net
  odfe-node2:
    image: amazon/opendistro-for-elasticsearch:0.8.0
    container_name: odfe-node2
    environment:
      - cluster.name=odfe-cluster
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - discovery.zen.ping.unicast.hosts=odfe-node1
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - odfe-data2:/usr/share/elasticsearch/data
    networks:
      - odfe-net
  kibana:
    image: amazon/opendistro-for-elasticsearch-kibana:0.8.0
    container_name: odfe-kibana
    ports:
      - 5601:5601
    expose:
      - "5601"
    environment:
      ELASTICSEARCH_URL: https://odfe-node1:9200
    networks:
      - odfe-net

volumes:
  odfe-data1:
  odfe-data2:

networks:
  odfe-net:
```

> 如果要使用环境变量修改其中的参数信息，请使用 "大写字母" 和 "_" 的组合， (例如. 对于 elasticsearch.url, 使用 ELASTICSEARCH_URL).

## 配置 Elasticsearch

你可以使用自己的 elasticsearch.yml 文件来定制，通过 -v flag 参数来使用他它:

``` bash

docker run \
-p 9200:9200 -p 9600:9600 \
-e "discovery.type=single-node" \
-v /<full-path-to>/custom-elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
amazon/opendistro-for-elasticsearch:0.8.0

```

对于docker-compose.yml 中使用相对路径:

``` yaml
services:
  odfe-node1:
    volumes:
      - odfe-data1:/usr/share/elasticsearch/data
      - ./custom-elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
  odfe-node2:
    volumes:
      - odfe-data2:/usr/share/elasticsearch/data
      - ./custom-elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml
  kibana:
    volumes:
      - ./custom-kibana.yml:/usr/share/kibana/config/kibana.yml
```

## 重要设置

在生产环境, 确认你的 Linux 设置 vm.max_map_count 至少为 262144. 在 Open Distro for Elasticsearch Docker 镜像中, 它是默认设置. 可以通过以下命令来验证:

``` bash
cat /proc/sys/vm/max_map_count
```

如果要修改它比如增加它的数值，就只能必须进入到容器内来修改，你可以修改通过修改  /etc/sysctl.conf 文件增加下面的内容:

``` conf
vm.max_map_count=262144
```

然后运行命令 *sudo sysctl -p* 来重新加载生效.

上面的 docker-compose.yml 文件还包括几个重要设置: bootstrap.memory_lock=true, ES_JAVA_OPTS=-Xms512m -Xmx512m, and 9600:9600. 分别表示 禁用 memory swapping (along with memlock), 设置 Java heap (建议内存的1/2 half of system RAM)的大小, and 通过 9600 端口来进行性能分析.

## 运行自定义 plugins

创建一个 Dockerfile:

``` Dockerfile
FROM amazon/opendistro-for-elasticsearch:0.8.0
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch <plugin-name-or-url>

```

标准插件安装

``` bash
sudo bin/elasticsearch-plugin install https://d3g5vo6xdbdb9a.cloudfront.net/downloads/elasticsearch-plugins/opendistro-security/opendistro_security-0.8.0.0.zip
sudo bin/elasticsearch-plugin install https://d3g5vo6xdbdb9a.cloudfront.net/downloads/elasticsearch-plugins/opendistro-alerting/opendistro_alerting-0.8.0.0.zip
sudo bin/elasticsearch-plugin install https://d3g5vo6xdbdb9a.cloudfront.net/downloads/elasticsearch-plugins/opendistro-sql/opendistro_sql-0.8.0.0.zip
sudo bin/elasticsearch-plugin install https://d3g5vo6xdbdb9a.cloudfront.net/downloads/elasticsearch-plugins/performance-analyzer/opendistro_performance_analyzer-0.8.0.0.zip
```

使用以下命令来构建和运行镜像

``` bash 
docker build --tag=odfe-custom-plugin .
docker run -p 9200:9200 -p 9600:9600 -v /usr/share/elasticsearch/data odfe-custom-plugin
```

你也可以通过Dockerfile 来为Security plugin 使用你自己的 certificates , 和使用 -v argument 参数配置 Elasticsearch 类似:

``` Dockerfile 
FROM amazon/opendistro-for-elasticsearch:0.8.0
COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/
COPY --chown=elasticsearch:elasticsearch my-key-file.pem /usr/share/elasticsearch/config/
COPY --chown=elasticsearch:elasticsearch my-certificate-chain.pem /usr/share/elasticsearch/config/
COPY --chown=elasticsearch:elasticsearch my-root-cas.pem /usr/share/elasticsearch/config/

```

## 使用 Kibana

启动 Kibana 后, 可以通过 5601 端口来访问它. 例如 [localhost:5601](http://localhost:5601),
默认的用户名 admin and 和密码 admin.

- 选择使用默认提供的sample data 并添加 sample flight data.
- 选择 Discover and search for a few flights.
- 选择 Dashboard, [Flights] Global Flight Dashboard, 并等待加载成功.

[参考文档](https://opendistro.github.io/for-elasticsearch-docs/docs/kibana/)

[中文日志](https://aws.amazon.com/cn/blogs/china/iot-alerting-open-distro-for-elasticsearch/)

ELASTICSEARCH_HOSTS

services:
  kibana:
    image: docker.elastic.co/kibana/kibana:5.1.2
    volumes:
      - ./kibana.yml:/usr/share/kibana/config/kibana.yml
	  
	  
services:
  kibana:
    image: docker.elastic.co/kibana/kibana:5.1.2
    environment:
      SERVER_NAME: kibana.example.org
      ELASTICSEARCH_URL: http://elasticsearch.example.org	  



docker run -d --name kibana -e somenetwork -p 5601:5601 kibana:tag

docker run --name kibana5 -e ELASTICSEARCH_URL=http://192.168.5.151:9200 -p 5601:5601 -d  kibana5.4.1

openssh
root
passwd
CQY@mass%root2019

portainer
admin
CQY@mass2019
 