# JVM调优指令



## JVM常用配置参数

```
-Xms2g：初始化推大小为 2g；
-Xmx2g：堆最大内存为 2g；
-XX:NewRatio=4：设置年轻的和老年代的内存比例为 1:4；
-XX:SurvivorRatio=8：设置新生代 Eden 和 Survivor 比例为 8:2；
–XX:+UseParNewGC：指定使用 ParNew + Serial Old 垃圾回收器组合；
-XX:+UseParallelOldGC：指定使用 ParNew + ParNew Old 垃圾回收器组合；
-XX:+UseConcMarkSweepGC：指定使用 CMS + Serial Old 垃圾回收器组合；
-XX:+PrintGC：开启打印 gc 信息；
-XX:+PrintGCDetails：打印 gc 详细信息。
-XX:+HeapDumpOnOutOfMemoryError：  虚拟机在出现内存溢出异常时dump出当前内存堆转储快照以便事后进行分析
```



## jdk命令行工具

```text
jps: 显示系统内所有hotspot虚拟机进程
jstat: 用于收集Hotspot虚拟机各方面的运行参数。
jinfo: 显示虚拟机配置信息
jmap: 生成虚拟机内存转储快照
jhat: 用于分析heapdump文件，它会建立一个http/html服务器，让用户可以在浏览器上查看分析结果
jstack: 显示虚拟机的线程快照
```



## 1. jps

`jps`(JVM Process Status) 命令类似 UNIX 的 `ps` 命令。

### 命令帮助

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jps -help
usage: jps [-help]
       jps [-q] [-mlvV] [<hostid>]

Definitions:
    <hostid>:      <hostname>[:<port>]
```

### 参数说明

```
-l : 输出主类全名或jar路径
-q : 只输出LVMID
-m : 输出JVM启动时传递给main()的参数
-v : 输出JVM启动时显示指定的JVM参数
```

### 示例详解

```bash
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jps
25378 Jps
1701 idc-order-boot.jar
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jps -l
1701 target/idc-order-boot.jar
25391 sun.tools.jps.Jps
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jps -q
25410
1701
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jps -m
25425 Jps -m
1701 idc-order-boot.jar --spring.profiles.active=dev --server.port=8080
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jps -v
25440 Jps -Denv.class.path=.:/usr/java/jdk1.8.0_201/jre/lib/rt.jar:/usr/java/jdk1.8.0_201/lib/dt.jar:/usr/java/jdk1.8.0_201/lib/tools.jar -Dapplication.home=/usr/java/jdk1.8.0_201 -Xms8m
1701 idc-order-boot.jar
```



## 2. jstat

jstat（JVM Statistics Monitoring Tool） 使用于监视虚拟机各种运行状态信息的命令行工具。 它可以显示本地或者远程（需要远程主机提供 RMI 支持）虚拟机进程中的类信息、内存、垃圾收集、JIT 编译等运行数据，在没有 GUI，只提供了纯文本控制台环境的服务器上，它将是运行期间定位虚拟机性能问题的首选工具。

### 命令帮助

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -help
Usage: jstat -help|-options
       jstat -<option> [-t] [-h<lines>] <vmid> [<interval> [<count>]]

Definitions:
  <option>      An option reported by the -options option
  <vmid>        Virtual Machine Identifier. A vmid takes the following form:
                     <lvmid>[@<hostname>[:<port>]]
                Where <lvmid> is the local vm identifier for the target
                Java virtual machine, typically a process id; <hostname> is
                the name of the host running the target Java virtual machine;
                and <port> is the port number for the rmiregistry on the
                target host. See the jvmstat documentation for a more complete
                description of the Virtual Machine Identifier.
  <lines>       Number of samples between header lines.
  <interval>    Sampling interval. The following forms are allowed:
                    <n>["ms"|"s"]
                Where <n> is an integer and the suffix specifies the units as
                milliseconds("ms") or seconds("s"). The default units are "ms".
  <count>       Number of samples to take before terminating.
  -J<flag>      Pass <flag> directly to the runtime system.
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -options
-class
-compiler
-gc
-gccapacity
-gccause
-gcmetacapacity
-gcnew
-gcnewcapacity
-gcold
-gcoldcapacity
-gcutil
-printcompilation
```

### 参数说明

```
[option] : 操作参数
LVMID : 本地虚拟机进程ID
[interval] : 连续输出的时间间隔
[count] : 连续输出的次数
```



### option参数说明

| 选项              | 作用                                                         |
| ----------------- | ------------------------------------------------------------ |
| -class            | 监视类装载、卸载数量、总空间以及类装载所耗费的时间           |
| -gc               | 监视java堆状况，包括Eden区，2个servivor区、老年代、永久代等的容量、已用空间、GC时间合计等信息 |
| -gccapacity       | 监视内容与-gc基本相同，但输出主要关注java堆各个区域使用到的最大、最小空间 |
| -gcutil           | 监视内容与-gc基本相同，但输出主要关注已使用空间占总空间的百分比 |
| -gccause          | 与-gcutil功能一样，但是会额外输出导致上一次gc产生的原因      |
| -gcnew            | 监视新生代GC状况                                             |
| -gcnewcapacity    | 监视内容与-gcnew基本相同，输出主要关注使用到的最大最小空间   |
| -gcold            | 监视GC老年代状况                                             |
| -gcoldcapacity    | 监视内容与-gcold基本相同，输出主要关注使用到的最大最小空间   |
| -gcpermcapacity   | 输出永久代使用到的最大、最小空间                             |
| -compiler         | 输出JIT编译器编译过的方法、耗时等信息                        |
| -printcompilation | 输出已经被JIT编译的方法                                      |



### 示例详解

#### -class

监视类装载、卸载数量、总空间以及耗费的时间

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -class 1701
Loaded  Bytes  Unloaded  Bytes     Time
 14317 27168.2      140   209.1      25.95
```

说明

```
Loaded : 加载class的数量
Bytes : class字节大小
Unloaded : 未加载class的数量
Bytes : 未加载class的字节大小
Time : 加载时间
```



#### -compiler

输出JIT编译过的方法数量耗时等

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -compiler 1701
Compiled Failed Invalid   Time   FailedType FailedMethod
   13515      1       0   134.67          1 org/springframework/boot/loader/jar/Handler openConnection
```

说明

```
Compiled : 编译数量
Failed : 编译失败数量
Invalid : 无效数量
Time : 编译耗时
FailedType : 失败类型
FailedMethod : 失败方法的全限定名
```



#### -gc

监视java堆状况，包括Eden区，2个servivor区、老年代、永久代等的容量、已用空间、GC时间合计等信息

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -gc 1701 1000 5
 S0C    S1C    S0U    S1U      EC       EU        OC         OU       MC     MU    CCSC   CCSU   YGC     YGCT    FGC    FGCT     GCT
5888.0 5888.0  0.0    0.0   47168.0   4656.0   117740.0   48648.4   86952.0 82657.6 10672.0 9866.7    306    6.441  14      2.882    9.323
5888.0 5888.0  0.0    0.0   47168.0   4656.0   117740.0   48648.4   86952.0 82657.6 10672.0 9866.7    306    6.441  14      2.882    9.323
5888.0 5888.0  0.0    0.0   47168.0   4656.0   117740.0   48648.4   86952.0 82657.6 10672.0 9866.7    306    6.441  14      2.882    9.323
5888.0 5888.0  0.0    0.0   47168.0   4656.0   117740.0   48648.4   86952.0 82657.6 10672.0 9866.7    306    6.441  14      2.882    9.323
5888.0 5888.0  0.0    0.0   47168.0   4656.0   117740.0   48648.4   86952.0 82657.6 10672.0 9866.7    306    6.441  14      2.882    9.323
```

上述指令的意思是1701进程每隔1000ms输出一次gc情况，一共5次。



说明

C即Capacity 总容量，U即Used 已使用的容量

```
S0C : survivor0区的总容量
S1C : survivor1区的总容量
S0U : survivor0区已使用的容量
S1C : survivor1区已使用的容量
EC : Eden区的总容量
EU : Eden区已使用的容量
OC : Old区的总容量
OU : Old区已使用的容量
MC : 当前元空间的容量 (KB)
MU : Metaspace的使用 (KB)
CCSC: 压缩类空间大小
CCSU: 压缩类空间使用大小
YGC : 新生代垃圾回收次数
YGCT : 新生代垃圾回收时间
FGC : 老年代垃圾回收次数
FGCT : 老年代垃圾回收时间
GCT : 垃圾回收总消耗时间
```



#### -gccapacity

同-gc，不过还会输出Java堆各区域使用到的最大、最小空间

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -gccapacity 1701
 NGCMN    NGCMX     NGC     S0C   S1C       EC      OGCMN      OGCMX       OGC         OC       MCMN     MCMX      MC     CCSMN    CCSMX     CCSC    YGC    FGC
 10240.0 156992.0  58944.0 5888.0 5888.0  47168.0    20480.0   314048.0   117740.0   117740.0      0.0 1126400.0  86952.0      0.0 1048576.0  10672.0    306    14
```

说明

```
NGCMN : 新生代占用的最小空间
NGCMX : 新生代占用的最大空间
OGCMN : 老年代占用的最小空间
OGCMX : 老年代占用的最大空间
OGC：当前年老代的容量 (KB)
OC：当前年老代的空间 (KB)
PGCMN : perm占用的最小空间
PGCMX : perm占用的最大空间
```



#### -gcutils

监视内容与-gc基本相同，但输出主要关注已使用空间占总空间的百分比

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -gcutil 1701
  S0     S1     E      O      M     CCS    YGC     YGCT    FGC    FGCT     GCT
  0.00   0.00  11.78  41.32  95.06  92.45    306    6.441    14    2.882    9.323
```



#### -gccause

与-gcutil功能一样，但是会额外输出导致上一次gc产生的原因

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -gccause 1701
  S0     S1     E      O      M     CCS    YGC     YGCT    FGC    FGCT     GCT    LGCC                 GCC
  0.00   0.00  11.95  41.32  95.06  92.45    306    6.441    14    2.882    9.323 Heap Inspection Initiated GC No GC
```

说明

```
LGCC：最近垃圾回收的原因
GCC：当前垃圾回收的原因
```



#### -gcnew

统计新生代的行为

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -gcnew 1701
 S0C    S1C    S0U    S1U   TT MTT  DSS      EC       EU     YGC     YGCT
5888.0 5888.0    0.0    0.0  1  15 2080.0  47168.0   5656.6    306    6.441
```

说明

```
TT：Tenuring threshold(提升阈值)
MTT：最大的tenuring threshold
DSS：survivor区域大小 (KB)
```



#### -gcnewcapacity

新生代与其相应的内存空间的统计

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -gcnewcapacity 1701
  NGCMN      NGCMX       NGC      S0CMX     S0C     S1CMX     S1C       ECMX        EC      YGC   FGC
   10240.0   156992.0    58944.0  15680.0   5888.0  15680.0   5888.0   125632.0    47168.0   306    14
```

说明

```
NGC:当前年轻代的容量 (KB)
S0CMX:最大的S0空间 (KB)
S0C:当前S0空间 (KB)
ECMX:最大eden空间 (KB)
EC:当前eden空间 (KB)
```



#### -gcold

统计旧生代的行为

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -gcold 1701
   MC       MU      CCSC     CCSU       OC          OU       YGC    FGC    FGCT     GCT
 86952.0  82657.6  10672.0   9866.7    117740.0     48648.4    306    14    2.882    9.323
```



#### -gcoldcapacity

统计旧生代的大小和空间

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -gcoldcapacity 1701
   OGCMN       OGCMX        OGC         OC       YGC   FGC    FGCT     GCT
    20480.0    314048.0    117740.0    117740.0   306    14    2.882    9.323
```



#### -gcmetacapacity

元空间统计

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -gcmetacapacity 1701
   MCMN       MCMX        MC       CCSMN      CCSMX       CCSC     YGC   FGC    FGCT     GCT
       0.0  1126400.0    86952.0        0.0  1048576.0    10672.0   306    14    2.882    9.323
```



#### -printcompilation

hotspot编译方法统计

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstat -printcompilation 1701
Compiled  Size  Type Method
   13515     22    1 java/util/ResourceBundle$CacheKey getLoader
```

说明

```
Compiled：被执行的编译任务的数量
Size：方法字节码的字节数
Type：编译类型
Method：编译方法的类名和方法名。类名使用"/" 代替 "." 作为空间分隔符. 方法名是给出类的方法名. 格式是一致于HotSpot - XX:+PrintComplation 选项
```



## 3. jmap

`jmap`（Memory Map for Java）命令用于生成堆转储快照。 如果不使用 `jmap` 命令，要想获取 Java 堆转储，可以使用 `“-XX:+HeapDumpOnOutOfMemoryError”` 参数，可以让虚拟机在 OOM 异常出现之后自动生成 dump 文件，Linux 命令下可以通过 `kill -3` 发送进程退出信号也能拿到 dump 文件。

`jmap` 的作用并不仅仅是为了获取 dump 文件，它还可以查询 finalizer 执行队列、Java 堆和永久代的详细信息，如空间使用率、当前使用的是哪种收集器等。和`jinfo`一样，`jmap`有不少功能在 Windows 平台下也是受限制的。

示例：将指定应用程序的堆快照输出到桌面。后面，可以通过 jhat、Visual VM 等工具分析该堆文件。



### 命令帮助

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jmap -help
Usage:
    jmap [option] <pid>
        (to connect to running process)
    jmap [option] <executable <core>
        (to connect to a core file)
    jmap [option] [server_id@]<remote server IP or hostname>
        (to connect to remote debug server)

where <option> is one of:
    <none>               to print same info as Solaris pmap
    -heap                to print java heap summary
    -histo[:live]        to print histogram of java object heap; if the "live"
                         suboption is specified, only count live objects
    -clstats             to print class loader statistics
    -finalizerinfo       to print information on objects awaiting finalization
    -dump:<dump-options> to dump java heap in hprof binary format
                         dump-options:
                           live         dump only live objects; if not specified,
                                        all objects in the heap are dumped.
                           format=b     binary format
                           file=<file>  dump heap to <file>
                         Example: jmap -dump:live,format=b,file=heap.bin <pid>
    -F                   force. Use with -dump:<dump-options> <pid> or -histo
                         to force a heap dump or histogram when <pid> does not
                         respond. The "live" suboption is not supported
                         in this mode.
    -h | -help           to print this help message
    -J<flag>             to pass <flag> directly to the runtime system
```

### 参数详解

| 选项           | 作用                                                         |
| -------------- | ------------------------------------------------------------ |
| -dump          | 生成java堆转储快照。格式为:-dump:[live, ]format=b, file=,其中live子参数说明是否只dump出存活的对象 |
| -finalizerinfo | 显示在finalizer线程执行finalize方法的对象，只在linux平台下有效 |
| -heap          | 显示java堆详细信息，如使用哪些回收器、参数配置、分代状况等。只在linux平台下有效 |
| -histo         | 显示堆中对象统计信息，包括类、实例数量、合计容量             |
| -permstat      | 以Classloader为统计口径显示永久代内存状态。只在linux平台下有效 |
| -F             | 当虚拟机进程对-dump选项没有响应时，可使用这个选项强制生成dump快照，只在linux平台下有效 |

### 示例详解

#### -dump

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jmap -dump:format=b,file=dump.hprof 1701
Dumping heap to /root/dump.hprof ...
File exists
```

dump堆到文件,format指定输出格式，live指明是活着的对象,file指定文件名。dump.hprof这个后缀是为了后续可以直接用MAT(Memory Anlysis Tool)打开。

#### -finalizerinfo

打印等待回收对象的信息

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jmap -finalizerinfo 1701
Attaching to process ID 1701, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.201-b09
Number of objects pending for finalization: 0
```

可以看到当前F-QUEUE队列中并没有等待Finalizer线程执行finalizer方法的对象。

#### -heap

打印heap的概要信息，GC使用的算法，heap的配置及wise heap的使用情况,可以用此来判断内存目前的使用情况以及垃圾回收情况

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jmap -heap 1701
Attaching to process ID 1701, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.201-b09

using thread-local object allocation.
Mark Sweep Compact GC 	//GC 方式  

Heap Configuration:	//堆内存初始化配置
   MinHeapFreeRatio         = 40	//对应jvm启动参数-XX:MinHeapFreeRatio设置JVM堆最小空闲比率
   MaxHeapFreeRatio         = 70	//对应jvm启动参数 -XX:MaxHeapFreeRatio设置JVM堆最大空闲比率
   MaxHeapSize              = 482344960 (460.0MB) //对应jvm启动参数-XX:MaxHeapSize=设置JVM堆的最大大小
   NewSize                  = 10485760 (10.0MB)	//对应jvm启动参数-XX:NewSize=设置JVM堆的‘新生代’的默认大小
   MaxNewSize               = 160759808 (153.3125MB)	//对应jvm启动参数-XX:MaxNewSize=设置JVM堆的‘新生代’的最大大小
   OldSize                  = 20971520 (20.0MB)  //对应jvm启动参数-XX:OldSize=<value>:设置JVM堆的‘老生代’的大小
   NewRatio                 = 2	//对应jvm启动参数-XX:OldSize=<value>:设置JVM堆的‘老生代’的大小
   SurvivorRatio            = 8	//对应jvm启动参数-XX:SurvivorRatio=设置年轻代中Eden区与Survivor区的大小比值 
   MetaspaceSize            = 21807104 (20.796875MB) //元空间初始大小
   CompressedClassSpaceSize = 1073741824 (1024.0MB)
   MaxMetaspaceSize         = 17592186044415 MB
   G1HeapRegionSize         = 0 (0.0MB)

Heap Usage:	//堆内存使用情况
New Generation (Eden + 1 Survivor Space):
   capacity = 54329344 (51.8125MB)
   used     = 7109688 (6.780326843261719MB)
   free     = 47219656 (45.03217315673828MB)
   13.086276175173401% used
Eden Space:  //Eden区内存分布
   capacity = 48300032 (46.0625MB) //Eden区总容量
   used     = 7109688 (6.780326843261719MB) //Eden区已使用
   free     = 41190344 (39.28217315673828MB) //Eden区剩余容量
   14.719841179401289% used
From Space:
   capacity = 6029312 (5.75MB)
   used     = 0 (0.0MB)
   free     = 6029312 (5.75MB)
   0.0% used
To Space:
   capacity = 6029312 (5.75MB)
   used     = 0 (0.0MB)
   free     = 6029312 (5.75MB)
   0.0% used
tenured generation: //老年代内存分布
   capacity = 120565760 (114.98046875MB)
   used     = 49815952 (47.50819396972656MB)
   free     = 70749808 (67.47227478027344MB)
   41.318490423815184% used

27371 interned Strings occupying 2942608 bytes.
```



#### -histo

打印堆的对象统计，包括对象数、内存大小等等 （因为在dump:live前会进行full gc，如果带上live则只统计活对象，因此不加live的堆大小要大于加live堆的大小 ）

```shell
jmap -histo:live 1701 | less
 num     #instances         #bytes  class name
----------------------------------------------
   1:          4358       18044728  [B
   2:         97247        8984344  [C
   3:         26579        2338952  java.lang.reflect.Method
   4:         96737        2321688  java.lang.String
   5:         58232        1863424  java.util.concurrent.ConcurrentHashMap$Node
   6:         22337        1824304  [Ljava.lang.Object;
   7:         15080        1675792  java.lang.Class
   8:         24027         961080  java.util.LinkedHashMap$Entry
   9:          6227         917008  [I
  10:         10500         797288  [Ljava.util.HashMap$Node;
  ...
```



## jhat

jhat(JVM Heap Analysis Tool)命令是与jmap搭配使用，用来分析jmap生成的dump，jhat内置了一个微型的HTTP/HTML服务器，生成dump的分析结果后，可以在浏览器中查看。在此要注意，一般不会直接在服务器上进行分析，因为jhat是一个耗时并且耗费硬件资源的过程，一般把服务器生成的dump文件复制到本地或其他机器上进行分析。

```shell
jhat [dumpfile]
```

**分析同样一个dump快照，MAT需要的额外内存比jhat要小的多的多，所以建议使用MAT来进行分析，当然也看个人偏好。**

具体排查时需要结合代码，观察是否大量应该被回收的对象在一直被引用或者是否有占用内存特别大的对象无法被回收。
**一般情况，会down到客户端用工具来分析**



## 5. jstack

`jstack`（Stack Trace for Java）命令用于生成虚拟机当前时刻的线程快照。线程快照就是当前虚拟机内每一条线程正在执行的方法堆栈的集合.

生成线程快照的目的主要是定位线程长时间出现停顿的原因，如线程间死锁、死循环、请求外部资源导致的长时间等待等都是导致线程长时间停顿的原因。线程出现停顿的时候通过`jstack`来查看各个线程的调用堆栈，就可以知道没有响应的线程到底在后台做些什么事情，或者在等待些什么资源。

### 命令帮助

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jstack -help
Usage:
    jstack [-l] <pid>
        (to connect to running process)
    jstack -F [-m] [-l] <pid>
        (to connect to a hung process)
    jstack [-m] [-l] <executable> <core>
        (to connect to a core file)
    jstack [-m] [-l] [server_id@]<remote server IP or hostname>
        (to connect to a remote debug server)

Options:
    -F  to force a thread dump. Use when jstack <pid> does not respond (process is hung)
    -m  to print both java and native frames (mixed mode)
    -l  long listing. Prints additional information about locks
    -h or -help to print this help message
```



### 参数详解

```
-F : 当正常输出请求不被响应时，强制输出线程堆栈
-l : 除堆栈外，显示关于锁的附加信息
-m : 如果调用到本地方法的话，可以显示C/C++的堆栈
```



### 示例详情

**下面是一个线程死锁的代码。我们下面会通过 `jstack` 命令进行死锁检查，输出死锁信息，找到发生死锁的线程。**

```java
package com.javaedge.concurrency.example.deadLock;


public class DeadLockDemo {
    private static Object resource1 = new Object();//资源 1
    private static Object resource2 = new Object();//资源 2

    public static void main(String[] args) {
        new Thread(() -> {
            synchronized (resource1) {
                System.out.println(Thread.currentThread() + "get resource1");
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(Thread.currentThread() + "waiting get resource2");
                synchronized (resource2) {
                    System.out.println(Thread.currentThread() + "get resource2");
                }
            }
        }, "线程 1").start();

        new Thread(() -> {
            synchronized (resource2) {
                System.out.println(Thread.currentThread() + "get resource2");
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println(Thread.currentThread() + "waiting get resource1");
                synchronized (resource1) {
                    System.out.println(Thread.currentThread() + "get resource1");
                }
            }
        }, "线程 2").start();
    }
}
```



线程 A 通过 synchronized (resource1) 获得 resource1 的监视器锁，然后通过`Thread.sleep(1000);`让线程 A 休眠 1s 为的是让线程 B 得到执行然后获取到 resource2 的监视器锁。线程 A 和线程 B 休眠结束了都开始企图请求获取对方的资源，然后这两个线程就会陷入互相等待的状态，这也就产生了死锁。



**通过 `jstack` 命令分析：**

```log
➜  Java-Concurrency-Progamming-Tutorial git:(master) ✗ jstack 26752
2020-02-08 15:07:20
Full thread dump Java HotSpot(TM) 64-Bit Server VM (25.211-b12 mixed mode):

"Attach Listener" #16 daemon prio=9 os_prio=31 tid=0x00007ff49814c800 nid=0x3207 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"DestroyJavaVM" #15 prio=5 os_prio=31 tid=0x00007ff495857800 nid=0xd03 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"线程 2" #14 prio=5 os_prio=31 tid=0x00007ff498836800 nid=0x5903 waiting for monitor entry [0x0000700005b7e000]
   java.lang.Thread.State: BLOCKED (on object monitor)
        at com.javaedge.concurrency.example.deadLock.DeadLockDemo.lambda$main$1(DeadLockDemo.java:34)
        - waiting to lock <0x000000076af91968> (a java.lang.Object)
        - locked <0x000000076af91978> (a java.lang.Object)
        at com.javaedge.concurrency.example.deadLock.DeadLockDemo$$Lambda$2/194494468.run(Unknown Source)
        at java.lang.Thread.run(Thread.java:748)

"线程 1" #13 prio=5 os_prio=31 tid=0x00007ff499876000 nid=0xa703 waiting for monitor entry [0x0000700005a7b000]
   java.lang.Thread.State: BLOCKED (on object monitor)
        at com.javaedge.concurrency.example.deadLock.DeadLockDemo.lambda$main$0(DeadLockDemo.java:19)
        - waiting to lock <0x000000076af91978> (a java.lang.Object)
        - locked <0x000000076af91968> (a java.lang.Object)
        at com.javaedge.concurrency.example.deadLock.DeadLockDemo$$Lambda$1/972765878.run(Unknown Source)
        at java.lang.Thread.run(Thread.java:748)

"Service Thread" #12 daemon prio=9 os_prio=31 tid=0x00007ff495820800 nid=0xa903 runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"C1 CompilerThread3" #11 daemon prio=9 os_prio=31 tid=0x00007ff49612f800 nid=0x5503 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"C2 CompilerThread2" #10 daemon prio=9 os_prio=31 tid=0x00007ff497014000 nid=0x3f03 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"C2 CompilerThread1" #9 daemon prio=9 os_prio=31 tid=0x00007ff497013800 nid=0x3d03 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"C2 CompilerThread0" #8 daemon prio=9 os_prio=31 tid=0x00007ff499880800 nid=0x3c03 waiting on condition [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"JDWP Command Reader" #7 daemon prio=10 os_prio=31 tid=0x00007ff497009000 nid=0x3a03 runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"JDWP Event Helper Thread" #6 daemon prio=10 os_prio=31 tid=0x00007ff497004800 nid=0x4203 runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"JDWP Transport Listener: dt_socket" #5 daemon prio=10 os_prio=31 tid=0x00007ff497003800 nid=0x4407 runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"Signal Dispatcher" #4 daemon prio=9 os_prio=31 tid=0x00007ff49902d800 nid=0x3803 runnable [0x0000000000000000]
   java.lang.Thread.State: RUNNABLE

"Finalizer" #3 daemon prio=8 os_prio=31 tid=0x00007ff497005800 nid=0x4b03 in Object.wait() [0x0000700004e54000]
   java.lang.Thread.State: WAITING (on object monitor)
        at java.lang.Object.wait(Native Method)
        - waiting on <0x000000076ab08ed0> (a java.lang.ref.ReferenceQueue$Lock)
        at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:144)
        - locked <0x000000076ab08ed0> (a java.lang.ref.ReferenceQueue$Lock)
        at java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:165)
        at java.lang.ref.Finalizer$FinalizerThread.run(Finalizer.java:216)

"Reference Handler" #2 daemon prio=10 os_prio=31 tid=0x00007ff496835000 nid=0x4d03 in Object.wait() [0x0000700004d51000]
   java.lang.Thread.State: WAITING (on object monitor)
        at java.lang.Object.wait(Native Method)
        - waiting on <0x000000076ab06bf8> (a java.lang.ref.Reference$Lock)
        at java.lang.Object.wait(Object.java:502)
        at java.lang.ref.Reference.tryHandlePending(Reference.java:191)
        - locked <0x000000076ab06bf8> (a java.lang.ref.Reference$Lock)
        at java.lang.ref.Reference$ReferenceHandler.run(Reference.java:153)

"VM Thread" os_prio=31 tid=0x00007ff49682e800 nid=0x2e03 runnable 

"GC task thread#0 (ParallelGC)" os_prio=31 tid=0x00007ff498803800 nid=0x2207 runnable 

"GC task thread#1 (ParallelGC)" os_prio=31 tid=0x00007ff498804000 nid=0x2103 runnable 

"GC task thread#2 (ParallelGC)" os_prio=31 tid=0x00007ff498804800 nid=0x1e03 runnable 

"GC task thread#3 (ParallelGC)" os_prio=31 tid=0x00007ff498805000 nid=0x2a03 runnable 

"GC task thread#4 (ParallelGC)" os_prio=31 tid=0x00007ff498806000 nid=0x5403 runnable 

"GC task thread#5 (ParallelGC)" os_prio=31 tid=0x00007ff496802000 nid=0x5303 runnable 

"GC task thread#6 (ParallelGC)" os_prio=31 tid=0x00007ff496802800 nid=0x5103 runnable 

"GC task thread#7 (ParallelGC)" os_prio=31 tid=0x00007ff495800800 nid=0x4f03 runnable 

"VM Periodic Task Thread" os_prio=31 tid=0x00007ff498824800 nid=0x5703 waiting on condition 

JNI global references: 2505


Found one Java-level deadlock:
=============================
"线程 2":
  waiting to lock monitor 0x00007ff4998056a8 (object 0x000000076af91968, a java.lang.Object),
  which is held by "线程 1"
"线程 1":
  waiting to lock monitor 0x00007ff499801608 (object 0x000000076af91978, a java.lang.Object),
  which is held by "线程 2"

Java stack information for the threads listed above:
===================================================
"线程 2":
        at com.javaedge.concurrency.example.deadLock.DeadLockDemo.lambda$main$1(DeadLockDemo.java:34)
        - waiting to lock <0x000000076af91968> (a java.lang.Object)
        - locked <0x000000076af91978> (a java.lang.Object)
        at com.javaedge.concurrency.example.deadLock.DeadLockDemo$$Lambda$2/194494468.run(Unknown Source)
        at java.lang.Thread.run(Thread.java:748)
"线程 1":
        at com.javaedge.concurrency.example.deadLock.DeadLockDemo.lambda$main$0(DeadLockDemo.java:19)
        - waiting to lock <0x000000076af91978> (a java.lang.Object)
        - locked <0x000000076af91968> (a java.lang.Object)
        at com.javaedge.concurrency.example.deadLock.DeadLockDemo$$Lambda$1/972765878.run(Unknown Source)
        at java.lang.Thread.run(Thread.java:748)

Found 1 deadlock.

```

可以看到 `jstack` 命令已经帮我们找到发生死锁的线程的具体信息。



## 6. jinfo

jinfo(JVM Configuration info)这个命令作用是实时查看和调整虚拟机运行参数。 之前的jps -v口令只能查看到显示指定的参数，如果想要查看未被显示指定的参数的值就要使用jinfo口令

### 命令帮助

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jinfo -help
Usage:
    jinfo [option] <pid>
        (to connect to running process)
    jinfo [option] <executable <core>
        (to connect to a core file)
    jinfo [option] [server_id@]<remote server IP or hostname>
        (to connect to remote debug server)

where <option> is one of:
    -flag <name>         to print the value of the named VM flag
    -flag [+|-]<name>    to enable or disable the named VM flag
    -flag <name>=<value> to set the named VM flag to the given value
    -flags               to print VM flags
    -sysprops            to print Java system properties
    <no option>          to print both of the above
    -h | -help           to print this help message
```

### 参数详解

```
-flag : 输出指定args参数的值
-flags : 不需要args参数，输出所有JVM参数的值
-sysprops : 输出系统属性，等同于System.getProperties()
```



### 示例详情

#### -flags

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jinfo -flags 1701
Attaching to process ID 1701, please wait...
Debugger attached successfully.
Server compiler detected.
JVM version is 25.201-b09
Non-default VM flags: -XX:CICompilerCount=2 -XX:InitialHeapSize=31457280 -XX:MaxHeapSize=482344960 -XX:MaxNewSize=160759808 -XX:MinHeapDeltaBytes=196608 -XX:NewSize=10485760 -XX:OldSize=20971520 -XX:+UseCompressedClassPointers -XX:+UseCompressedOops
Command line:
```



#### -flag

`jinfo -flag name vmid` :输出对应名称的参数的具体值。比如输出 MaxHeapSize、查看当前 jvm 进程是否开启打印 GC 日志 ( `-XX:PrintGCDetails` :详细 GC 日志模式，这两个都是默认关闭的)。

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jinfo -flag MaxHeapSize 1701
-XX:MaxHeapSize=482344960
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jinfo -flag PrintGC 1701
-XX:-PrintGC
```



使用 jinfo 可以在不重启虚拟机的情况下，可以动态的修改 jvm 的参数。尤其在线上的环境特别有用。**

**`jinfo -flag [+|-]name vmid` 开启或者关闭对应名称的参数。**

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jinfo -flag PrintGC 1701
-XX:-PrintGC
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jinfo -flag +PrintGC 1701
[root@iz2ze2e5wmatyx36v5jw5lz ~]# jinfo -flag PrintGC 1701
-XX:+PrintGC
```



## JVM查看运行时参数

 **打印命令行参数**

```shell
[root@iz2ze2e5wmatyx36v5jw5lz ~]# java -XX:+PrintCommandLineFlags -version
-XX:InitialHeapSize=30115776 -XX:MaxHeapSize=481852416 -XX:+PrintCommandLineFlags -XX:+UseCompressedClassPointers -XX:+UseCompressedOops
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)
```

**打印初始参数**

```shell
java -XX:+PrintFlagsInitial -version
```

**查看最终值**

```shell
java -XX:+PrintFlagsFinal -version
```



## 生成dump文件

1. JVM的配置文件中配置：

   例如：堆初始化大小，而堆最大大小

   在应用启动时配置相关的参数 -XX:+HeapDumpOnOutOfMemoryError，当应用抛出OutOfMemoryError时生成dump文件。

   在启动的时候，配置文件在哪个目录下面：

-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=目录+产生的时间.hprof

JVM启动时增加两个参数:

```
#出现 OOME 时生成堆 dump:
-XX:+HeapDumpOnOutOfMemoryError

#生成堆文件地址：
-XX:HeapDumpPath=/home/liuke/jvmlogs/
```

1. 发现程序异常前通过执行指令，直接生成当前JVM的dmp文件，6214是指JVM的进程号

   jmap -dump:file=文件名.dump [pid]

```
jmap -dump:format=b,file=serviceDump.dat 6214
```

由于第一种方式是一种事后方式，需要等待当前JVM出现问题后才能生成dmp文件，实时性不高，第二种方式在执行时，JVM是暂停服务的，所以对线上的运行会产生影响。所以建议第一种方式。



## 生产级JVM参数配置

```
//4核心8G内存配置 
-Xms4g 
-Xmx4g 
-Xmn2g 
-XX:MetaspaceSize=256M 
-XX:MaxMetaspaceSize=256M 
-XX:ReservedCodeCacheSize=256M
-XX:MaxDirectMemorySize=1g 

 
//8核16G内存配置
-Xms10g 
-Xmx10g 
-Xmn6g 
-XX:MetaspaceSize=512M 
-XX:MaxMetaspaceSize=512M 
-XX:ReservedCodeCacheSize=512M
-XX:MaxDirectMemorySize=1g 



// Tuning JVM  for Production Deployments
// > java8
// 生产环境推荐
-server 
-Xms24G
-Xmx24G
-XX:PermSize=512m
-XX:+UseG1GC 
-XX:MaxGCPauseMillis=200 
-XX:ParallelGCThreads=20 
-XX:ConcGCThreads=5 
-XX:InitiatingHeapOccupancyPercent=70

// 从服务器推荐
-server 
-Xms4G 
-Xmx4G 
-XX:PermSize=512m 
-XX:+UseG1GC 
-XX:MaxGCPauseMillis=200 
-XX:ParallelGCThreads=20 
-XX:ConcGCThreads=5 
-XX:InitiatingHeapOccupancyPercent=70

// 独立服务器
-server 
-Xms32G 
-Xmx32G 
-XX:PermSize=512m 
-XX:+UseG1GC 
-XX:MaxGCPauseMillis=200 
-XX:ParallelGCThreads=20 
-XX:ConcGCThreads=5 
-XX:InitiatingHeapOccupancyPercent=70

// http://www.51gjie.com/java/551.html
// https://www.cnblogs.com/gxyandwmm/p/9456955.html
// For JDK 1.7⁄ 1.8 (8GB heap example for machine with 32 CPUs):
-server // 服务器模式
-Xms8g // JVM初始分配的堆内存，一般和Xmx配置成一样以避免每次gc后JVM重新分配内存
-Xmx8g // JVM最大允许分配的堆内存，按需分配
-XX:+UseParNewGC // 年轻代垃圾收集器
-XX:+UseConcMarkSweepGC // 并发标记清除（CMS）收集器 (年老代)
-XX:+UseTLAB 
-XX:NewSize=128m // 年轻代大小
-XX:MaxNewSize=128m // 最大年轻代大小
-XX:MaxTenuringThreshold=2 // 提升年老代的最大临界值,JDK8里CMS 默认是6，其他如G1是15
-XX:SurvivorRatio=8  // Eden区与Survivor区的大小比值
-XX:+UseCMSInitiatingOccupancyOnly  //使用手动定义初始化定义开始CMS收集
-XX:CMSInitiatingOccupancyFraction=40 //使用cms作为垃圾回收使用40％后开始CMS收集
-XX:MaxGCPauseMillis=1000 // 用户设定的最大gc 停顿时间1000ms
-XX:InitiatingHeapOccupancyPercent=50 // heap中50%的容量被使用，则会触发concurrent gc
-XX:+UseCompressedOops
-XX:ParallelGCThreads=8 // 设置垃圾收集器在并行阶段使用的线程数,默认值随JVM运行的平台不同而不同.
-XX:ConcGCThreads=8 
-XX:+DisableExplicitGC // 忽略手动调用GC, System.gc()的调用就会变成一个空调用，完全不触发GC


```



## JVM参数设置优化例子

**1. 承受海量访问的动态Web应用**



服务器配置：8 CPU, 8G MEM, JDK 1.6.X
参数方案：
-server -Xmx3550m -Xms3550m -Xmn1256m -Xss128k -XX:SurvivorRatio=6 -XX:MaxPermSize=256m -XX:ParallelGCThreads=8 -XX:MaxTenuringThreshold=0 -XX:+UseConcMarkSweepGC
调优说明：
-Xmx 与 -Xms 相同以避免JVM反复重新申请内存。-Xmx 的大小约等于系统内存大小的一半，即充分利用系统资源，又给予系统安全运行的空间。
-Xmn1256m 设置年轻代大小为1256MB。此值对系统性能影响较大，Sun官方推荐配置年轻代大小为整个堆的3/8。
-Xss128k 设置较小的线程栈以支持创建更多的线程，支持海量访问，并提升系统性能。
-XX:SurvivorRatio=6 设置年轻代中Eden区与Survivor区的比值。系统默认是8，根据经验设置为6，则2个Survivor区与1个Eden区的比值为2:6，一个Survivor区占整个年轻代的1/8。
-XX:ParallelGCThreads=8 配置并行收集器的线程数，即同时8个线程一起进行垃圾回收。此值一般配置为与CPU数目相等。
-XX:MaxTenuringThreshold=0 设置垃圾最大年龄（在年轻代的存活次数）。如果设置为0的话，则年轻代对象不经过Survivor区直接进入年老代。对于年老代比较多的应用，可以提高效率；如果将此值设置为一个较大值，则年轻代对象会在Survivor区进行多次复制，这样可以增加对象再年轻代的存活时间，增加在年轻代即被回收的概率。根据被海量访问的动态Web应用之特点，其内存要么被缓存起来以减少直接访问DB，要么被快速回收以支持高并发海量请求，因此其内存对象在年轻代存活多次意义不大，可以直接进入年老代，根据实际应用效果，在这里设置此值为0。
-XX:+UseConcMarkSweepGC 设置年老代为并发收集。CMS（ConcMarkSweepGC）收集的目标是尽量减少应用的暂停时间，减少Full GC发生的几率，利用和应用程序线程并发的垃圾回收线程来标记清除年老代内存，适用于应用中存在比较多的长生命周期对象的情况。



**2. 内部集成构建服务器案例**



高性能数据处理的工具应用
服务器配置：1 CPU, 4G MEM, JDK 1.6.X
参数方案：
-server -XX:PermSize=196m -XX:MaxPermSize=196m -Xmn320m -Xms768m -Xmx1024m
调优说明：
-XX:PermSize=196m -XX:MaxPermSize=196m 根据集成构建的特点，大规模的系统编译可能需要加载大量的Java类到内存中，所以预先分配好大量的持久代内存是高效和必要的。
-Xmn320m 遵循年轻代大小为整个堆的3/8原则。
-Xms768m -Xmx1024m 根据系统大致能够承受的堆内存大小设置即可。