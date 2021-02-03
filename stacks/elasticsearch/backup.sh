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