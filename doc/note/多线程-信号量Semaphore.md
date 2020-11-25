# Semaphore的使用方法

Semaphore翻译成字面意思为**信号量**，Semaphore可以控同时访问的线程个数，通过 acquire() 获取一个许可，如果没有就等待，而 release() 释放一个许可。

Semaphore类位于java.util.concurrent包下，它提供了2个构造器：

```
 /**
     * Creates a {@code Semaphore} with the given number of
     * permits and nonfair fairness setting.
     *
     * @param permits the initial number of permits available.
     *        This value may be negative, in which case releases
     *        must occur before any acquires will be granted.
     */
    public Semaphore(int permits) {
        sync = new NonfairSync(permits);
    }

    /**
     * Creates a {@code Semaphore} with the given number of
     * permits and the given fairness setting.
     *
     * @param permits the initial number of permits available.
     *        This value may be negative, in which case releases
     *        must occur before any acquires will be granted.
     * @param fair {@code true} if this semaphore will guarantee
     *        first-in first-out granting of permits under contention,
     *        else {@code false}
     */
    public Semaphore(int permits, boolean fair) {
        sync = fair ? new FairSync(permits) : new NonfairSync(permits);
    }
```

参数permits表示许可数目，即同时可以允许多少线程进行访问。

第二个构造函数多了一个参数fair表示是否是公平的，即等待时间越久的越先获取许可。

下面说一下Semaphore类中比较重要的几个方法，首先是acquire()、release()方法：

```

//获取一个许可
public void acquire() throws InterruptedException {  }
//获取permits个许可     
public void acquire(int permits) throws InterruptedException { } 
//释放一个许可   
public void release() { }          
//释放permits个许可
public void release(int permits) { } 
```

acquire()用来获取一个许可，若无许可能够获得，则会一直等待，直到获得许可。

release()用来释放许可。注意，在释放许可之前，必须先获获得许可。

这4个方法都会被阻塞，如果想立即得到执行结果，可以使用下面几个方法：

```
//尝试获取一个许可，若获取成功，则立即返回true，若获取失败，则立即返回false
public boolean tryAcquire() { };   
//尝试获取一个许可，若在指定的时间内获取成功，则立即返回true，否则则立即返回false
public boolean tryAcquire(long timeout, TimeUnit unit) throws InterruptedException { };  
//尝试获取permits个许可，若获取成功，则立即返回true，若获取失败，则立即返回false
public boolean tryAcquire(int permits) { }; 
//尝试获取permits个许可，若在指定的时间内获取成功，则立即返回true，否则则立即返回false
public boolean tryAcquire(int permits, long timeout, TimeUnit unit) throws InterruptedException { }; 
```

另外还可以通过availablePermits()方法得到可用的许可数目。

下面通过一个例子来看一下Semaphore的具体使用：

马上到端午节了，大家要去旅游，比如我们去圆明园游览，只有5个窗口可以售票，也就是说同一个时刻只能服务5个人。

```
public class Test {

    public static void main(String[] args) {
        //游客的数量
        int visitor = 8;
        //窗口的数量
        Semaphore semaphore = new Semaphore(5);
        for (int i = 0; i < visitor; i++) {
            new Visitor(i, semaphore).start();
        }

    }

    static class Visitor extends Thread {
        private int num;
        private Semaphore semaphore;

        public Visitor(int num, Semaphore semaphore) {
            this.num = num;
            this.semaphore = semaphore;
        }

        @Override
        public void run() {
            try {
                //占用窗口
                semaphore.acquire();
                System.out.println("游客" + this.num + "占用窗口进行买票...");
                Thread.sleep(2000);
                System.out.println("游客" + this.num + "释放出窗口");
                //释放窗口
                semaphore.release();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
```

输出结果为

```
游客0占用窗口进行买票...
游客1占用窗口进行买票...
游客2占用窗口进行买票...
游客3占用窗口进行买票...
游客4占用窗口进行买票...
游客0释放出窗口
游客1释放出窗口
游客2释放出窗口
游客5占用窗口进行买票...
游客7占用窗口进行买票...
游客6占用窗口进行买票...
游客3释放出窗口
游客4释放出窗口
游客5释放出窗口
游客7释放出窗口
游客6释放出窗口
```

从结果来看，最多只有5个游客在购票。而这么精确的控制，我们也只是调用了acquire和release方法。

从acquire方法进去，具体调用的还是AbstractQueuedSynchronizer这个类的逻辑

```
    public void acquire() throws InterruptedException {
        sync.acquireSharedInterruptibly(1);
    }
    public final void acquireSharedInterruptibly(int arg)
            throws InterruptedException {
        if (Thread.interrupted())
            throw new InterruptedException();
        if (tryAcquireShared(arg) < 0)
            doAcquireSharedInterruptibly(arg);
    }
```

而tryAcquireShared方法留给了子类去实现，Semaphore类里面的两个内部类FairSync和NonfairSync都继承自AbstractQueuedSynchronizer。

这两个内部类，从名字来看，一个实现了公平锁，另一个是非公平锁。



**实现原理**

Semaphore内部原理是通过AQS实现的。Semaphore中定义了Sync抽象类，而Sync又继承了AbstractQueuedSynchronizer，Semaphore中对许可的获取与释放，是使用CAS通过对AQS中state的操作实现的。

Semaphore对许可的分配有两种策略，公平策略和非公平策略，没有明确指明时，默认为非公平策略。

公平策略：根据方法调用顺序（即先进先出，FIFO）来选择线程、获得许可。 

非公平策略：不对线程获取许可的顺序做任何保证。