# 1. 前言

还是从面试中来，到面试中去。面试官在面试Redis的时候经常会问到，Redis的LRU是如何实现的？如果让你实现LRU算法，你会怎么实现呢？除了用现有的结构LinkedHashMap实现，你可以自己实现一个吗？跳跃表、小顶堆行不行...

阅读这篇文章前建议大家先熟悉下[Java面试必问之Hashmap底层实现原理(JDK1.8)](https://mp.weixin.qq.com/s/ugBm-koApBRepbSQ2kiV2A)。LinkedHashMap基于HashMap实现，其中很多方法都是在HashMap上进行了增强。


# 2. 使用LinkedHashMap实现LRU缓存

实现代码如下:

```java
public class LRUCache<K, V> extends LinkedHashMap<K, V> {

    private int cacheSize;

    public LRUCache(int cacheSize) {
        super(16, (float) 0.75, true);
        this.cacheSize = cacheSize;
    }

    /**
     * 判断节点数是否超限
     * @param eldest
     * @return 超限返回 true，否则返回 false
     */
    @Override
    protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
        return size() > cacheSize;
    }
}
```

测试代码如下:

```java
/**
 * 输出结果:
 * 17:44:31.635 [main] INFO com.demo.cache.Test - 所有的缓存:{key0=0, key1=1, key2=2}
 * 17:44:31.641 [main] INFO com.demo.cache.Test - 访问key0后的缓存:{key1=1, key2=2, key0=0}
 * 17:44:31.642 [main] INFO com.demo.cache.Test - 测试热点缓存:{key2=2, key0=0, key3=3}
 */
@Slf4j
public class Test {

    public static void main(String[] args) {

        LRUCache<Object, Object> lruCache = new LRUCache<>(3);

        for (int i=0; i<3; i++) {
            lruCache.put("key" + i, i);
        }

        log.info("所有的缓存:{}", lruCache);

        // 理论上刚访问过key0，key0应该放在链表尾部，代表最近使用，删除策略从头部删除
        lruCache.get("key0");
        log.info("访问key0后的缓存:{}", lruCache);

        // 新插入缓存，超过了缓存阈值，理论上会删除链表头部元素，并将新缓存放置在链表尾部。
        lruCache.put("key3", 3);
        log.info("测试热点缓存:{}", lruCache);

    }
}
```

# 3. 源码分析

Redis中LRU的实现暂时没有研究，大家可以看下别人的分析，这里只做java部分的分析。

> *笔者的代码环境是OpenJDK8*

LinkedHashMap底层依旧基于HashMap实现，同时增加了一条双向链表，使得上面的结构可以保持键值对的插入顺序。同时通过对链表进行相应的操作，实现了访问顺序相关逻辑。

## 3.1 基础节点Entry

```java
    static class Entry<K,V> extends HashMap.Node<K,V> {
        Entry<K,V> before, after;
        // 构造方法直接复用Hashmap的构造方法
        Entry(int hash, K key, V value, Node<K,V> next) {
            super(hash, key, value, next);
        }
    }
```

基础节点的继承自HashMap的Node节点.


## 3.2 新增节点

查看源码方法列表可以看出，源码中没有put()方法，那一定是继承父类Hashmap的put()方法。

![](https://gitee.com/idea360/oss/raw/master/images/java8-linkedhashmap-method-list.png)

这里我们再看下链表的插入逻辑

```java

    // HashMap方法
    public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }

    // HashMap方法
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
                // 需要子类实现
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        // 判断是否需要扩容
        if (++size > threshold)
            resize();
        // 需要子类实现，默认是true
        afterNodeInsertion(evict);
        return null;
    }

    // 覆盖HashMap方法,新创建Entry节点的元素放在链表尾部(需要新建节点的走这里，包括链表和红黑树)
    Node<K,V> newNode(int hash, K key, V value, Node<K,V> e) {
        LinkedHashMap.Entry<K,V> p =
            new LinkedHashMap.Entry<K,V>(hash, key, value, e);
        linkNodeLast(p);
        return p;
    }

    // 将元素插入到双端链表尾部
    private void linkNodeLast(LinkedHashMap.Entry<K,V> p) {
        LinkedHashMap.Entry<K,V> last = tail;
        tail = p;
        // 数组和链表都为空，首尾指针指向当前节点
        if (last == null)
            head = p;
        else {
            // 移动尾指针指向新节点
            p.before = last;
            last.after = p;
        }
    }


    // 将被访问节点移动到链表最后(覆盖旧节点value的走这里，包括链表和红黑树)
    void afterNodeAccess(Node<K,V> e) { // move node to last
        LinkedHashMap.Entry<K,V> last;
        if (accessOrder && (last = tail) != e) {
            LinkedHashMap.Entry<K,V> p =
                (LinkedHashMap.Entry<K,V>)e, b = p.before, a = p.after;
            p.after = null;
            if (b == null)
                head = a;
            else
                b.after = a;
            if (a != null)
                a.before = b;
            else
                last = b;
            if (last == null)
                head = p;
            else {
                p.before = last;
                last.after = p;
            }
            tail = p;
            ++modCount;
        }
    }

    // 根据条件判断是否移除最近最少被访问的节点
    void afterNodeInsertion(boolean evict) { // possibly remove eldest
        LinkedHashMap.Entry<K,V> first;
        if (evict && (first = head) != null && removeEldestEntry(first)) {
            K key = first.key;
            // 删除头节点
            removeNode(hash(key), key, null, false, true);
        }
    }

    // 覆盖此方法可实现不同的策略缓存, 
    protected boolean removeEldestEntry(Map.Entry<K,V> eldest) {
        return false;
    }
```

基本插入逻辑和HashMap是相同的，我把需要子类覆写的地方用不同颜色表示出来了，具体见下图:

![](https://gitee.com/idea360/oss/raw/master/images/java8-linkedhashmap-put.jpg)


## 3.3 删除节点

```java

    // HashMap实现
    public V remove(Object key) {
        Node<K,V> e;
        return (e = removeNode(hash(key), key, null, false, true)) == null ?
            null : e.value;
    }
    // HashMap实现
    final Node<K,V> removeNode(int hash, Object key, Object value,
                               boolean matchValue, boolean movable) {
        Node<K,V>[] tab; Node<K,V> p; int n, index;
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (p = tab[index = (n - 1) & hash]) != null) {
            Node<K,V> node = null, e; K k; V v;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                node = p;
            else if ((e = p.next) != null) {
                if (p instanceof TreeNode)
                    node = ((TreeNode<K,V>)p).getTreeNode(hash, key);
                else {
                    do {
                        if (e.hash == hash &&
                            ((k = e.key) == key ||
                             (key != null && key.equals(k)))) {
                            node = e;
                            break;
                        }
                        p = e;
                    } while ((e = e.next) != null);
                }
            }
            if (node != null && (!matchValue || (v = node.value) == value ||
                                 (value != null && value.equals(v)))) {
                if (node instanceof TreeNode)
                    ((TreeNode<K,V>)node).removeTreeNode(this, tab, movable);
                else if (node == p)
                    tab[index] = node.next;
                else
                    p.next = node.next;
                ++modCount;
                --size;
                // 默认空实现，子类中实现删除回调
                afterNodeRemoval(node);
                return node;
            }
        }
        return null;
    }

    // LinkedHashMap中实现。删除节点后的链表维护
    void afterNodeRemoval(Node<K,V> e) { // unlink
        LinkedHashMap.Entry<K,V> p =
            (LinkedHashMap.Entry<K,V>)e, b = p.before, a = p.after;
        p.before = p.after = null;
        if (b == null)
            head = a;
        else
            b.after = a;
        if (a == null)
            tail = b;
        else
            a.before = b;
    }
```

删除节点的逻辑比较简单，和HashMap基本一样，删除节点后重新维护前后节点指针即可。

## 3.4 获取节点(最近使用节点移动至尾节点)

```java
    // 重写HashMap方法
    public V get(Object key) {
        Node<K,V> e;
        if ((e = getNode(hash(key), key)) == null)
            return null;

        // 如果accessOrder=true,则获取节点元素后将该节点移动至链表尾部(删除旧节点从头部删除)
        if (accessOrder)
            afterNodeAccess(e);
        return e.value;
    }

    // LinkedHashMap 中覆写。将被访问节点移动到链表最后(覆盖旧节点value的走这里，包括链表和红黑树)
    // 将被访问节点移动到链表最后(覆盖旧节点value的走这里，包括链表和红黑树)
    void afterNodeAccess(Node<K,V> e) { // move node to last
        LinkedHashMap.Entry<K,V> last;
        if (accessOrder && (last = tail) != e) {
            LinkedHashMap.Entry<K,V> p =
                (LinkedHashMap.Entry<K,V>)e, b = p.before, a = p.after;
            p.after = null;
            if (b == null)
                head = a;
            else
                // 移除节点e,并重新维护前后节点链表指针
                b.after = a;
            if (a != null)
                // 移除节点e,并重新维护前后节点链表指针
                a.before = b;
            else
                last = b;
            if (last == null)
                head = p;
            else {
                // 将节点e移动到链表尾部
                p.before = last;
                last.after = p;
            }
            tail = p;
            ++modCount;
        }
    }
```

从代码中可以看到，每次调用get方法时，如果开启了accessOrder，则会将当前元素移动到链表尾部。

# 4. 总结

本来源码加配图学习会更加容易明白，奈何绘图功底有限。大家有什么比较好用的工具可以推荐一下。到此，本篇文章就写完了，感谢大家的阅读！如果您觉得对您有帮助，请关注公众号【当我遇上你】。