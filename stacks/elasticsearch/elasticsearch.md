# Elasticsearch

- 分布式实时文件存储，每个字段都被索引并可被搜索
- 分布式实时分析搜索引擎
- 可扩展至上百台服务器，处理PB级结构化和分结构化数据

## 集群，节点，分片

- 节点是一个运行着的Elasticsearch实例
- 集群是一组具有相同cluster.name节点集合，共享数据并提供故障转移和扩展功能

elaticsearch存储文档，对文档进行索引、搜索、排序、过滤

索引(indice) --> Types --> Documents --> Fields

## 分片，复制，故障转移

- 纵向扩展：
- 横向扩展：增加节点来均摊负载和可靠性

用户可以和集群中的任意节点通信，每个节点都知道文档存在 哪个节点上，他们可以转发请求到相应节点上。访问的节点负责收集各个节点返回的数据，最后一起返回给客户端

### 集群健康

- green     所有主要分片和复制分片都可用
- yellow    所有主要分片可用，但不是所有分片都可用
- red       不是所有的主要分片都可用

> get /_cluster/health

### 添加索引

索引： 一个存储关联数据的地方，指向一个或多个分片的逻辑命名空间
分片： 最小的工作单元，保存索引中所有数据的一部分（Lucene实例）

分片是存储数据的容器，一个Lucene实例，文档在分片中被索引，分片分配到集群中的节点上。当集群缩容或扩容时，Elasticsearch自动在节点间迁移分片，使集群保持平衡

### 分片

分片分为主分片和复制分片

- 主要分片（primary shard）,
- 复制分片（replica shard）

分片的最大容量取决于：

- 1. 硬件存储
- 2. 文档大小
- 3. 如何索引与查询文档
- 4. 期望的响应时间

复制分片是主分片的副本，防止硬件故障导致的数据丢失，同时可以提供读请求（搜索、从别的shard取回文档）



### 查看索引--列表
GET  _cat/indices/

curl  http://192.168.6.16:9200/_cat/indices/
curl  http://192.168.6.26:9200/_cat/indices/
curl  http://192.168.9.40:9200/_cat/indices/


curl -XDELETE http://<node-ip|hostname>:9200/<index-name>


curl -XDELETE http://192.168.6.172:9200/zipkin:span-2020-03-31

curl -XDELETE http://192.168.9.26:9200/zipkin:span-2020-04-25
curl -XDELETE http://192.168.9.40:9200/usermessage            

curl -XDELETE http://192.168.9.26:9200/zipkin:span-2020-04-1*
/usr/cqy/log


curl -XDELETE http://192.168.9.16:9200/zipkin:span-2020-04-26*


### 创建索引

一个索引默认5个分片

``` json
PUT /blogs
{
    "settings" : {
        "number_of_shards" : 3,
        "number_of_replicas" : 1
    }
}
```

### 动态改变复制分片数

``` json
PUT /blogs/_settings
{
    "number_of_replicas": 3
}
```

## 数据吞吐

使用api来创建、检索、更新、删除文档

### 文档： 根对象序列化成的JSON数据

> 元数据：

- _index    文档存储的地方
- _type     文档代表对象的类
- _id       文档唯一标识

每一个tyoe都有自己的映射（mapping）或者结构定义，所有类型下的文档被存储在同一个索引下，但是类型的映射会告诉Elasticsearch不同的文档如何被索引

### 自定义ID

``` json
PUT /{index}/{type}/{id}
{
    "field": "value",
    ...
}
```

### 自增Id

``` json
POST /website/blog/
{
"title": "My second blog entry",
"text": "Still trying this out...",
"date": "2014/01/01"
}
```

### 检索文档

GET /website/blog/123?pretty 

### 检索文档的一部分

GET /website/blog/123?_source=title,text

### 只返回_source字段，不包含元数据

GET /website/blog/123/_source

### 检查文档是否存在

HEAD /website/blog/123

### 更新整个文档

``` json
PUT /website/blog/123
{
"title": "My first blog entry",
"text": "I am starting to get the hang of this...",
"date": "2014/01/02"
}
```

### 创建新文档

1. PUT /website/blog/123?op_type=create
2. PUT /website/blog/123/_create

### 删除文档

DELETE /website/blog/123

### 更新使用内部版本号

PUT /website/blog/1?version=1

### 外部版本号

PUT /website/blog/2?version=5&version_type=external

### 文档局部更新

``` json
POST /website/blog/1/_update
{
"doc" : {
"tags" : [ "testing" ],
"views": 0
}
}
```

### 使用groove脚本

``` json
POST /website/blog/1/_update
{
"script" : "ctx._source.views+=1"
}
```

删除

``` json
POST /website/blog/1/_update
{
"script" : "ctx.op = ctx._source.views == count ? 'delete' : 'none'",
"params" : {
"count": 1
}
}
```

冲突时重试

``` json
POST /website/pageviews/1/_update?retry_on_conflict=5 
{
"script" : "ctx._source.views+=1",
"upsert": {
"views": 0
}
}
```

### 检索多个文档

``` json
GET /_mget
{
"docs" : [
{
"_index" : "website",
"_type" : "blog",
"_id" : 2
},
{
"_index" : "website",
"_type" : "pageviews",
"_id" : 1,
"_source": "views"
}
]
}
```

``` json
GET /website/blog/_mget
{
    "docs" : [
        { "_id" : 2 },
        { "_type" : "pageviews", "_id" : 1 }
    ]
}
```

``` json
GET /website/blog/_mget
{
    "ids" : [ "2", "1" ]
}
```

## 更新时批量操作

1. create
2. index
3. update
4. delete

在索引、创建、更新或删除时必须指定文档的_index，_type,_id

``` json
{ "delete": { "_index": "website", "_type": "blog", "_id": "123" }} <1>
{ "create": { "_index": "website", "_type": "blog", "_id": "123" }}
{ "title": "My first blog post" }
{ "index": { "_index": "website", "_type": "blog" }}
{ "title": "My second blog post" }
{ "update": { "_index": "website", "_type": "blog", "_id": "123", "_retry_on_conflict" : 3} }
{ "doc" : {"title" : "My updated blog post"} } <2>
```

### 同一个index

``` json
POST /website/_bulk
{ "index": { "_type": "log" }}
{ "event": "User logged in" }
```

### 同一个index,type

``` json
POST /website/log/_bulk
{ "index": {}}
{ "event": "User logged in" }
{ "index": { "_type": "blog" }}
{ "title": "Overriding the default type" }
```

``` json
{
    "query" : {
        "bool" : {
            "filter" : {
                "range" : {
                    "age" : { "gt" : 30 }
                }
            },
            "must" : {
                "match" : {
                    "last_name" : "smith"
                }
            }
        }
    }
}


