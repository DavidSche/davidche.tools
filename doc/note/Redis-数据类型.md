# Redis数据类型

## 设计Key

### 分段设计法

使用冒号把 key 中要表达的多种含义分开表示，步骤如下：

1. 把表名转化为 key 前缀

2. 主键名（或其他常用于搜索的字段）

3. 主键值

4. 要存储的字段。

eg. 用户表（user）

| id   | Name  | email        |
| ---- | ----- | ------------ |
| 1    | admin | admin@qq.com |
| 2    | test  | test@qq.com  |

这个简单的表可能经常会有这个的需求：>根据用户 id 查询用户邮箱地址，可以选择把邮箱地址这个数据存到 redis 中：

```
set user:id:1:email 156577812@qq.com;
set user:id:2:email 156577812@qq.com;
```



## 数据类型

### String

#### 1.  简介

string 类型在 redis 中是二进制安全(binary safe)的,这意味着 string 值关心二进制的字符串，不关心具体格式，你可以用它存储 json 格式或 JPEG 图片格式的字符串。

#### 2. 数据模型

| Key  | value |
| ---- | ----- |
| K1   | V1    |
| K2   | V2    |

#### 3. 应用场景

- (1)存储mysql中某个字段的值

  把 key 设计为 表名：主键名：主键值：字段名

  eg.

  ```
  set user:id:1:email 156577812@qq.com
  set user:id:1:email 156577812@qq.com
  ```


- (2)存储json对象

  string 类型支持任何格式的字符串，应用最多的就是存储 json 或其他对象格式化的字符串。(这种场景下推荐使用 hash 数据类型)

  ```redis
  set user:id:1 '[{"id":1,"name":"zj","email":"156577812@qq.com"},{"id":1,"name":"zj","email":"156577812@qq.com"}]'
  ```

  

- (3)生成自增id

  当 redis 的 string 类型的值为整数形式时，redis 可以把它当做是整数一样进行自增（incr）自减（decr）操作。由于 redis 所有的操作都是原子性的，所以不必担心多客户端连接时可能出现的事务问题。

  

### Hash-字典

#### 1.  简介

hash 类型很像一个关系型数据库的数据表，hash 的 Key 是一个唯一值，Value 部分是一个 hashmap 的结构。hash特别适合用于存储对象。存储部分变更的数据，如用户信息等。

#### 2. 数据模型

| Key        | field                | Value |
| ---------- | -------------------- | ----- |
| cart:user1 | '深入理解java虚拟机' | 1     |
| cart:user1 | '数据结构与算法'     | 1     |

hash数据类型在存储上述类型的数据时具有比 string 类型更灵活、更快的优势，具体的说，使用 string 类型存储，必然需要转换和解析 json 格式的字符串，即便不需要转换，在内存开销方面，还是 hash 占优势。

#### 3. 应用场景

hash 类型十分适合存储对象类数据，相对于在 string 中介绍的把对象转化为 json 字符串存储，hash 的结构可以任意添加或删除‘字段名’，更加高效灵活。

比如购物车场景等。

```
hset cart:user:1 '深入理解java虚拟机' 1
hmset key1 field1 v1 field2 v2
```



### List

#### 1.  简介

list 是按照插入顺序排序的字符串链表，可以在头部和尾部插入新的元素（双向链表实现，两端添加元素的时间复杂度为 O(1)）。插入元素时，如果 key 不存在，redis 会为该 key 创建一个新的链表，如果链表中所有的元素都被移除，该 key 也会从 redis 中移除。

#### 2. 数据模型

常见操作时用 lpush 命令在 list 头部插入元素， 用 rpop 命令在 list 尾取出数据。

#### 3. 应用场景

- (1)消息队列

  redis 的 list 数据类型对于大部分使用者来说，是实现队列服务的最经济，最简单的方式。

- (2)最新内容

  因为 list 结构的数据查询两端附近的数据性能非常好，所以适合一些需要获取最新数据的场景，比如新闻类应用的 “最近新闻”。

### Set

#### 1.  简介

set 数据类型是一个集合（没有排序，不重复），可以对 set 类型的数据进行添加、删除、判断是否存在等操作（时间复杂度是 O(1) ）

set 集合不允许数据重复，如果添加的数据在 set 中已经存在，将只保留一份。

set 类型提供了多个 set 之间的聚合运算，如求交集、并集、补集，这些操作在 redis 内部完成，效率很高。

#### 2. 应用场景

set 类型的特点是——不重复且无序的一组数据，并且具有丰富的计算功能，在一些特定的场景中可以高效的解决一般关系型数据库不方便做的工作。

- (1). 共同好友列表

```
// 这里为了方便阅读，把 id 替换成姓名
sadd user:wade james melo paul kobe
sadd user:james wade melo paul kobe
sadd user:paul wade james melo kobe
sadd user:melo wade james paul kobe

// 获取 wade 和 james 的共同好友
sinter user:wade user:james
/* 输出：
 *      1) "kobe"
 *      2) "paul"
 *      3) "melo"
 */
 
 // 获取香蕉四兄弟的共同好友
 sinter user:wade user:james user:paul user:melo
 /* 输出：
 *      1) "kobe"
 */
 
 /*
     类似的需求还有很多 , 必须把每个标签下的文章 id 存到集合中，可以很容易的求出几个不同标签下的共同文章；
 把每个人的爱好存到集合中，可以很容易的求出几个人的共同爱好。 
 */
```





### Sorted set

#### 1.  简介

在 set 的基础上给集合中每个元素关联了一个分数，往有序集合中插入数据时会自动根据这个分数排序。

#### 2. 应用场景

- (1)排行榜

```
// 用元素的分数（score）表示与好友的亲密度
zadd user:kobe 80 james 90 wade  85 melo  90 paul

// 根据“亲密度”给好友排序
zrevrange user:kobe 0 -1

/**
 * 输出：
 *      1) "wade"
 *      2) "paul"
 *      3) "melo"
 *      4) "james"
 */
 
// 增加好友的亲密度
zincrby user:kobe 15 james

// 再次根据“亲密度”给好友排序
zrevrange user:kobe 0 -1

/**
 * 输出：
 *      1) "james"
 *      2) "wade"
 *      3) "paul"
 *      2) "melo"
 */
 
 //类似的需求还出现在根据文章的阅读量或点赞量对文章列表排序
```



### HyperLogLogs——做基数统计

#### 应用场景

- (1)统计UV数据

  进行 Redis Hyperloglog 的操作，我们可以使用以下三个命令：

  ```
  PFADD
  PFCOUNT
  PFMERGE
  ```

  我们用一个实际的例子来解释这些命令。比如，有这么个场景，用户登录到系统，我们需要在一小时内统计不同的用户。 因此，我们需要一个 key，例如 USERLOGIN:2019092818。 换句话说，我们要统计在 2019 年 09 月 28 日下午 18 点至 19 点之间发生用户登录操作的非重复用户数。对于将来的时间，我们也需要使用对应的 key 进行表示，比如 2019111100、2019111101、2019111102 等。

  我们假设，用户 A、B、C、D、E 和 F 在下午 18 点至 19 点之间登录了系统。

  ```
  127.0.0.1:6379> pfadd USER:LOGIN:2019092818 A
  (integer) 1
  127.0.0.1:6379> pfadd USER:LOGIN:2019092818 B C D E F
  (integer) 1
  127.0.0.1:6379>
  ```

  当进行计数时，你会得到预期的 6。

  ```
  127.0.0.1:6379> pfcount USER:LOGIN:2019092818
  (integer) 6
  ```

  

### Bitmaps

#### 简介

基础指令

```
SETBIT
GETBIT
BITCOUNT
BITPOS
BITOP
BITFIELD
```

字符串操作

```
SETBIT key offset value
```

#### 应用场景

- (1)这里举一个例子：储存用户在线状态

  这里只需要一个 key，然后把用户 ID 作为 offset，如果在线就设置为1，不在线就设置为 0

     ```
  //设置在线状态
  $redis->setBit online 0 1;
  
  //设置离线状态
  $redis->setBit online 0 0;
  
  //获取状态
  $redis->getBit online 0;
  
  //获取在线人数
  $redis->bitCount online;
     ```

  

- (2)布隆过滤器

  



### GeoHash

#### 简介

基础指令

```
GEOADD
GEOPOS
GEODIST
GEORADIUS
GEORADIUSBYMEMBER
GEOHASH
```

#### 实例

1. 添加经纬度信息

   ```
   geoadd cityGeo 116.405285 39.904989 "北京"
   geoadd cityGeo 121.472644 31.231706 "上海"
   ```

   

2. 查找指定key的经纬度信息

   ```
   127.0.0.1:6379> geopos cityGeo 北京
   1) 1) "116.40528291463851929"
      2) "39.9049884229125027"
   ```

   

3. 返回两个地方的距离，可以指定单位

   ```
   127.0.0.1:6379> geodist cityGeo 北京 上海
   "1067597.9668"
   127.0.0.1:6379> geodist cityGeo 北京 上海 km
   "1067.5980"
   ```

   

4. 根据给定的经纬度，返回半径不超过指定距离的元素

   ```
   georadius cityGeo 116.405285 39.904989 100 km WITHDIST WITHCOORD ASC COUNT 5
   ```

   