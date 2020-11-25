# 1. 概述

接上一篇 [学习ConcurrentHashMap1.8并发写机制](https://mp.weixin.qq.com/s/e-ZA9oxzJGRVt0mBjCIi5A), 本文主要学习 `Segment分段锁` 的实现原理。

虽然 `JDK1.7` 在生产环境已逐渐被 `JDK1.8` 替代，然而一些好的思想还是需要进行学习的。比方说位图中寻找 `bit` 位的思路是不是和 `ConcurrentHashMap1.7` 有点相似？

接下来，本文基于 `OpenJDK7` 来做源码解析。

# 2. ConcurrentHashMap1.7初认识

ConcurrentHashMap中put()是线程安全的。但是很多时候, 由于业务需求, 需要先 `get()` 操作再 `put()` 操作，这2个操作无法保证原子性，这样就会产生**线程安全**问题了。大家在开发中一定要注意。

ConcurrentHashMap的结构示意图如下:

![](https://gitee.com/idea360/oss/raw/master/images/concurrentHashmap7-segment.png)

在进行数据的定位时，会首先找到 `segment`, 然后在 `segment` 中定位 `bucket`。如果多线程操作同一个 `segment`, 就会触发 `segment` 的锁 `ReentrantLock`, 这就是分段锁的**基本实现原理**。

# 3. 源码分析

## 3.1 HashEntry

`HashEntry` 是 `ConcurrentHashMap` 的基础单元(节点)，是实际数据的载体。

```java
    static final class HashEntry<K,V> {
        final int hash;
        final K key;
        volatile V value;
        volatile HashEntry<K,V> next;

        HashEntry(int hash, K key, V value, HashEntry<K,V> next) {
            this.hash = hash;
            this.key = key;
            this.value = value;
            this.next = next;
        }

        /**
         * Sets next field with volatile write semantics.  (See above
         * about use of putOrderedObject.)
         */
        final void setNext(HashEntry<K,V> n) {
            UNSAFE.putOrderedObject(this, nextOffset, n);
        }

        // Unsafe mechanics
        static final sun.misc.Unsafe UNSAFE;
        static final long nextOffset;
        static {
            try {
                UNSAFE = sun.misc.Unsafe.getUnsafe();
                Class k = HashEntry.class;
                nextOffset = UNSAFE.objectFieldOffset
                    (k.getDeclaredField("next"));
            } catch (Exception e) {
                throw new Error(e);
            }
        }
    }
```

## 3.2 Segment

`Segment` 继承 `ReentrantLock` 锁,用于存放数组 `HashEntry[]`。在这里可以看出, 无论1.7还是1.8版本, `ConcurrentHashMap` 底层并不是对 `HashMap` 的扩展, 而是同样从底层基于数组+链表进行功能实现。

```java
    static final class Segment<K,V> extends ReentrantLock implements Serializable {

        private static final long serialVersionUID = 2249069246763182397L;

        static final int MAX_SCAN_RETRIES =
            Runtime.getRuntime().availableProcessors() > 1 ? 64 : 1;

        // 数据节点存储在这里(基础单元是数组)
        transient volatile HashEntry<K,V>[] table;

        transient int count;

        transient int modCount;

        transient int threshold;

        final float loadFactor;

        Segment(float lf, int threshold, HashEntry<K,V>[] tab) {
            this.loadFactor = lf;
            this.threshold = threshold;
            this.table = tab;
        }
        // 具体方法不在这里讨论...
    }
```

## 3.3 构造方法

![](https://gitee.com/idea360/oss/raw/master/images/concurrenthashmap-constructor.jpg)


```java
    public ConcurrentHashMap(int initialCapacity,
                             float loadFactor, int concurrencyLevel) {
        if (!(loadFactor > 0) || initialCapacity < 0 || concurrencyLevel <= 0)
            throw new IllegalArgumentException();
        // 对于concurrencyLevel的理解, 可以理解为segments数组的长度，即理论上多线程并发数(分段锁), 默认16
        if (concurrencyLevel > MAX_SEGMENTS)
            concurrencyLevel = MAX_SEGMENTS;
        // Find power-of-two sizes best matching arguments
        int sshift = 0;
        int ssize = 1;
        // 默认concurrencyLevel = 16, 所以ssize在默认情况下也是16,此时 sshift = 4
        // ssize = 2^sshift 即 ssize = 1 << sshift
        while (ssize < concurrencyLevel) {
            ++sshift;
            ssize <<= 1;
        }
        // 段偏移量，32是因为hash是int值，int值32位，默认值情况下此时segmentShift = 28
        this.segmentShift = 32 - sshift;
        // 散列算法的掩码，默认值情况下segmentMask = 15, 定位segment的时候需要根据segment[]长度取模, 即hash(key)&(ssize - 1)
        this.segmentMask = ssize - 1;
        if (initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;
        // 计算每个segment中table的容量, 初始容量=16, 并发数=16, 则segment中的Entry[]长度为1。
        int c = initialCapacity / ssize;
        // 处理无法整除的情况，取上限
        if (c * ssize < initialCapacity)
            ++c;
        // MIN_SEGMENT_TABLE_CAPACITY默认时2，cap是2的n次方
        int cap = MIN_SEGMENT_TABLE_CAPACITY;
        while (cap < c)
            cap <<= 1;
        // create segments and segments[0]
        // 创建segments并初始化第一个segment数组,其余的segment延迟初始化
        Segment<K,V> s0 =
            new Segment<K,V>(loadFactor, (int)(cap * loadFactor),
                             (HashEntry<K,V>[])new HashEntry[cap]);
        // 默认并发数=16
        Segment<K,V>[] ss = (Segment<K,V>[])new Segment[ssize];
        UNSAFE.putOrderedObject(ss, SBASE, s0); // ordered write of segments[0]
        this.segments = ss;
    }
```

由图和源码可知，当用默认构造函数时，最大并发数是16，即最大允许16个线程同步写操作，且无法扩展。所以如果我们的场景数据量比较大时，应该设置合适的并发数，避免频繁锁冲突。

## 3.4 put()操作

```java
    public V put(K key, V value) {
        Segment<K,V> s;
        if (value == null)
            throw new NullPointerException();
        // 根据key的hash再次进行hash运算
        int hash = hash(key.hashCode());
        // 基于hash定位segment数组的索引。
        // hash值是int值，32bits。segmentShift=28，无符号右移28位，剩下高4位，其余补0。
        // segmentMask=15，二进制低4位全部是1，所以j相当于hash右移后的低4位。
        int j = (hash >>> segmentShift) & segmentMask;
        if ((s = (Segment<K,V>)UNSAFE.getObject          // nonvolatile; recheck
             (segments, (j << SSHIFT) + SBASE)) == null) //  in ensureSegment
        // 找到对应segment
            s = ensureSegment(j);
        // 将新节点插入segment中
        return s.put(key, hash, value, false);
    }
```

![](https://gitee.com/idea360/oss/raw/master/images/concurrenthashmap-cal-segment-index.png)

 找出对应segment，如果不存在就创建并初始化

```java
    @SuppressWarnings("unchecked")
    private Segment<K,V> ensureSegment(int k) {
        // 当前的segments数组
        final Segment<K,V>[] ss = this.segments;
        // 计算原始偏移量,在segments数组的位置
        long u = (k << SSHIFT) + SBASE; // raw offset
        Segment<K,V> seg;
        // 判断没有被初始化
        if ((seg = (Segment<K,V>)UNSAFE.getObjectVolatile(ss, u)) == null) {
            // 获取第一个segment ss[0]作为原型
            Segment<K,V> proto = ss[0]; // use segment 0 as prototype
            int cap = proto.table.length; // 容量
            float lf = proto.loadFactor; // 负载因子
            int threshold = (int)(cap * lf); // 阈值
            // 初始化ss[k] 内部的tab数组 // recheck
            HashEntry<K,V>[] tab = (HashEntry<K,V>[])new HashEntry[cap];
            // 再次检查这个ss[k]  有没有被初始化
            if ((seg = (Segment<K,V>)UNSAFE.getObjectVolatile(ss, u))
                == null) { // recheck
                Segment<K,V> s = new Segment<K,V>(lf, threshold, tab);
                // 自旋。getObjectVolatile 保证了读的可见性,所以一旦有一个线程初始化了,那么就结束自旋
                while ((seg = (Segment<K,V>)UNSAFE.getObjectVolatile(ss, u))
                       == null) {
                    if (UNSAFE.compareAndSwapObject(ss, u, null, seg = s))
                        break;
                }
            }
        }
        return seg;
    }
```

## 3.5 segment插入节点

上一步找到segment位置后计算节点在segment中的位置。

```java
         final V put(K key, int hash, V value, boolean onlyIfAbsent) {
            // 是否获取锁,失败自旋获取锁(直到成功)
            HashEntry<K,V> node = tryLock() ? null :
                scanAndLockForPut(key, hash, value); // 失败了才会scanAndLockForPut
            V oldValue;
            try {
                HashEntry<K,V>[] tab = table;
                int index = (tab.length - 1) & hash;
                // 获取到bucket位置的第一个节点
                HashEntry<K,V> first = entryAt(tab, index);
                for (HashEntry<K,V> e = first;;) {
                    // hash冲突
                    if (e != null) {
                        K k;
                        // key相等则覆盖
                        if ((k = e.key) == key ||
                            (e.hash == hash && key.equals(k))) {
                            oldValue = e.value;
                            if (!onlyIfAbsent) {
                                e.value = value;
                                ++modCount;
                            }
                            break;
                        }
                        // 不相等则遍历链表
                        e = e.next;
                    }
                    else {
                        if (node != null)
                            // 将新节点插入链表作为表头
                            node.setNext(first);
                        else
                            // 创建新节点并插入表头
                            node = new HashEntry<K,V>(hash, key, value, first);
                        int c = count + 1;
                        // 判断元素个数是否超过了阈值或者segment中数组的长度超过了MAXIMUM_CAPACITY，如果满足条件则rehash扩容！
                        if (c > threshold && tab.length < MAXIMUM_CAPACITY)
                            // 扩容
                            rehash(node);
                        else
                            setEntryAt(tab, index, node);
                        ++modCount;
                        count = c;
                        oldValue = null;
                        break;
                    }
                }
            } finally {
                // 解锁
                unlock();
            }
            return oldValue;
        }
```

如果加锁失败则先走 `scanAndLockForPut()` 方法。

```java
        private HashEntry<K,V> scanAndLockForPut(K key, int hash, V value) {
            // 根据hash获取头结点
            HashEntry<K,V> first = entryForHash(this, hash);
            HashEntry<K,V> e = first;
            HashEntry<K,V> node = null;
            int retries = -1; // negative while locating node
            // 尝试获取锁,成功就返回,失败就开始自旋
            while (!tryLock()) {
                HashEntry<K,V> f; // to recheck first below
                if (retries < 0) {
                    // 如果头结点不存在
                    if (e == null) {
                        if (node == null) // speculatively create node
                            node = new HashEntry<K,V>(hash, key, value, null);
                        retries = 0;
                    }
                    // 和头结点key相等
                    else if (key.equals(e.key))
                        retries = 0;
                    else
                        // 下一个节点 直到为null
                        e = e.next;
                }
                // 达到自旋的最大次数
                else if (++retries > MAX_SCAN_RETRIES) {
                    // lock()是阻塞方法。进入加锁方法,失败进入队列,阻塞当前线程
                    lock();
                    break;
                }
                // TODO (retries & 1) == 0 没理解
                else if ((retries & 1) == 0 &&
                         (f = entryForHash(this, hash)) != first) {
                    // 头结点变化,需要重新遍历,说明有新的节点加入或者移除
                    e = first = f; // re-traverse if entry changed
                    retries = -1;
                }
            }
            return node;
        }
```

(retries & 1) == 0 没理解是在做什么，有小伙伴看明白了请赐教。

# 最后

本文到此结束，主要是学习分段锁是如何工作的。谢谢大家的观看。