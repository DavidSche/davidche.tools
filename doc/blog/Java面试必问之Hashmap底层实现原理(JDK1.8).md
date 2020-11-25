# 1. 前言

上一篇从源码方面了解了JDK1.7中Hashmap的实现原理，可以看到其源码相对还是比较简单的。本篇笔者和大家一起学习下JDK1.8下Hashmap的实现。JDK1.8中对Hashmap做了以下改动。

- 默认初始化容量=0
- 引入红黑树，优化数据结构
- 将链表头插法改为尾插法，解决1.7中多线程循环链表的bug
- 优化hash算法
- resize计算索引位置的算法改进
- 先插入后扩容

# 2. Hashmap中put()过程

笔者的源码是OpenJDK1.8的源码。

JDK1.8中，Hashmap将基本元素由Entry换成了Node，不过查看源码后发现换汤不换药，这里没啥好说的。

下图是一位大神级别画的图，自己就不再造轮子了。客官请看

![](https://gitee.com/idea360/oss/raw/master/images/hashmap-java8-put.png)

put()源码如下

```java
    public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        // 判断数组是否为空，长度是否为0，是则进行扩容数组初始化
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        // 通过hash算法找到数组下标得到数组元素，为空则新建
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            // 找到数组元素，hash相等同时key相等，则直接覆盖
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            // 该数组元素在链表长度>8后形成红黑树结构的对象,p为树结构已存在的对象
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                // 该数组元素hash相等，key不等，同时链表长度<8.进行遍历寻找元素，有就覆盖无则新建
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        // 新建链表中数据元素，尾插法
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            // 链表长度>=8 结构转为 红黑树
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            // 新值覆盖旧值
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                // onlyIfAbsent默认false
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        // 判断是否需要扩容
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```

基本过程如下:

1. 检查数组是否为空，执行resize()扩充；在实例化HashMap时，并不会进行初始化数组）

2. 通过hash值计算数组索引，获取该索引位的首节点。

3. 如果首节点为null（没发生碰撞），则创建新的数组元素，直接添加节点到该索引位(bucket)。

4. 如果首节点不为null（发生碰撞），那么有3种情况

    ① key和首节点的key相同，覆盖old value（保证key的唯一性）；否则执行②或③

    ② 如果首节点是红黑树节点（TreeNode），将键值对添加到红黑树。

    ③ 如果首节点是链表，进行遍历寻找元素，有就覆盖无则新建，将键值对添加到链表。添加之后会判断链表长度是否到达TREEIFY_THRESHOLD - 1这个阈值，“尝试”将链表转换成红黑树。

5. 最后判断当前元素个数是否大于threshold，扩充数组。

# 3. Hashmap中get()过程

```java
    public V get(Object key) {
        Node<K,V> e;
        return (e = getNode(hash(key), key)) == null ? null : e.value;
    }

    final Node<K,V> getNode(int hash, Object key) {
        Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (first = tab[(n - 1) & hash]) != null) {
            // 永远检查第一个node
            if (first.hash == hash && // always check first node
                ((k = first.key) == key || (key != null && key.equals(k))))
                return first;
            if ((e = first.next) != null) {
                if (first instanceof TreeNode)  // 树查找
                    return ((TreeNode<K,V>)first).getTreeNode(hash, key);
                do {
                    if (e.hash == hash &&   // 遍历链表
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        return e;
                } while ((e = e.next) != null);
            }
        }
        return null;
    }
```

在Hashmap1.8中，无论是存元素还是取元素，都是优先判断bucket上第一个元素是否匹配，而在1.7中则是直接遍历查找。

基本过程如下:

1. 根据key计算hash;
2. 检查数组是否为空，为空返回null;
3. 根据hash计算bucket位置，如果bucket第一个元素是目标元素，直接返回。否则执行4;
4. 如果bucket上元素大于1并且是树结构，则执行树查找。否则执行5;
5. 如果是链表结构，则遍历寻找目标


# 4. Hashmap中resize()过程

```java
    final Node<K,V>[] resize() {
        Node<K,V>[] oldTab = table;
        int oldCap = (oldTab == null) ? 0 : oldTab.length;
        int oldThr = threshold;
        int newCap, newThr = 0;
        if (oldCap > 0) {
            // 如果已达到最大容量不在扩容
            if (oldCap >= MAXIMUM_CAPACITY) {
                threshold = Integer.MAX_VALUE;
                return oldTab;
            }
            // 通过位运算扩容到原来的两倍
            else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                     oldCap >= DEFAULT_INITIAL_CAPACITY)
                newThr = oldThr << 1; // double threshold
        }
        else if (oldThr > 0) // initial capacity was placed in threshold
            newCap = oldThr;
        else {               // zero initial threshold signifies using defaults
            newCap = DEFAULT_INITIAL_CAPACITY;
            newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
        }
        if (newThr == 0) {
            float ft = (float)newCap * loadFactor;
            newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                      (int)ft : Integer.MAX_VALUE);
        }
        // 新的扩容临界值
        threshold = newThr;
        @SuppressWarnings({"rawtypes","unchecked"})
            Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
        table = newTab;
        if (oldTab != null) {
            for (int j = 0; j < oldCap; ++j) {
                Node<K,V> e;
                if ((e = oldTab[j]) != null) {
                    oldTab[j] = null;
                    // 如果该位置元素没有next节点，将该元素放入新数组
                    if (e.next == null)
                        newTab[e.hash & (newCap - 1)] = e;
                    else if (e instanceof TreeNode)
                        // 树节点
                        ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                    else { // preserve order
                        // 链表节点。

                        // lo串的新索引位置与原先相同
                        Node<K,V> loHead = null, loTail = null;
                        // hi串的新索引位置为[原先位置j+oldCap]
                        Node<K,V> hiHead = null, hiTail = null;
                        Node<K,V> next;
                        do {
                            next = e.next;
                            // 原索引，oldCap是2的n次方，二进制表示只有一个1，其余是0
                            if ((e.hash & oldCap) == 0) {
                                if (loTail == null)
                                    loHead = e;
                                else
                                    // 尾插法
                                    loTail.next = e;
                                loTail = e;
                            }
                            // 原索引+oldCap
                            else {
                                if (hiTail == null)
                                    hiHead = e;
                                else
                                    hiTail.next = e;
                                hiTail = e;
                            }
                        } while ((e = next) != null);
                        // 根据hash判断该bucket上的整个链表的index还是旧数组的index，还是index+oldCap
                        if (loTail != null) {
                            loTail.next = null;
                            newTab[j] = loHead;
                        }
                        if (hiTail != null) {
                            hiTail.next = null;
                            newTab[j + oldCap] = hiHead;
                        }
                    }
                }
            }
        }
        return newTab;
    }
```

JDK1.8版本中扩容相对复杂。在1.7版本中，重新根据hash计算索引位置即可；而在1.8版本中分2种情况，下边用图例来解释。

![](https://gitee.com/idea360/oss/raw/master/images/hashmap-java8-resize-index-unchange.png)

---

![](https://gitee.com/idea360/oss/raw/master/images/hashmap-java8-resize-index-change.png)

# 5. 总结

其余还有为什么阈值=8转红黑树，长度<=6 转链表这些问题。基本都是数据科学家根据概率做出的经验值，同时避免数据结构频繁的转换引起的性能开销。

整体看来，JDK1.8主要在数据结构、算法和性能上对1.7进行了优化。

# 6. AD

欢迎大家关注公众号【当我遇上你】, 每天第一时间与您分享干货。

![](https://gitee.com/idea360/oss/raw/master/images/wechat-qr-code.png)


