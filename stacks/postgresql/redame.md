
# zombodb 使用说明

## 安装测试

运行脚本

创建扩展
CREATE EXTENSION zombodb;

创建表
CREATE TABLE products (
    id SERIAL8 NOT NULL PRIMARY KEY,
    name text NOT NULL,
    keywords varchar(64)[],
    short_summary text,
    long_description zdb.fulltext, 
    price bigint,
    inventory_count integer,
    discontinued boolean default false,
    availability_date date
);

插入测试数据

COPY products FROM PROGRAM 'curl https://raw.githubusercontent.com/zombodb/zombodb/master/TUTORIAL-data.dmp'

运行全文检索
docker run -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.0.0

创建索引

CREATE INDEX idxproducts 
                     ON products 
                  USING zombodb ((products.*))
                   WITH (url='http://192.168.5.105:9200/');

测试查询

SELECT * FROM products WHERE products ==> 'sports box';