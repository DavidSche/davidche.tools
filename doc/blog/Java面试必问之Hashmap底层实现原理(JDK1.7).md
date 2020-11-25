# 1. 前言

Hashmap可以说是Java面试必问的，一般的面试题会问:

* Hashmap有哪些特性？
* Hashmap底层实现原理(get\put\resize)
* Hashmap怎么解决hash冲突？
* Hashmap是线程安全的吗？
* ...

今天就从源码角度一探究竟。笔者的源码是OpenJDK1.7

# 2. 构造方法

首先看构造方法的源码

```java
    // 默认初始容量
    static final int DEFAULT_INITIAL_CAPACITY = 16;
    // 默认负载因子
    static final float DEFAULT_LOAD_FACTOR = 0.75f;
    // 数组, 该数据不参与序列化
    transient Entry[] table;  
    
    public HashMap() {
        this.loadFactor = DEFAULT_LOAD_FACTOR;
        // 初始容量16，扩容因子0.75，扩容临界值12
        threshold = (int)(DEFAULT_INITIAL_CAPACITY * DEFAULT_LOAD_FACTOR);
        // 基础结构为Entry数组
        table = new Entry[DEFAULT_INITIAL_CAPACITY];
        init();
    }
```
由以上源码可知，Hashmap的初始容量默认是16, 底层存储结构是数组(到这里只能看出是数组, 其实还有链表，下边看源码解释)。基本存储单元是Entry，那Entry是什么呢?我们接着看Entry相关源码，


```java
    static class Entry<K,V> implements Map.Entry<K,V> {
        final K key;
        V value;
        Entry<K,V> next;    // 链表后置节点
        final int hash;

        /**
         * Creates new entry.
         */
        Entry(int h, K k, V v, Entry<K,V> n) {
            value = v;
            next = n;   // 头插法: newEntry.next=e
            key = k;
            hash = h;
        }
        ...
    }
```
由Entry源码可知，Entry是链表结构。综上所述，可以得出:
**Hashmap底层是基于数组和链表实现的**


# 3. Hashmap中put()过程

我已经将put过程绘制了流程图帮助大家理解

![](https://gitee.com/idea360/oss/raw/master/images/hashmap-java7-put.png)

先上put源码
```java
    public V put(K key, V value) {
        if (key == null)
            return putForNullKey(value);
        // 根据key计算hash
        int hash = hash(key.hashCode());
        // 计算元素在数组中的位置
        int i = indexFor(hash, table.length);
        // 遍历链表，如果相同覆盖
        for (Entry<K,V> e = table[i]; e != null; e = e.next) {
            Object k;
            if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
                V oldValue = e.value;
                e.value = value;
                e.recordAccess(this);
                return oldValue;
            }
        }

        modCount++;
        // 头插法插入元素
        addEntry(hash, key, value, i);
        return null;
    }
```

上图中多次提到头插法，啥是 `头插法` 呢？接下来看 `addEntry` 方法

```java
    void addEntry(int hash, K key, V value, int bucketIndex) {
        // 取出原bucket链表
        Entry<K,V> e = table[bucketIndex];
        // 头插法
        table[bucketIndex] = new Entry<>(hash, key, value, e);
        // 判断是否需要扩容
        if (size++ >= threshold)
            // 扩容好容量为原来的2倍
            resize(2 * table.length);
    }
```

结合Entry类的构造方法，每次插入新元素的时候，将bucket原链表取出，新元素的next指向原链表,这就是 `头插法` 。为了更加清晰的表示Hashmap存储结构，再绘制一张存储结构图。

![](https://gitee.com/idea360/oss/raw/master/images/hashmap-java7-data-constractor.png)

# 4. Hashmap中get()过程

get()逻辑相对比较简单，如图所示

![](https://gitee.com/idea360/oss/raw/master/images/hashmap-java7-get.png)

我们来对应下get()源码

```java
    public V get(Object key) {
        // 获取key为null的值
        if (key == null)
            return getForNullKey();
        // 根据key获取hash
        int hash = hash(key.hashCode());
        // 遍历链表，直到找到元素
        for (Entry<K,V> e = table[indexFor(hash, table.length)];
             e != null;
             e = e.next) {
            Object k;
            if (e.hash == hash && ((k = e.key) == key || key.equals(k)))
                return e.value;
        }
        return null;
    }
```

# 5. Hashmap中resize()过程

只要是新插入元素，即执行addEntry()方法，在插入完成后，都会判断是否需要扩容。从addEntry()方法可知，扩容后的容量为原来的2倍。

```java
    void resize(int newCapacity) {
        Entry[] oldTable = table;
        int oldCapacity = oldTable.length;
        if (oldCapacity == MAXIMUM_CAPACITY) {
            threshold = Integer.MAX_VALUE;
            return;
        }
        // 新建数组
        Entry[] newTable = new Entry[newCapacity];
        // 数据迁移
        transfer(newTable);
        // table指向新的数组
        table = newTable;
        // 新的扩容临界值
        threshold = (int)(newCapacity * loadFactor);
    }
```

这里有个transfer()方法没讲，别着急，扩容时线程安全的问题出现在这个方法中，接下来讲解数组复制过程。

# 6. Hashmap扩容安全问题

大家都知道结果: 多线程扩容有可能会形成环形链表，这里用图给大家模拟下扩容过程。

首先看下单线程扩容的头插法

![](https://gitee.com/idea360/oss/raw/master/images/Hashmap-java7-resize-singlethread.png)

然后看下多线程可能会出现的问题

![](https://gitee.com/idea360/oss/raw/master/images/java7-hashmap-resize-multithread.png)

以下是源码，你仔细品一品

```java
    void transfer(Entry[] newTable) {
        Entry[] src = table;
        int newCapacity = newTable.length;
        for (int j = 0; j < src.length; j++) {
            Entry<K,V> e = src[j];
            if (e != null) {
                // 释放旧Entry数组的对象引用
                src[j] = null;
                do {
                    Entry<K,V> next = e.next;
                    // 重新根据新的数组长度计算位置(同一个bucket上元素hash相等，所以扩容后必然还在一个链表上)
                    int i = indexFor(e.hash, newCapacity);
                    // 头插法(同一位置上新元素总会被放在链表的头部位置),将newTable[i]的引用赋给了e.next
                    e.next = newTable[i];
                    // 将元素放在数组上
                    newTable[i] = e;
                    // 访问下一个元素
                    e = next;
                } while (e != null);
            }
        }
    }
```

# 7. Hashmap寻找bucket位置

```java
    static int indexFor(int h, int length) {
        // 根据hash与数组长度mod运算
        return h & (length-1);
    }
```

由源码可知, jdk根据key的hash值和数组长度做mod运算，这里用位运算代替mod。

hash运算值是一个int整形值，在java中int占4个字节，32位，下边通过图示来说明位运算。

![](https://gitee.com/idea360/oss/raw/master/images/mod-vs-binary.png)

# 8. AD

如果您觉得还行，请关注公众号【当我遇上你】, 您的支持是我输出的最大动力。
同时，欢迎大家一起交流学习。

![](https://gitee.com/idea360/oss/raw/master/images/wechat-qr-code.png)

