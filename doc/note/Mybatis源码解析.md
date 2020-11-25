## Mybatis是什么

mybatis是一个ORM框架。它的作用就是通过Object进行sql查询，返回的结果也是封装好的Object。
所以我们可以把以上的流程抽象成Object-sql-Object的过程。
在java中对象是如何获取到它的变量然后拼装sql呢？很明显，这里用到了反射的知识。
那么mapper的定义只有接口，是如何完成复杂的sql查询呢？jdk动态代理。没错，这就是核心思想部分。

## 实现思路

1. 读取配置文件，建立连接。包括数据库配置、mybatis-xml、注解等，然后将配置文件解析封装到mapper中；
2. 创建SqlSession，搭建Configuration和Executor之间的桥梁。Configuration就是刚才的配置，Executor是sql执行器；
3. 创建Executor，封装JDBC操作数据库。负责执行 SQL 语句，并且封装结果集；
4. 创建MapperProxy，使用动态代理生成Mapper对象。调用Mapper中的方法执行查询。

## 参考

- https://aimanyeye.github.io/2019/05/22/2019-05-22-%E6%89%8B%E5%86%99Mybatis%E6%A1%86%E6%9E%B6/