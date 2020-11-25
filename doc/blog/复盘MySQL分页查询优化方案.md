# 一、前言

MySQL分页查询作为Java面试的一道高频面试题，这里有必要实践一下，毕竟实践出真知。
很多同学在做测试时苦于没有海量数据，官方其实是有一套测试库的。

# 二、模拟数据

这里模拟数据分2种情况导入，如果只是需要数据测试下，那么推荐官方数据。如果官方数据满足不了需求的话，那么我们自己模拟数据。

## 1. 导入官方测试库

下载 [官方数据库文件](https://launchpad.net/test-db) 或者在 [github](https://github.com/datacharmer/test_db) 上下载。

该测试库含有6个表。

![](https://gitee.com/idea360/oss/raw/master/images/employees.png)

首先进入 `employees_db`, 执行导入数据指令

```bash
mysql -uroot -proot -t < employees.sql
```

有些环境可能会报错

```
ERROR 1193 (HY000) at line 38: Unknown system variable 'storage_engine'
```

连接mysql查看默认引擎，发现不是本地环境的问题。

```mysql
mysql> show variables like '%engine%';
+----------------------------------+--------+
| Variable_name                    | Value  |
+----------------------------------+--------+
| default_storage_engine           | InnoDB |
| default_tmp_storage_engine       | InnoDB |
| disabled_storage_engines         |        |
| internal_tmp_disk_storage_engine | InnoDB |
+----------------------------------+--------+
4 rows in set (0.01 sec)
```

修改 `employees.sql` 脚本

```mysql
   set default_storage_engine = InnoDB;
-- set storage_engine = MyISAM;
-- set storage_engine = Falcon;
-- set storage_engine = PBXT;
-- set storage_engine = Maria;

select CONCAT('storage engine: ', @@default_storage_engine) as INFO;
```

再次执行发现导入成功

```bash
➜  employees_db mysql -uroot -proot -t < employees.sql
mysql: [Warning] Using a password on the command line interface can be insecure.
+-----------------------------+
| INFO                        |
+-----------------------------+
| CREATING DATABASE STRUCTURE |
+-----------------------------+
+------------------------+
| INFO                   |
+------------------------+
| storage engine: InnoDB |
+------------------------+
+---------------------+
| INFO                |
+---------------------+
| LOADING departments |
+---------------------+
+-------------------+
| INFO              |
+-------------------+
| LOADING employees |
+-------------------+
+------------------+
| INFO             |
+------------------+
| LOADING dept_emp |
+------------------+
+----------------------+
| INFO                 |
+----------------------+
| LOADING dept_manager |
+----------------------+
+----------------+
| INFO           |
+----------------+
| LOADING titles |
+----------------+
+------------------+
| INFO             |
+------------------+
| LOADING salaries |
+------------------+
```

验证结果(配置修改同上)

```mysql
➜  employees_db mysql -uroot -proot -t < test_employees_sha.sql
mysql: [Warning] Using a password on the command line interface can be insecure.
+----------------------+
| INFO                 |
+----------------------+
| TESTING INSTALLATION |
+----------------------+
+--------------+------------------+------------------------------------------+
| table_name   | expected_records | expected_crc                             |
+--------------+------------------+------------------------------------------+
| departments  |                9 | 4b315afa0e35ca6649df897b958345bcb3d2b764 |
| dept_emp     |           331603 | d95ab9fe07df0865f592574b3b33b9c741d9fd1b |
| dept_manager |               24 | 9687a7d6f93ca8847388a42a6d8d93982a841c6c |
| employees    |           300024 | 4d4aa689914d8fd41db7e45c2168e7dcb9697359 |
| salaries     |          2844047 | b5a1785c27d75e33a4173aaa22ccf41ebd7d4a9f |
| titles       |           443308 | d12d5f746b88f07e69b9e36675b6067abb01b60e |
+--------------+------------------+------------------------------------------+
```

我们可以看到emp大概有33万条数据。

## 2. 存储过程导入模拟数据

这里我们可以选择存储过程批量导入。

首先创建一张表

```mysql
drop table if exists `user`;
create table `user`(
  `id` int unsigned auto_increment,
  `username` varchar(64) not null default '',
  `score` int(11) not null default 0,
    primary key(`id`)
)ENGINE = InnoDB;
```

创建存储过程

```mysql
DROP PROCEDURE IF EXISTS batchInsert;
delimiter $$  -- 声明存储过程结束符号
create procedure batchInsert() -- 创建存储过程
begin   -- 存储过程主体开始
    declare num int; -- 声明变量
    set num=1; -- 初始值
    while num<=3000000 do -- 循环条件
        insert into user(`username`,`score`) values(concat('user-', num),num); -- 执行语句
        set num=num+1; -- 循环变量自增
    end while; -- 结束循环
end$$ -- 存储过程主体结束
delimiter ; #恢复;表示结束

CALL batchInsert; -- 执行存储过程
```

可以看到测试300W条数据大概1046s插入完成。好吧，本来计划导入1000w的结果时间太长了。


# 三、常用的MySQL分页查询问题复现及优化。

我们拿现有的表 `user` 进行测试，该表有 300w 条数据。

## 1. 前置检查

首先查看下该表结构以及目前存在哪些索引

```mysql
mysql> desc user;
+----------+------------------+------+-----+---------+----------------+
| Field    | Type             | Null | Key | Default | Extra          |
+----------+------------------+------+-----+---------+----------------+
| id       | int(10) unsigned | NO   | PRI | NULL    | auto_increment |
| username | varchar(30)      | NO   |     |         |                |
| score    | int(11)          | NO   |     | 0       |                |
+----------+------------------+------+-----+---------+----------------+
3 rows in set (0.00 sec)

mysql> show index from user;
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
| user  |          0 | PRIMARY  |            1 | id          | A         |     2991886 |     NULL | NULL   |      | BTREE      |         |               |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+
1 row in set (0.00 sec)
```

可以看到只有 `id` 主键索引。

---

其次查看是否开启 `缓存` (避免查询缓存对执行效率产生影响)

```mysql
mysql> show variables like '%query_cache%';
+------------------------------+---------+
| Variable_name                | Value   |
+------------------------------+---------+
| have_query_cache             | YES     |
| query_cache_limit            | 1048576 |
| query_cache_min_res_unit     | 4096    |
| query_cache_size             | 1048576 |
| query_cache_type             | OFF     |
| query_cache_wlock_invalidate | OFF     |
+------------------------------+---------+
6 rows in set (0.00 sec)

mysql> show profiles;
Empty set, 1 warning (0.00 sec)
```

`have_query_cache` 和 `query_cache_type` 说明支持缓存但并未开启。
`show profiles` 显示为空，说明profiles功能是关闭的。

---

开启 `profiles`

```mysql
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> show profiles;
+----------+------------+-------------------+
| Query_ID | Duration   | Query             |
+----------+------------+-------------------+
|        1 | 0.00012300 | SET profiling = 1 |
+----------+------------+-------------------+
1 row in set, 1 warning (0.00 sec)
```



## 2. 无索引分页查询

一般我们最常用的分页查询的方式为 `order by` + `limit m,n` 的方式, 现在我们测试下分页性能


```mysql
select * from user order by score limit 0,10; -- 10 rows in set (0.65 sec)
select * from user order by score limit 10000,10; -- 10 rows in set (0.83 sec)
select * from user order by score limit 100000,10; -- 10 rows in set (1.03 sec)
select * from user order by score limit 1000000,10; -- 10 rows in set (1.14 sec)
```

这里我们确认下是否用到了索引

```mysql
mysql> explain select * from user order by score limit 1000000,10;
+----+-------------+-------+------------+------+---------------+------+---------+------+---------+----------+----------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows    | filtered | Extra          |
+----+-------------+-------+------------+------+---------------+------+---------+------+---------+----------+----------------+
|  1 | SIMPLE      | user  | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 2991995 |   100.00 | Using filesort |
+----+-------------+-------+------------+------+---------------+------+---------+------+---------+----------+----------------+
1 row in set, 1 warning (0.00 sec)
```

可以看到确实没有用到索引，全表扫描100W数据分页大概需要1.14s的时间。


## 3. 有索引分页查询

```mysql
select * from user order by id limit 10000,10; -- 10 rows in set (0.01 sec)
select * from user order by id limit 1000000,10; -- 10 rows in set (0.18 sec)
select * from user order by id limit 2000000,10; -- 10 rows in set (0.35 sec)
```

该查询用到了主键索引，所以查询效率比较高。
可以看到，当数据量变大时，查询效率明显下降。

这里我们确认下是否使用到了索引

```mysql
mysql> explain select * from user order by id limit 2000000,10;
+----+-------------+-------+------------+-------+---------------+---------+---------+------+---------+----------+-------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows    | filtered | Extra |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+---------+----------+-------+
|  1 | SIMPLE      | user  | NULL       | index | NULL          | PRIMARY | 4       | NULL | 2000010 |   100.00 | NULL  |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+---------+----------+-------+
1 row in set, 1 warning (0.00 sec)
```

可以看到用了全索引扫描，共查询了2000010行数据。


## 4. 优化

我们根据MYSQL自带的一种query诊断分析工具查看下sql语句执行各个操作的耗时详情。可以看到查询获取到的2000010条记录都返回给客户端了，耗时主要集中在Sending data阶段。但是客户端只需要10条数据，我们能否只给客户端返回10条数据呢？

```mysql
mysql> show profiles;
+----------+------------+---------------------------------------------------------+
| Query_ID | Duration   | Query                                                   |
+----------+------------+---------------------------------------------------------+
|        1 | 0.00012300 | SET profiling = 1                                       |
|        2 | 0.00009200 | SET profiling = 1                                       |
|        3 | 0.35689500 | select * from user order by id limit 2000000,10         |
|        4 | 0.00023900 | explain select * from user order by id limit 2000000,10 |
+----------+------------+---------------------------------------------------------+
4 rows in set, 1 warning (0.00 sec)

mysql> show profile for query 3;
+----------------------+----------+
| Status               | Duration |
+----------------------+----------+
| starting             | 0.000071 |
| checking permissions | 0.000007 |
| Opening tables       | 0.000012 |
| init                 | 0.000017 |
| System lock          | 0.000008 |
| optimizing           | 0.000005 |
| statistics           | 0.000024 |
| preparing            | 0.000016 |
| Sorting result       | 0.000004 |
| executing            | 0.000003 |
| Sending data         | 0.356653 |
| end                  | 0.000013 |
| query end            | 0.000005 |
| closing tables       | 0.000008 |
| freeing items        | 0.000019 |
| cleaning up          | 0.000030 |
+----------------------+----------+
16 rows in set, 1 warning (0.00 sec)
```



**网上的优化方案**: 子查询 + 覆盖索引

```mysql
mysql> select * from user where id > (select id from user order by id limit 2000000, 1) limit 10;
+---------+--------------+---------+
| id      | username     | score   |
+---------+--------------+---------+
| 2000002 | user-2000002 | 2000002 |
| 2000003 | user-2000003 | 2000003 |
| 2000004 | user-2000004 | 2000004 |
| 2000005 | user-2000005 | 2000005 |
| 2000006 | user-2000006 | 2000006 |
| 2000007 | user-2000007 | 2000007 |
| 2000008 | user-2000008 | 2000008 |
| 2000009 | user-2000009 | 2000009 |
| 2000010 | user-2000010 | 2000010 |
| 2000011 | user-2000011 | 2000011 |
+---------+--------------+---------+
10 rows in set (0.29 sec)

mysql> explain select * from user where id > (select id from user order by id limit 2000000, 1) limit 10;
+----+-------------+-------+------------+-------+---------------+---------+---------+------+---------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows    | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+---------+----------+-------------+
|  1 | PRIMARY     | user  | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL | 1495997 |   100.00 | Using where |
|  2 | SUBQUERY    | user  | NULL       | index | NULL          | PRIMARY | 4       | NULL | 2000001 |   100.00 | Using index |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+---------+----------+-------------+
2 rows in set, 1 warning (0.30 sec)
```

然而并没有提升查询性能。没看到问题出在哪里呢？从执行计划可以看出，索引和我们期望是一致的。rows这里检索了很多行。单独看下子查询

```mysql
mysql> select id from user order by id limit 2000000, 1;
+---------+
| id      |
+---------+
| 2000001 |
+---------+
1 row in set (0.29 sec)

mysql> explain select id from user order by id limit 2000000, 1;
+----+-------------+-------+------------+-------+---------------+---------+---------+------+---------+----------+-------------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows    | filtered | Extra       |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+---------+----------+-------------+
|  1 | SIMPLE      | user  | NULL       | index | NULL          | PRIMARY | 4       | NULL | 2000001 |   100.00 | Using index |
+----+-------------+-------+------------+-------+---------------+---------+---------+------+---------+----------+-------------+
1 row in set, 1 warning (0.00 sec)
```

这里可以看出子查询即使走了覆盖索引，依旧消耗3s左右，我觉得这就是正常的索引IO花费的时间。没找到官方测试数据做对比，以及MySQL一次IO查询花费的时间来做对比。

理论上int主键一页可以存储1000个键,根常驻内存,那么B+Tree第二层大概100W个键,测试数据在200W的分页，理论上需要2次IO可以找到数据。2次IO花费的时间是3s的话，1次应该在1.5s左右, 我们查询下99W左右的分页看是否符合假想。

```mysql
mysql> select id from user order by id limit 990000,1;
+--------+
| id     |
+--------+
| 990001 |
+--------+
1 row in set (0.15 sec)
```

所以这里笔者大胆的猜想结果是正常开销

# 四、最后

本来想复盘网上的分页优化方案是否可靠，但是预期结果还是有区别。希望聪明的读者有不同见解的不吝赐教。公众号里有笔者的微信二维码。