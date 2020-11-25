# 系列文章

- CPU飙升(young gc频率过高导致)
- 接口响应慢(减小gc的次数和减小单次gc的时间这两个维度来考虑;jmap分析内存泄露)
- 线程死锁
- OOM
- 内存泄露


# 何时需要调优

- Heap内存（老年代）持续上涨达到设置的最大内存值；
- Full GC 次数频繁；
- GC 停顿时间过长（超过1秒）；
- 应用出现OutOfMemory 等内存异常；
- 应用中有使用本地缓存且占用大量内存空间；
- 系统吞吐量与响应性能不高或下降。

# 调优目标是什么

- 延迟：GC低停顿和GC低频率；
- 低内存占用；
- 高吞吐量;

# OOM原因

1. 申请资源（内存）过小，不够用。
2. 申请资源太多，没有释放。
3. 申请资源过多，资源耗尽。比如：线程过多，线程内存过大等。

**排查申请资源问题**

1. 排查申请资源问题。

```
jmap -heap 11869 
```

2. 排查gc

```
jstat -gcutil 11938 1000 每秒输出一次gc的分代内存分配情况，以及gc时间
```

3. 查找最费内存的对象

```
jmap -histo:live 11869 | more
```

4. 确认资源是否耗尽

```
pstree 查看进程线程数量
netstat 查看网络连接数量
```

# 频繁YGC引起FullGC

1. Eden区分配过小

```
jstat -gc 1701 1000 5
jmap -heap 1701
```



# 如何分析CPU飙升的问题

可能是young gc频率过高导致

- top 找到最耗CPU进程
- top -Hp pid 找到该进程下最耗费cpu的线程
- printf “%x\n” 15332  转换16进制（转换后为0x3be4） 
- jstack 13525 |grep '0x3be4'  -C5 --color  //  打印进程堆栈 并通过线程id，过滤得到线程堆栈信息

# 如何分析OOM的问题

- jps
- jstack 19645
- jstack 19645 >t.log 存储进程信息
- jmap -histo 19645 查看内存信息
- jmap -dump:format=b,file=heap.bin 19645 dump内存信息到heap.bin文件
- jstat -gc 19645 jstat 监视垃圾回收（GC）时间，次数
- 分析heap.bin


# 如何分析线程死锁的问题

> -l : 除堆栈外，显示关于锁的附加信息

- top
- jps
- jstack -l pid


# 参考

- https://tech.meituan.com/2017/12/29/jvm-optimize.html

