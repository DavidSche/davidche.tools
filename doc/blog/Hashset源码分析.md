# 1. 概述

Hashset实现set接口，底层基于Hashmap实现, 但与Hashmap不同的实Hashmap存储键值对，Hashset仅存储对象。

HashSet使用成员对象来计算hashcode值。


# 2. 原理

在《Head fist java》一书中有描述:

当你把对象加入HashSet时，HashSet会先计算对象的hashcode值来判断对象加入的位置，同时也会与其他加入的对象的hashcode值作比较，如果没有相符的hashcode，HashSet会假设对象没有重复出现。但是如果发现有相同hashcode值的对象，这时会调用equals()方法来检查hashcode相等的对象是否真的相同。如果两者相同，则覆盖旧元素。

这里看到很多文章说: ~~如果equals()方法相等，HashSet就不会让加入操作成功~~。根据hashmap的put()方法源码可知，实际上是覆盖操作，虽然覆盖对象的key和value都完全一致。

**hashCode()与equals()的相关规定：**

- 如果两个对象相等，则hashcode一定也是相同的
- 两个对象相等,对两个equals方法返回true
- 两个对象有相同的hashcode值，它们也不一定是相等的
- 综上，equals方法被覆盖过，则hashCode方法也必须被覆盖
- hashCode()的默认行为是对堆上的对象产生独特值。如果没有重写hashCode()，则该class的两个对象无论如何都不会相等（即使这两个对象指向相同的数据）。


**==与equals的区别**

- ==是判断两个变量或实例是不是指向同一个内存空间 equals是判断两个变量或实例所指向的内存空间的值是不是相同
- ==是指对内存地址进行比较 equals()是对字符串的内容进行比较
- ==指引用是否相同 equals()指的是值是否相同

# 3. 源码分析

首先查看下源码结构，发现该类源码相对比较简单

![](https://gitee.com/idea360/oss/raw/master/images/hashset-method-all.png)

## 3.1 构造方法

```java
    /**
     * Constructs a new, empty set; the backing <tt>HashMap</tt> instance has
     * default initial capacity (16) and load factor (0.75).
     */
    // 内部存储在hashmap中
    public HashSet() {
        map = new HashMap<>();
    }
```
## 3.2 添加元素add()

```java
private static final Object PRESENT = new Object();
    public boolean add(E e) {
        return map.put(e, PRESENT)==null;
    }
```

可以看到添加的对象直接作为Hashmap的key, 而value是final修饰的空对象。

根据之前对 [Java面试必问之Hashmap底层实现原理(JDK1.8)](https://mp.weixin.qq.com/s/ugBm-koApBRepbSQ2kiV2A) 中 `put()` 方法的解读可以知道:

在Hashmap中首先根据hashCode寻找数组bucket，当hash冲突时，需要比较key是否相等，相等则覆盖，否则通过拉链法进行处理。在Hashset中存储的对象作为key，所以存储对象需要重写 `hashCode()` 和 `equals()` 方法。


# 4. 使用案例分析

## 4.1 存储字符串案例

再来看一组示例

```java
public class Demo2 {

    public static void main(String[] args) {
        HashSet<Object> hashSet = new HashSet<>();
        hashSet.add("a");
        hashSet.add("b");
        hashSet.add("c");
        hashSet.add("a");
        System.out.println(hashSet);
    }
}
```

结果

```
[a, b, c]
```

**分析**

查看字符串源码.字符串重写了hashCode()和equals方法, 所以结果符合预期

```java
    public int hashCode() {
        int h = hash;
        if (h == 0 && value.length > 0) {
            char val[] = value;

            for (int i = 0; i < value.length; i++) {
                h = 31 * h + val[i];
            }
            hash = h;
        }
        return h;
    }


    public boolean equals(Object anObject) {
        if (this == anObject) {
            return true;
        }
        if (anObject instanceof String) {
            String anotherString = (String)anObject;
            int n = value.length;
            if (n == anotherString.value.length) {
                char v1[] = value;
                char v2[] = anotherString.value;
                int i = 0;
                while (n-- != 0) {
                    if (v1[i] != v2[i])
                        return false;
                    i++;
                }
                return true;
            }
        }
        return false;
    }    }
```

## 4.2 存储对象错误案例

首先我们创建一个 `user` 对象

```java
@Getter@Setter
@AllArgsConstructor
@ToString
public class User {

    private String username;

}
```

根据set集合的属性，set中的元素是不重复的，现在测试下

```java
public class Demo {

    public static void main(String[] args) {
        HashSet<Object> hashSet = new HashSet<>();
        hashSet.add(new User("a"));
        hashSet.add(new User("b"));
        hashSet.add(new User("c"));
        hashSet.add(new User("a"));
        System.out.println(hashSet);
    }
}
```

结果输出

```
[User(username=a), User(username=c), User(username=b), User(username=a)]
```

怎么会有重复的呢? 和预期结果不符呀。其实根据上边的源码我们已经知道原因了，打印hash值确认下

```
[901506536, 1513712028, 747464370, 1018547642]
```

java中对象默认继承顶级父类Object。在Object类中源码如下:

```java
    public native int hashCode();
    // 比较内存地址
    public boolean equals(Object obj) {
        return (this == obj);
    }
```

## 4.3 存储对象正确示范

重写equals()和hashCode()方法。(这里偷了个懒，感兴趣的大家可以自己重写下这2个方法)

```java
@Getter@Setter
@AllArgsConstructor
@ToString
@EqualsAndHashCode
public class User extends Object{

    private String username;

}
```

再次输出发现结果唯一了

```
[User(username=a), User(username=b), User(username=c)]
```


# 5. 总结

其实HashSet的一些东西都是用HashMap来实现的，如果HashMap的源码已经阅读过的话基本上没有什么问题。这可能是我写的最轻松的一篇文章。