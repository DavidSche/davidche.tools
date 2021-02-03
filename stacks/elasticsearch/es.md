#
### 查看索引--列表
GET  _cat/indices/

curl  http://192.168.9.16:9200/_cat/indices/
curl  http://192.168.9.26:9200/_cat/indices/
curl  http://192.168.6.172:9200/_cat/indices/

curl  http://192.168.9.40:9200/_cat/indices/
curl -XDELETE http://192.168.9.40:9200/usermessage    

curl -XDELETE http://<node-ip|hostname>:9200/<index-name>


curl -XDELETE http://192.168.6.172:9200/zipkin:span-2021-01-19

curl -XDELETE http://192.168.9.26:9200/zipkin:span-2020-04-25
curl -XDELETE http://192.168.9.40:9200/usermessage            

curl -XDELETE http://192.168.9.26:9200/zipkin:span-2020-04-1*
/usr/cqy/log


curl -XDELETE http://192.168.9.16:9200/zipkin:span-2020-04-26*


## 查询操作
基本查询有两种语法：左边是一个简单的语法，你不能使用任何选项， 
右边是一个扩展。 大多数初学者头痛的DSL来自于：

```
GET _search
{
  "query": {
    "match": {
      "FIELD": "TEXT"
    }
  }
}
GET _search
{
  "query": {
    "match": {
      "FIELD": {
        "query": "TEXT",
        "OPTION": "VALUE"
      }
    }
  }
}
```

### 包含高亮、聚合、过滤器的完整的检索示例

``` json
GET /_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "title": "smith"
          }
        }
      ],
      "must_not": [
        {
          "match_phrase": {
            "title": "granny smith"
          }
        }
      ],
      "filter": [
        {
          "exists": {
            "field": "title"
          }
        }
      ]
    }
  },
  "aggs": {
    "my_agg": {
      "terms": {
        "field": "user",
        "size": 10
      }
    }
  },
  "highlight": {
    "pre_tags": [
      "<em>"
    ],
    "post_tags": [
      "</em>"
    ],
    "fields": {
      "body": {
        "number_of_fragments": 1,
        "fragment_size": 20
      },
      "title": {}
    }
  },
  "size": 20,
  "from": 100,
  "_source": [
    "title",
    "id"
  ],
  "sort": [
    {
      "_id": {
        "order": "desc"
      }
    }
  ]
}
```

### 普通检索

#### 多字段检索

``` json
"multi_match": {
  "query": "Elastic",
  "fields": ["user.*", "title^3"],
  "type": "best_fields"
}
```

#### bool检索

``` json
"bool": {
  "must": [],
  "must_not": [],
  "filter": [],
  "should": [],
  "minimum_should_match" : 1
}
```

#### 范围检索

``` json
"range": {
  "age": {
    "gte": 10,
    "lte": 20,
    "boost": 2
  }
}
```

### QueryString语法概述

检索所有的_all字段

``` bash
GET /_search?q=pony
```

### 1.3.2 包含运算符和包含boost精确检索的复杂检索

``` bsh
GET /_search?q=title:(joli OR code) AND author:"Damien Alexandre"^2
```

#### 1.3.3 使用通配符和特殊查询进行检索

``` bash
GET /_search?q=_exists_:title OR title:singl? noneOrAnyChar*cter
```

#### 1.3.4 模糊搜素和范围检索

``` bash
GET /_search?q=title:elastichurch~3 AND date:[2016-01-01 TO 2018-12-31]
```

#### 1.3.5 使用 DSL检索（不推荐用于用户搜索）：

``` json
GET /_search
{
  "query": {
    "query_string": {
      "default_field": "content",
      "query": "elastic AND (title:lucene OR title:solr)"
    }
  }
}
```

-------

## 索引操作

### 创建包含设置和mapping的索引

``` json
PUT /my_index_name
{
  "settings": {
    "number_of_replicas": 1,
    "number_of_shards": 3,
    "analysis": {},
    "refresh_interval": "1s"
  },
  "mappings": {
    "my_type_name": {
      "properties": {
        "title": {
          "type": "text",
          "analyzer": "english"
        }
      }
    }
  }
}
```

### 动态的更新设置

``` json
PUT /my_index_name/_settings
{
  "index": {
    "refresh_interval": "-1",
    "number_of_replicas": 0
  }
}
```

### 通过向类型添加字段更新索引

``` json
PUT /my_index_name/_mapping/my_type_name
{
  "my_type_name": {
    "properties": {
      "tag": {
        "type": "keyword"
      }
    }
  }
}
```

### 获取Mapping和设置

``` bash
GET /my_index_name/_mapping
GET /my_index_name/_settings
```

### 创建document

```
POST /my_index_name/my_type_name
{
  "title": "Elastic is funny",
  "tag": [
    "lucene"
  ]
}
```

### 创建或更新document

```
PUT /my_index_name/my_type_name/12abc
{
  "title": "Elastic is funny",
  "tag": [
    "lucene"
  ]
}
```

### 删除文档

```
DELETE /my_index_name/my_type_name/12abc
```

### 打开或关闭索引已节约内存和CPU

```
POST /my_index_name/_close
POST /my_index_name/_open
```

### 移除和创建别名

```
POST /_aliases
{
  "actions": [
    {
      "remove": {
        "index": "my_index_name",
        "alias": "foo"
      }
    },
    {
      "add": {
        "index": "my_index_name",
        "alias": "bar",
        "filter" : { "term" : { "user" : "damien" } }
      }
    }
  ]
}
```

### 列举别名

```
GET /_aliases
GET /my_index_name/_alias/*
GET /*/_alias/*
GET /*/_alias/foo
```

### 索引监控和信息

```
GET /my_index_name/_stats
GET /my_index_name/_segments
GET /my_index_name/_recovery?pretty&human
```

### 索引状态和管理

```
POST /my_index_name/_cache/clear
POST /my_index_name/_refresh
POST /my_index_name/_flush
POST /my_index_name/_forcemerge
POST /my_index_name/_upgrade
GET /my_index_name/_upgrade?pretty&human
```

-------

## 调试和部署

### 检索调试


#### 获取query操作到底做了什么？

```
GET /blog/post/_validate/query?explain
{
  "query": {
    "match": {
      "title": "Smith"
    }
  }
}
```

#### 获取文档是否匹配？

```
GET /blog/post/1/_explain
{
  "query": {
    "match": {
      "title": "Smith"
    }
  }
}
```

### 分析

#### 3.2.1 测试内容如何在文档中被标记？

```
GET /blog/_analyze?field=title&text=powerful
```

#### 3.2.2 测试分析器输出？

```
GET /_analyze?analyzer=english&text=powerful
```

------

## 集群管理和插件管理

###集群和节点信息

```
GET /_cluster/health?pretty
GET /_cluster/health?wait_for_status=yellow&timeout=50s
GET /_cluster/state
GET /_cluster/stats?human&pretty
GET /_cluster/pending_tasks
GET /_nodes
GET /_nodes/stats
GET /_nodes/nodeId1,nodeId2/stats
```

####  手动移动分片

索引1的分片移动到索引2

```
POST /_cluster/reroute
{
  "commands": [
    {
      "move": {
        "index": "my_index_name",
        "shard": 0,
        "from_node": "node1",
        "to_node": "node2"
      }
    },
    {
      "allocate": {
        "index": "my_index_name",
        "shard": 1,
        "node": "node3"
      }
    }
  ]
}
```
#### 更新设置

动态更新最小节点数。

```
PUT /_cluster/settings
{
  "persistent": {
    "discovery.zen.minimum_master_nodes": 3
  }
}

PUT /_cluster/settings
{
  "transient": {
    "discovery.zen.minimum_master_nodes": 2
  }
}
```

使分片失效，在rolling重启前有效。

```
PUT /_cluster/settings
{
    "transient" : {
        "cluster.routing.allocation.enable" : "none"
    }
}

PUT /_cluster/settings
{
    "transient" : {
        "cluster.routing.allocation.enable" : "all"
    }
}

```

------

## 数据备份

来源：
[https://github.com/elasticsearch-dump/elasticsearch-dump](https://github.com/elasticsearch-dump/elasticsearch-dump)

```shell

#!/bin/bash
#按照时间生成日志文件或日志目录
#定义datetime变量
datetime=`date +%Y%m%d_%H%M%S_%N |cut -b1-20`
date=$(date +%Y%m%d%H%M)
#输出datetime
echo $datetime
echo $date
#创建文件 使用touch命令
#touch log_${datetime}.log
#创建目录 使用mkdir命令
#首先判断目录是否存在，如果不存在则创建，存在则不再创建
if [ ! -d "/home/es-data/${date}" ]
then
#echo "目录不存在"
mkdir /home/es-data/${date}
fi
#在创建的目录下面创建日志文件
#touch ./log_${date}/log_${datetime}.log
docker run --rm -ti -v /home/es-data/${date}:/tmp elasticdump/elasticsearch-dump \
  --input=http://192.168.6.172:9200/usermessage \
  --output=/tmp/usermessage.json \
  --type=data
  
docker run --rm -ti -v /home/es-data/${date}:/tmp elasticdump/elasticsearch-dump \
  --input=http://192.168.6.172:9200/operationlog \
  --output=/tmp/operationlog.json \
  --type=data
echo "backup elasticsearch index: usermessage operationlog completed !"

##恢复数据
#docker run --rm -ti -v /home/es-data:/tmp elasticdump/elasticsearch-dump \
#  --input=/tmp/operationlog.json \
#  --output=http://192.168.9.71:9200/operationlog \
#  --type=data  

```









