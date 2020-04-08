#Neo4j 查询语法

2016-11-11 18:22:16 三劫散仙 
分类专栏： Neo4j
版权声明：本文为博主原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接和本声明。
本文链接：https://blog.csdn.net/u010454030/article/details/53131229


cypher是neo4j官网提供的声明式查询语言，非常强大，用它可以完成任意的图谱里面的查询过滤，我们知识图谱的一期项目 基本开发完毕，后面会陆续总结学习一下neo4j相关的知识。今天接着上篇文章来看下neo4j的cpyher查询的一些基本概念和语法。

## 一，Node语法
在cypher里面通过用一对小括号()表示一个节点，它在cypher里面查询形式如下：

1，() 代表匹配任意一个节点

2, (node1) 代表匹配任意一个节点，并给它起了一个别名

3, (:Lable) 代表查询一个类型的数据

4, (person:Lable) 代表查询一个类型的数据，并给它起了一个别名

5, (person:Lable {name:"小王"}) 查询某个类型下，节点属性满足某个值的数据

6, (person:Lable {name:"小王",age:23})　节点的属性可以同时存在多个，是一个AND的关系

## 二，关系语法

关系用一对-组成，关系分有方向的进和出，如果是无方向就是进和出都查询

1,--> 指向一个节点

2,-[role]-> 给关系加个别名

3,-[:acted_in]-> 访问某一类关系

4,-[role:acted_in]-> 访问某一类关系，并加了别名

5,-[role:acted_in {roles:["neo","hadoop"]}]->

访问某一类关系下的某个属性的关系的数据

## 三，模式语法
模式语法是节点和关系查询语法的结合，通过模式语法我们可以进行我们想要的任意复杂的查询

(p1: Person:Actor {name:"tom"})-[role:acted_in {roles:["neo","actor"]}]-(m1:Movie {title:"water"})

##四, 模式变量

为了增加模块化和减少重复，cypher允许把模式的结果指定在一个变量或者别名中，方便后续使用或操作

path = (: Person)-[:ACTED_IN]->(:Movie)

path是结果集的抽象封装，有多个函数可以直接从path里面提取数据如：

nodes(path)：提取所有的节点

rels(path): 提取所有的关系 和relationships(path)相等

length(path): 获取路径长度

##五，条件

cypher语句也是由多个关键词组成，像SQL的

select name, count(*) from talbe where age=24 group by name having count(*) >2  order by count(*) desc
多个关键字组成的语法，cypher也非常类似，每个关键词会执行一个特定的task来处理数据

match: 查询的主要关键词

create: 类似sql里面的insert

filter，project，sort，page等都有对应的功能语句

通过组合上面的一些语句，我们可以写出非常强大复杂的语法，来查询我们想要检索的内容，cypher会 自动解析语法并优化执行。

一些实际的用法例子：

1,创建
create (:Movie {title:"驴得水",released:2016})  return p;
执行成功，在neo4j的web页面我们能看到下面的信息

+-------------------+
| No data returned. |
+-------------------+
Nodes created: 1
Properties set: 2
Labels added: 1
当然cypher也可以一次创建多个数据，并同时添加关系

2,查询
match (p: Person) return p; 查询Person类型的所有数据

match (p: Person {name:"sun"}) return p; 查询名字等于sun的人

match( p1: Person {name:"sun"} )-[rel:friend]->(p2) return p2.name , p2.age 查询sun的朋友的名字和年龄

match (old) ... create (new) create (old)-[rel:dr]->(new) return new 对已经存在的节点和新建的节点建立关系

3,查询或更新
merge 语法可以对已经存在的节点不做改变，对变化的部分会合并

MERGE (m:Movie { title:"Cloud Atlas" })
ON CREATE SET m.released = 2012
RETURN m
merge .... on create set ... return 语法支持合并更新

4,筛选过滤
cypher过滤也是用的和SQL一样的关键词where

match (p1: Person) where p1.name="sun" return p1;

等同下面的

match (p1: Person {name:"sun"}) return p1

注意where条件里面支持 and ， or ，xor，not等boolean运算符，在json串里面都是and

除此之外，where里面查询还支持正则查询

match (p1: Person)-[r:friend]->(p2: Person) 
where p1.name=~"K.+" or p2.age=24 or "neo" in r.rels 
return p1,r,p2
关系过滤匹配使用not

MATCH (p:Person)-[:ACTED_IN]->(m)
WHERE NOT (p)-[:DIRECTED]->()
RETURN p,m
5，结果集返回
MATCH (p:Person)
RETURN p, p.name AS name, upper(p.name), coalesce(p.nickname,"n/a") AS nickname, { name: p.name,
  label:head(labels(p))} AS person
结果集返回做去重

match (n) return distinct n.name;
6,聚合函数
cypher支持count,sum,avg,min,max

match (: Person) return count(*)

聚合的时候null会被跳过 count 语法 支持 count( distinct role )

MATCH (actor:Person)-[:ACTED_IN]->(movie:Movie)<-[:DIRECTED]-(director:Person)
RETURN actor,director,count(*) AS collaborations
7,排序和分页
MATCH (a:Person)-[:ACTED_IN]->(m:Movie)
RETURN a,count(*) AS appearances
ORDER BY appearances DESC SKIP 3 LIMIT 10;
8, 收集聚合结果
MATCH (m:Movie)<-[:ACTED_IN]-(a:Person)
RETURN m.title AS movie, collect(a.name) AS cast, count(*) AS actors
9, union 联合
支持两个查询结构集一样的结果合并

MATCH (actor:Person)-[r:ACTED_IN]->(movie:Movie)
RETURN actor.name AS name, type(r) AS acted_in, movie.title AS title
UNION （ALL）
MATCH (director:Person)-[r:DIRECTED]->(movie:Movie)
RETURN director.name AS name, type(r) AS acted_in, movie.title AS title
10, with
with语句给cypher提供了强大的pipeline能力，可以一个或者query的输出，或者下一个query的输入 和return语句非常类似，唯一不同的是，with的每一个结果，必须使用别名标识。

通过这个功能，我们可以轻而易举的做到在查询结果里面在继续嵌套查询。

MATCH (person:Person)-[:ACTED_IN]->(m:Movie)
WITH person, count(*) AS appearances, collect(m.title) AS movies
WHERE appearances > 1
RETURN person.name, appearances, movies
注意在SQL里面，我们想过滤聚合结果，需要使用having语句但是在cypher里面我们可以配合with语句使用 where关键词来完成过滤

11，添加约束或者索引
唯一约束(使用merge来实现) CREATE CONSTRAINT ON (movie:Movie) ASSERT movie.title IS UNIQUE

添加索引(在图谱遍历时，快速找到开始节点),大幅提高查询遍历性能 CREATE INDEX ON :Actor(name)

添加测试数据：

CREATE (actor:Actor { name:"Tom Hanks" }),(movie:Movie { title:'Sleepless IN Seattle' }),
  (actor)-[:ACTED_IN]->(movie);
使用索引查询:

MATCH (actor:Actor { name: "Tom Hanks" })
RETURN actor;

-------

## 如何将大规模数据导入Neo4j
项目需要基于Neo4j开发，由于数据量较大（数千万节点），因此对当前数据插入的方法进行了分析和对比。

###常见数据插入方式概览

目前主要有以下几种数据插入方式：

Cypher CREATE 语句，为每一条数据写一个CREATE
Cypher LOAD CSV 语句，将数据转成CSV格式，通过LOAD CSV读取数据。
官方提供的Java API —— Batch Inserter
大牛编写的 Batch Import 工具
官方提供的 neo4j-import 工具
这些工具有什么不同呢？速度如何？适用的场景分别是什么？我这里根据我个人理解，粗略地给出了一个结果：

 	CREATE语句	LOAD CSV语句	Batch Inserter	Batch Import	Neo4j-import
适用场景	1 ~ 1w nodes	1w ~ 10 w nodes	千万以上 nodes	千万以上 nodes	千万以上 nodes
速度	很慢 (1000 nodes/s)	一般 (5000 nodes/s)	非常快 (数万 nodes/s)	非常快 (数万 nodes/s)	非常快 (数万 nodes/s)
优点	使用方便，可实时插入。	使用方便，可以加载本地/远程CSV；可实时插入。	速度相比于前两个，有数量级的提升	基于Batch Inserter，可以直接运行编译好的jar包；可以在已存在的数据库中导入数据	官方出品，比Batch Import占用更少的资源
缺点	速度慢	需要将数据转换成CSV	需要转成CSV；只能在JAVA中使用；且插入时必须停止neo4j	需要转成CSV；必须停止neo4j	需要转成CSV；必须停止neo4j；只能生成新的数据库，而不能在已存在的数据库中插入数据。
速度测试
下面是我自己做的一些性能测试：

1. CREATE 语句
这里每1000条进行一次Transaction提交

CREATE (:label {property1:value, property2:value, property3:value} )
11.5w nodes	18.5w nodes
100 s	160 s
2. LOAD CSV 语句
using periodic commit 1000
load csv from "file:///fscapture_screencapture_syscall.csv" as line
create (:label {a:line[1], b:line[2], c:line[3], d:line[4], e:line[5], f:line[6], g:line[7], h:line[8], i:line[9], j:line[10]})
这里使用了语句USING PERIODIC COMMIT 1000，使得每1000行作为一次Transaction提交。

11.5w nodes	18.5w nodes
21 s	39 s
3. Batch Inserter、Batch Import、Neo4j-import
我只测试了Neo4j-import，没有测试Batch Inserter和Batch Import，但是我估计他们的内部实现差不多，速度也处于一个数量级别上，因此这里就一概而论了。

neo4j-import需要在Neo4j所在服务器执行，因此服务器的资源影响数据导入的性能，我这里为JVM分配了16G的heap资源，确保性能达到最好。

sudo ./bin/neo4j-import --into graph.db --nodes:label path_to_csv.csv
11.5w nodes	18.5w nodes	150w nodes + 1431w edges	3113w nodes + 7793w edges
3.4 s	3.8 s	26.5 s	3 m 48 s
结论
如果项目刚开始，想要将大量数据导入数据库，Neo4j-import是最好的选择。
如果数据库已经投入使用，并且可以容忍Neo4j关闭一段时间，那么Batch Import是最好的选择，当然如果你想自己实现，那么你应该选择Batch Inserter
如果数据库已经投入使用，且不能容忍Neo4j的临时关闭，那么LOAD CSV是最好的选择。
最后，如果只是想插入少量的数据，且不怎么在乎实时性，那么请直接看Cypher语言。

### 其它的Tips

在LOAD CSV前面加上USING PERIODIC COMMIT 1000，1000表示每1000行的数据进行一次Transaction提交，提升性能。
建立index可以使得查询性能得到巨大提升。如果不建立index，则需要对每个node的每一个属性进行遍历，所以比较慢。 并且index建立之后，新加入的数据都会自动编入到index中。 注意index是建立在label上的，不是在node上，所以一个node有多个label，需要对每一个label都建立index。

-------

/var/lib/neo4j/import

home:         /var/lib/neo4j
config:       /var/lib/neo4j/conf
logs:         /logs
plugins:      /var/lib/neo4j/plugins
import:       /var/lib/neo4j/import
data:         /var/lib/neo4j/data
certificates: /var/lib/neo4j/certificates
run:          /var/lib/neo4j/run
  
  
neo4j清空所有数据

MATCH (e {name:"鱼暖暖"})

match (n:交易方) detach delete n 

MATCH (n:`交易项目`) detach delete n 


match (n:行业) detach delete n 

match (n:用户) detach delete n 

match (n:地区) detach delete n 

match (n:标的) detach delete n

match (n:标的物) detach delete n

asset_id:50f0df24dada404889195647448500d0

match (n:标的) WHERE n.asset_id = '50f0df24dada404889195647448500d0' RETURN n



match (n) detach delete n 
  
  MATCH (n:资产包项目) WHERE n.pro_id = '6ed707fc7ed74398aee17354626c95e5' RETURN n
  MATCH (n:交易项目) WHERE n.pro_id = {pro_id} RETURN n
  8181274851b741b9b09ac68510f7ae82
  
  
    MATCH (n:实物资产) WHERE n.asset_id = '8c72f5cdbfa0475b9ac1c6c5175aeed5' RETURN n
	
    MATCH (n:实物资产) WHERE n.asset_id = '23a95bed74d94f098845bf6eb8feff17' RETURN n
	
	 MATCH (n:交易项目) WHERE n.asset_id = '23a95bed74d94f098845bf6eb8feff17' RETURN n
	
	asset_id:23a95bed74d94f098845bf6eb8feff17
--------

neo4j-casual-cluster-quickstart
A demonstration of causal clustering using Docker, as described in GraphAware's https://graphaware.com/spring/2018/01/03/2018-01-03-casual-cluster-quickstart.html.

https://github.com/graphaware/neo4j-casual-cluster-quickstart/blob/master/README.md

--------
###企业版 3.5分支

```
docker run \
       --publish=7474:7474 --publish=7687:7687 \
       --volume=$HOME/neo4j/data:/data \
       graphfoundation/ongdb:3.5
```

Go to:  http://localhost:7474


https://github.com/graphfoundation/ongdb

--------
YANG-DB/yang-db

基本操作语句


1. "查"操作 , 查找 id 属性 为 501的节点:

```
MATCH (r)
WHERE id(r) = 501
RETURN r
```

2. "改"操作, 更改 id 属性 为 501的节点的 test 属性 的属性值为 "testtest"

```
MATCH (r)
WHERE id(r) = 501
SET r.test = "testtest"
```

3. "删"操作， 删除 id 属性 为 501的节点
这个样例只删除该节点，要想删和这个节点与其他节点的关系，请看下个例子。

```
MATCH (r)
WHERE id(r) = 501
DELETE r
RETURN r
```

4. 删除某个节点和这个节点与其他节点的关系
先创建两个节点。

```
MATCH (r)
WHERE id(r) = 501
DETACH DELETE r
RETURN r

```

















