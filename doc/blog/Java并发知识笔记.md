# 1. 线程状态

| 线程状态      | 说明                                                         |
| ------------- | ------------------------------------------------------------ |
| NEW           | 初始状态，线程被构建，但是还没调用start()方法                |
| RUNNABLE      | 运行状态，Java线程将操作系统中的就绪和运行两种状态统称运行中 |
| BLOCKED       | 阻塞状态，表示线程阻塞于锁                                   |
| WAITING       | 等待状态，表示线程进入等待状态，进入该状态表示当前线程需要等待其他线程做出一些特定状态(通知或中断) |
| TIMED_WAITING | 超时等待状态，该状态不同于WAITING，它是可以在指定时间自行返回的 |
| TERMINATED    | 终止状态，表示当前线程已经执行完毕                           |


# 2. 内存模型

**CPU执行计算的过程**

1. 程序以及数据被加载到主内存
2. 指令和数据被加载到CPU缓存
3. CPU执行指令，把结果写到高速缓存
4. 高速缓存中的数据写回主内存

**JMM是基于共享内存的多线程并发模型**

工作内存Work Memory其实就是对CPU寄存器和高速缓存的抽象，或者说每个线程的工作内存也可以简单理解为CPU寄存器和高速缓存。

![](https://gitee.com/idea360/oss/raw/master/images/jmm.png)

交互协议（原子操作）

- lock：作用于主内存的变量，把一个变量标识为一条线程独占的状态
- unlock：作用于主内存的变量，把一个处于锁定状态的变量释放出来，释放后的变量才可以被其他线程锁定
- read：作用于主内存的变量，把一个变量的值从主内存传输到线程的工作内存中，以便随后的load动作使用
- load：作用于工作内存的变量，把read操作从主内存得到的变量放入工作内存的变量副本中
- use：作用于工作内存的变量，把工作内存中一个变量的值传递给执行引擎；每当虚拟机遇到一个需要使用到变量的值的字节码指令时会执行这个操作
- assign：作用于工作内存的变量，把一个从执行引擎接收到的值赋给工作内存的变量；每当虚拟机遇到一个给变量赋值的字节码指令时执行这个操作
- store：作用于工作内存的变量，把工作内存中一个变量的值传送到主内存中，以便随后的write动作使用
- write：作用于主内存的变量，把store操作从工作内存中得到的变量值放入主内存的变量中


# 3. 原子性、可见性、有序性

- **原子性**: 一个操作是不可中断的
- **可见性**: 当一个线程修改了某一个共享变量的值，其他线程是否能够立即知道这个修改
- **有序性**: 程序执行的顺序按照代码的先后顺序执行

| 特性   | 实现                                |
| ------ | ----------------------------------- |
| 可见性 | volatile、final、synchronized、lock |
| 有序性 | volatile、synchronized、lock        |
| 原子性 | synchronized、JUC-原子类            |

# 4. happens-before规则

**happens-before规则用于描述线程的内存可见性问题，是判断数据是否存在竞争、线程是否安全的主要依据**

1. **程序顺序规则**: 在一个线程中，按照程序顺序，前面的操作`Happens-Before`于后续的任意操作;
2. **监视器锁规则**: 对一个锁的解锁`Happens-Before` 于后续对这个锁的加锁;
3. **volatile变量规则**: 对一个volatile域的写，happens-before于任意后续对这个volatile域的读;
4. **传递性规则**: 如果A`Happens-Before`B，且 B`Happens-Before`C，那么 A`Happens- Before`C;
5. **线程start()规则**: 如果线程A执行操作ThreadB.start()（启动线程B），那么A线程的ThreadB.start()操作`Happens-Before`于线程B中的任意操作;
6. **线程join()规则**: 主线程A等待子线程B完成(主线程A通过调用子线程B的join()方法实现)，当子线程 B 完成后(主线程A中join()方法返回)，主线程能够看到子线程的操作。当然所谓的“看到”，指的是对共享变量的操作。

# 5. 内存屏障

| 屏障类型            | 指令示例                 | 说明                                                         |
| :------------------ | :----------------------- | :----------------------------------------------------------- |
| LoadLoad Barriers   | Load1;LoadLoad;Load2     | 确保Load1数据的装载先于Load2及其后所有装载指令的的操作       |
| StoreStore Barriers | Store1;StoreStore;Store2 | 确保Store1立刻刷新数据到内存(使其对其他处理器可见)的操作先于Store2及其后所有存储指令的操作 |
| LoadStore Barriers  | Load1;LoadStore;Store2   | 确保Load1的数据装载先于Store2及其后所有的存储指令刷新数据到内存的操作 |
| StoreLoad Barriers  | Store1;StoreLoad;Load2   | 确保Store1立刻刷新数据到内存的操作先于Load2及其后所有装载装载指令的操作.它会使该屏障之前的所有内存访问指令(存储指令和访问指令)完成之后,才执行该屏障之后的内存访问指令 |

# 6. volatile

## 可见性

用 volatile 关键字修饰的共享变量，编译成字节码后增加**Lock前缀指令**，该指令要做两件事:

1. 将当前工作内存缓存行的数据立即写回到主内存。
2. 写回主内存的操作会使其他工作内存里缓存了该共享变量地址的数据无效（缓存一致性协议保证的操作）。

对声明了volatile的变量进行**写操作**，JVM就会向处理器发送一条**Lock前缀**的指令，将这个变量所在缓存行的数据写回到系统内存。LOCK＃信号一般不锁总线，而是锁缓存。它会锁定这块内存区域的缓存并回写到内存，并使用缓存一致性机制来确保修改的原子性，此操作被称为“缓存锁定”，缓存一致性机制会阻止同时修改由两个以上处理器缓存的内存区域数据。

在多处理器下，为了保证各个处理器的缓存是一致的，就会实现**缓存一致性协议**，**每个处理器通过嗅探在总线上传播的数据来检查自己缓存的值是不是过期了**，当处理器发现自己缓存行对应的内存地址被修改，就会将当前处理器的缓存行设置成无效状态，当处理器对这个数据进行修改操作的时候，会重新从系统内存中把数据读到处理器缓存里。**MESI协议**是当前最主流的缓存一致性协议。


## 有序性

volatile写

![](https://gitee.com/idea360/oss/raw/master/images/volatile-write.png)

volatile读

![](https://gitee.com/idea360/oss/raw/master/images/volatile-read.png)


# 7. synchronized

## 简介

1. synchronize实现的锁本质上是一种阻塞锁，也就是说多个线程要排队访问同一个共享对象。
2. synchronized是无法禁止指令重排和处理器优化的，从双重校验单例可以看出
3. synchronized保证的**有序性**是多个线程之间的有序性，即被加锁的内容要按照顺序被多个线程执行。但是其内部的同步代码还是会发生重排序，只不过由于编译器和处理器都遵循as-if-serial语义，所以我们可以认为这些重排序在单线程内部可忽略。
4. synchronize`可见性`通过Happens-Before 规则保证的

## 实现原理

![](https://gitee.com/idea360/oss/raw/master/images/MonitorLocks-1.png)

synchronized 同步语句块的实现使用的是 `monitorenter` 和 `monitorexit` 指令，其中 monitorenter 指令指向同 步代码块的开始位置，monitorexit 指令则指明同步代码块的结束位置。 当执行 monitorenter指令时，**线程试图获取锁也就是获取monitor的持有权**.当计数器为0则可以成功获取，获取后将锁计数器设 为1也就是加1。相应的在执行 monitorexit 指令后，将锁计数器设为0，表明锁被释放。如果获取对象锁失败，那当 前线程就要阻塞等待，直到锁被另外一个线程释放为止。


# 8. Lock

基于AQS实现

![](https://gitee.com/idea360/oss/raw/master/images/reentrantlock-nonfair.png)


# 9. wait/notify对比await/signal

## wait/notify

Object的wait和notify/notify是与对象监视器配合完成线程间的等待/通知机制，是java底层级别的。

1. wait/notify方式不支持响应中断
2. wait/notify方式支持一个等待队列
3. wait/notify可能导致线程永远无法被唤醒

## await/signal

Condition与Lock配合完成等待通知机制，是语言级别的，具有更高的可控制性和扩展性。

1. Condition能够支持响应中断
2. Condition能够支持多个等待队列（new 多个Condition对象）

# 10. lock对比synchronized

## synchronized

1. synchronized无法破坏不可抢占条件（死锁的条件之一）。

    - synchronized在申请资源的时候，如果申请不到，线程直接进入阻塞状态，也不会释放线程已经占有的资源。

## lock

1. **能够响应中断**

    - 持有锁A的线程在尝试获取锁B失败，进入阻塞状态，如果发生死锁，将没有机会唤醒阻塞线程
    - 如果处于阻塞状态的线程能够响应中断信号，那阻塞线程就有机会释放曾经持有的锁A

2. **支持超时**

    - 如果线程在一段时间内没有获得锁，不是进入阻塞状态，而是返回一个错误
    那么该线程也有机会释放曾经持有的锁

3. **非阻塞地获取锁**

    - 如果尝试获取锁失败，不是进入阻塞状态，而是直接返回，那么该线程也有机会释放曾经持有的锁

```java
// java.util.concurrent.locks.Lock接口
// 能够响应中断
void lockInterruptibly() throws InterruptedException;
// 支持超时（同时也能够响应中断）
boolean tryLock(long time, TimeUnit unit) throws InterruptedException;
// 非阻塞地获取锁
boolean tryLock();
```

# 11. CAS

# 12. AQS

volatile修饰的state保证可见性、顺序性，Unsafe类的CAS保证原子性

# 13. Unsafe

# 14. 死锁

## 死锁发生的条件

- **互斥**: 共享资源X和共享资源Y只能被一个线程占用
- **请求保持**: 线程T1占有共享资源X，在等待共享资源Y的时候，不会释放共享资源X
- **不可剥夺**: 其他线程不能强行抢占线程已经占有的共享资源
- **环路等待**: 线程T1等待线程T2占有的资源，线程T2等待线程T1占有的资源

## 规避死锁

1. **破坏请求保持**: 一次性申请所有共享资源，不存在等待
2. **破坏不可剥夺**: 占有部分共享资源的线程进一步申请其他共享资源时，如果申请不到，可以主动释放它所占用的共享资源，如超时释放等。
3. **破坏环路等待**: 按序申请共享资源（共享资源是有线性顺序的）

## 数据库死锁

- 一种策略是，直接进入等待，直到超时。这个超时时间可以通过参数innodb_lock_wait_timeout来设置。
- 另一种策略是，发起死锁检测，发现死锁后，主动回滚死锁链条中的某一个事务，让其他事务得以继续执行。将参数innodb_deadlock_detect设置为on，表示开启这个逻辑。
