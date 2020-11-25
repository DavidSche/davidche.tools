
表结构
Student（s_id, sname, sage, ssex） 学生表 
Course（c_id, cname, t_id）课程表 
SC（s_id, c_id, score）成绩表 
Teacher（t_id，tname）教师表

建表语句
CREATE TABLE `student` (
  `s_id` int(11) DEFAULT NULL AUTO_INCREMENT,
  `sname` varchar(32) DEFAULT NULL,
  `sage` int(11) DEFAULT NULL,
  `ssex` varchar(8) DEFAULT NULL,
   PRIMARY KEY ( s_id )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `course` (
  `c_id` int(11) DEFAULT NULL,
  `cname` varchar(32) DEFAULT NULL,
  `t_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `sc` (
  `s_id` int(11) DEFAULT NULL,
  `c_id` int(11) DEFAULT NULL,
  `score` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `teacher` (
  `t_id` int(11) DEFAULT NULL,
  `tname` varchar(16) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


面试问题
1. select的结果可以当做一个表
查询“001”课程比“002”课程成绩高的所有学生的学号；

select a.s_id from (select s_id,score from SC where c_id='001') a,(select s_id,score 
  from SC where c_id='002') b 
  where a.score>b.score and a.s_id=b.s_id;

2. 聚集函数和groupby一起出现，where不能连用
查询平均成绩大于60分的同学的学号和平均成绩；

    select s_id,avg(score) 
    from sc 
    group by s_id having avg(score) >60; 

3. 连接查询+groupby
查询所有同学的学号、姓名、选课数、总成绩

select s.s_id, s.sname, count(c.c_id), sum(c.score)
from student s, sc c where s.s_id = c.s_id
group by s.s_id;

4. 子查询 in 、not in
查询没学过“叶平”老师课的同学的学号、姓名；

select Student.S#,Student.Sname 
from Student  
where s_id not in (
select distinct( SC.S_id) from SC,Course,Teacher 
where  SC.c_id=Course.c_id and 
Teacher.t_id=Course.t_id and Teacher.Tname='叶平'); 

查询至少有一门课与学号为“1001”的同学所学相同的同学的学号和姓名；

select distinct s_ic,sname from Student,SC where Student.s_id=SC.s_id and SC.c_id in (select c_id from SC where s_id='1001'); 

5. and 不能连接同一个字段
查询学过1并且也学过编号2课程的同学的学号、姓名； 
正确写法：

select s_id from sc where score = 90 and c_id in (1,2);

错误写法：

select s_id from sc where score = 90 and c_id = 1 and c_id = 2;

6. 查询同名同性学生名单，并统计同名人数
select sname,count(*) from Student group by sname having  count(*)>1;

7. Order by 多个字段
例如order by id， score desc 
首先会按照id降序排列，当id相同时，再按score降序排列

查询每门课程的平均成绩，结果按平均成绩升序排列，平均成绩相同时，按课程号降序排列

select c_id, avg(score) from sc GROUP BY c_id order by avg(score) , c_id desc;

8. group by多个字段
例如group by s_id， c_id 
表示属于s_id， 又属于c_id的，例如属于1号学生的，又属于2号课程的

工作流程： 
首先按照s_id分组，分组的结果再用c_id来分组

查询平均成绩大于85的所有学生的姓名和平均成绩；

select s.s_id, s.sname, avg(c.score) from student s, sc c
where s.s_id = c.s_id group by s.sname , s.sage having avg(score) > 80;

因为学生可能同名，所以group by s.sname , s.sage的作用就是，先按姓名分组，要是有重复的姓名，再按照性别分组。

9. MySQL不支持top，用limit，而且limit不能用于子查询
查询每门功成绩最好的前两名 
错误写法：

select s.s_id, s.sname , c.score from student s, sc c 
where s.s_id = c.s_id and score in(
select score from sc GROUP BY s_id order by score desc limit 2);

正确写法：

select s.s_id, s.sname , c.score from student s, sc c 
where s.s_id = c.s_id and score in(
select score from sc GROUP BY s_id order by score desc)
limit 2;
