# 1. 前言

上篇文章讲了Unsafe类中CAS的实现，其实是在为这篇文章打基础。不太熟悉的小伙伴请移步[Unsafe中CAS的实现](https://mp.weixin.qq.com/s/7u63bPY_N5-0192akhuXjg)。本篇文章主要基于 `OpenJDK8` 来做源码解析。

# 2. 源码

ConcurrentHashMap基于HashMap实现。

JDK1.7和JDK1.8作为并发容器在实现上是有差别的。JDK1.7通过Segment分段锁实现，而JDK1.8通过CAS+synchronized实现。

## 2.1 ConcurrentHashMap几个重要方法

在ConcurrentHashMap中使用了unSafe方法，通过直接操作内存的方式来保证并发处理的安全性，使用的是硬件的安全机制。

```java
    private static final sun.misc.Unsafe U;
    private static final long SIZECTL;
    private static final long TRANSFERINDEX;
    private static final long BASECOUNT;
    private static final long CELLSBUSY;
    private static final long CELLVALUE;
    private static final long ABASE;
    private static final int ASHIFT;

    static {
        try {
            U = sun.misc.Unsafe.getUnsafe();
            Class<?> k = ConcurrentHashMap.class;
            SIZECTL = U.objectFieldOffset
                (k.getDeclaredField("sizeCtl"));
            TRANSFERINDEX = U.objectFieldOffset
                (k.getDeclaredField("transferIndex"));
            BASECOUNT = U.objectFieldOffset
                (k.getDeclaredField("baseCount"));
            CELLSBUSY = U.objectFieldOffset
                (k.getDeclaredField("cellsBusy"));
            Class<?> ck = CounterCell.class;
            CELLVALUE = U.objectFieldOffset
                (ck.getDeclaredField("value"));
            Class<?> ak = Node[].class;
            ABASE = U.arrayBaseOffset(ak);
            int scale = U.arrayIndexScale(ak);
            if ((scale & (scale - 1)) != 0)
                throw new Error("data type scale not a power of two");
            ASHIFT = 31 - Integer.numberOfLeadingZeros(scale);
        } catch (Exception e) {
            throw new Error(e);
        }
    }

    static final <K,V> Node<K,V> tabAt(Node<K,V>[] tab, int i) {
        return (Node<K,V>)U.getObjectVolatile(tab, ((long)i << ASHIFT) + ABASE);
    }

    // CAS 将Node插入bucket
    static final <K,V> boolean casTabAt(Node<K,V>[] tab, int i,
                                        Node<K,V> c, Node<K,V> v) {
        return U.compareAndSwapObject(tab, ((long)i << ASHIFT) + ABASE, c, v);
    }

    static final <K,V> void setTabAt(Node<K,V>[] tab, int i, Node<K,V> v) {
        U.putObjectVolatile(tab, ((long)i << ASHIFT) + ABASE, v);
    }
```

## 2.2 put()流程

还是老规矩，先上流程图帮助阅读源码。

![](https://gitee.com/idea360/oss/raw/master/images/concurrenthashmap-put.jpg)

主体源码如下:

```java
    public V put(K key, V value) {
        return putVal(key, value, false);
    }


    /** Implementation for put and putIfAbsent */
    final V putVal(K key, V value, boolean onlyIfAbsent) {
        if (key == null || value == null) throw new NullPointerException();
        int hash = spread(key.hashCode());
        int binCount = 0;
        // 基础数组
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh;
            if (tab == null || (n = tab.length) == 0)
                // 初始化
                tab = initTable();
            else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) { // 如果bucket==null，即没有hash冲突，CAS插入
                if (casTabAt(tab, i, null,
                             new Node<K,V>(hash, key, value, null)))
                    break;                   // no lock when adding to empty bin
            }
            // 如果在进行扩容操作，则先扩容
            else if ((fh = f.hash) == MOVED)
                tab = helpTransfer(tab, f);
            // 否则，存在hash冲突
            else {
                V oldVal = null;
                // 加锁同步
                synchronized (f) {
                    if (tabAt(tab, i) == f) {
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f;; ++binCount) {
                                K ek;
                                // 遍历过程中出现相同key直接覆盖
                                if (e.hash == hash &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {
                                    oldVal = e.val;
                                    if (!onlyIfAbsent)
                                        e.val = value;
                                    break;
                                }
                                Node<K,V> pred = e;
                                // 尾插法插入
                                if ((e = e.next) == null) {
                                    pred.next = new Node<K,V>(hash, key,
                                                              value, null);
                                    break;
                                }
                            }
                        }
                        // 如果是树节点，遍历红黑树
                        else if (f instanceof TreeBin) {
                            Node<K,V> p;
                            binCount = 2;
                            if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                           value)) != null) {
                                oldVal = p.val;
                                if (!onlyIfAbsent)
                                    p.val = value;
                            }
                        }
                    }
                }
                if (binCount != 0) {
                    if (binCount >= TREEIFY_THRESHOLD)
                        treeifyBin(tab, i);
                    if (oldVal != null)
                        return oldVal;
                    break;
                }
            }
        }
        addCount(1L, binCount);
        return null;
    }
```

put操作过程如下:

- 如果没有初始化就先调用initTable（）方法来进行初始化过程
- 如果没有hash冲突就直接CAS插入
- 如果还在进行扩容操作就先进行扩容
- 如果存在hash冲突，就加锁来保证线程安全，这里有两种情况，一种是链表形式就直接遍历到尾端插入，一种是红黑树就按照红黑树结构插入
- 最后一个如果该链表的数量大于阈值8，就要先转换成黑红树的结构，break再一次进入循环
- 如果添加成功就调用addCount（）方法统计size，并且检查是否需要扩容


## 2.3 ConcurrentHashMap的存储结构

下边的示意图来自网络

![](https://gitee.com/idea360/oss/raw/master/images/java8-concurrentHashmap-save.jpg)


# 3. 结语

本文只分析了 `ConcurrentHashMap` 的 `put()` 方法，并没有分析get()、扩容、删除节点等方法。主要目的是初步了解ConcurrentMap确保并发写的设计思路。至此，本篇文章结束，感谢大家的阅读！欢迎大家关注公众号【当我遇上你】。