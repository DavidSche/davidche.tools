# Hashmap底层实现原理

## put流程

源码,基于1.8(1.8引入红黑树，链表由1.7的头插法改为尾插法)

```java
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
            // 该数组元素在链表长度>8后形成红黑树结构的对象
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                // 该数组元素hash相等，key不等，同时链表长度<8.进行遍历寻找元素，有就覆盖无则新建
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        // 新建链表中数据元素
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
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```

下图是一位大神级别画的图，引用一下便于理解

![hashmap-put](../assets/hashmap-put.png)

1. 检查数组是否为空，执行resize()扩充；在实例化HashMap时，并不会进行初始化数组）

2. 通过hash值计算数组索引，获取该索引位的首节点。

3. 如果首节点为null（没发生碰撞），则创建新的数组元素，直接添加节点到该索引位(bucket)。

4. 如果首节点不为null（发生碰撞），那么有3种情况

   ① key和首节点的key相同，覆盖old value（保证key的唯一性）；否则执行②或③

   ② 如果首节点是红黑树节点（TreeNode），将键值对添加到红黑树。

   ③ 如果首节点是链表，进行遍历寻找元素，有就覆盖无则新建，将键值对添加到链表。添加之后会判断链表长度是否到达TREEIFY_THRESHOLD - 1这个阈值，“尝试”将链表转换成红黑树。

5. 最后判断当前元素个数是否大于threshold，扩充数组。



## resize() 数组扩容

扩充数组不单单只是让数组长度翻倍，将原数组中的元素直接存入新数组中这么简单。
因为元素的索引是通过hash&(n - 1)得到的，那么数组的长度由n变为2n，重新计算的索引就可能和原来的不一样了。
在jdk1.7中，是通过遍历每一个元素，每一个节点，重新计算他们的索引值，存入新的数组中，称为rehash操作。
而java1.8对此进行了一些优化，没有了rehash操作。因为当数组长度是通过2的次方扩充的，那么会发现以下规律：
元素的位置要么是在原位置，要么是在原位置再移动2次幂的位置。因此，在扩充HashMap的时候，不需要像JDK1.7的实现那样重新计算hash，只需要看看原来的hash值高位新增的那个bit是1还是0就好了，是0的话索引没变，是1的话索引变成“原索引+oldCap”。因为容量扩容2倍相当于二进制高位加一
先计算新数组的长度和新的阈值（threshold），然后将旧数组的内容迁移到新数组中，和1.7相比不需要执行rehash操作。因为以2次幂扩展的数组可以简单通过新增的bit判断索引位。



## 单线程rehash

![single_thread_rehash](../assets/single_thread_rehash.png)



##  HashMap 多线程操作导致死循环问题

在多线程下，进行 put 操作会导致 HashMap 死循环(java7链表头插法引起的)，原因在于 HashMap 的扩容 resize()方法。由于扩容是新建一 个数组，复制原数据到数组。由于数组下标挂有链表，所以需要复制链表，但是多线程操作有可能导致环形链表。复制链表过程如下:



假设链表为	A.next=B,B.next=null,链表头为A。

1. 线程一读取到当前的 HashMap 情况，在准备扩容时，线程二介入；扩容复制过程为先将 A 复制到新的 hash 表中，然后接着复制 B 到链头。此时的链表变为 B.next=A, A.next=null;

2. 这时候切换为线程一执行，根据上下文保存状态，先取出A并将A插入链头，此时A.next=B,由于线程二的原因，B.next=A, 因此形成环形链表。

   

![java7Hashmap扩容环形链表演示](../assets/java7Hashmap扩容环形链表演示.png)







## 参考

- [https://lushunjian.github.io/blog/2019/01/02/HashMap%E7%9A%84%E5%BA%95%E5%B1%82%E5%AE%9E%E7%8E%B0/](https://lushunjian.github.io/blog/2019/01/02/HashMap的底层实现/)