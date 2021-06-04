# backup file 


```shell
#!/bin/bash
#按照时间生成日志文件或日志目录
#定义datetime变量
datetime=`date +%Y%m%d_%H%M%S_%N |cut -b1-20`
date=$(date +%Y%m%d)
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

```


```shell

PUT _ilm/policy/logs_policy
{
    "policy_id": "logs_policy",
    "description": "A simple default policy that changes the replica count between hot and cold states.",
    "last_updated_time": 1622792935706,
    "schema_version": 1,
    "error_notification": null,
    "default_state": "hot",
    "states": [
        {
            "name": "hot",
            "actions": [
                {
                    "replica_count": {
                        "number_of_replicas": 5
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
        ]
      }
#        --------------
    ],
    "ism_template": null
}


```