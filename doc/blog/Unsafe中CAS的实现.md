# 前言

Unsafe是位于sun.misc包下的一个类。Unsafe提供的API大致可分为内存操作、CAS、Class相关、对象操作、线程调度、系统信息获取、内存屏障、数组操作等几类。由于并发相关的源码很多用到了CAS，比如java.util.concurrent.atomic相关类、AQS、CurrentHashMap等相关类。所以本文主要讲Unsafe中CAS的实现。笔者源码环境为 `OpenJDK8`。


# CAS相关

主要相关源码

```java
    /**
     * 参数说明
     * @param o             包含要修改field的对象
     * @param offset        对象中某个参数field的偏移量,该偏移量不会改变
     * @param expected      期望该偏移量对应的field值
     * @param x             更新值
     * @return              true|false
     */
    public final native boolean compareAndSwapObject(Object o, long offset,
                                                     Object expected,
                                                     Object x);

    public final native boolean compareAndSwapInt(Object o, long offset,
                                                  int expected,
                                                  int x);

    public final native boolean compareAndSwapLong(Object o, long offset,
                                                   long expected,
                                                   long x);
```

CAS是实现并发算法时常用到的一种技术。CAS操作包含三个操作数——内存位置、预期原值及新值。执行CAS操作的时候，将内存位置的值与预期原值比较，如果相匹配，那么处理器会自动将该位置值更新为新值，否则，处理器不做任何操作。我们都知道，CAS是一条CPU的 `原子指令`（cmpxchg指令），不会造成所谓的数据不一致问题，Unsafe提供的CAS方法（如compareAndSwapXXX）底层实现即为CPU指令cmpxchg。

> 说明：对象的基地址baseAddress+valueOffset得到value的内存地址valueAddress

# Unsafe类获取

首先看下Unsafe的单例实现

```java
    private static final Unsafe theUnsafe = new Unsafe();
    // 注解表明需要引导类加载器
    @CallerSensitive
    public static Unsafe getUnsafe() {
        Class<?> caller = Reflection.getCallerClass();
        // 仅在引导类加载器`BootstrapClassLoader`加载时才合法
        if (!VM.isSystemDomainLoader(caller.getClassLoader()))
            throw new SecurityException("Unsafe");
        return theUnsafe;
    }
```

那如若想使用这个类，该如何获取其实例？有如下两个可行方案。

其一，从 `getUnsafe` 方法的使用限制条件出发，通过Java命令行命令 `-Xbootclasspath/a` 把调用Unsafe相关方法的类A所在jar包路径追加到默认的bootstrap路径中，使得A被引导类加载器加载，从而通过 `Unsafe.getUnsafe` 方法安全的获取Unsafe实例。

```java
java -Xbootclasspath/a: ${path}   // 其中path为调用Unsafe相关方法的类所在jar包路径 
```

其二，通过反射获取单例对象theUnsafe。

```java
@Slf4j
public class UnsafeTest {

    private static Unsafe reflectGetUnsafe() {
        try {
            Field field = Unsafe.class.getDeclaredField("theUnsafe");
            field.setAccessible(true);
            return (Unsafe) field.get(null);
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            return null;
        }
    }

    public static void main(String[] args) {
        Unsafe unsafe = UnsafeTest.reflectGetUnsafe();
    }
}
```

# CAS演练

1. 创建一个类

```java
@Getter@Setter
public class User {
    private String name;
    private int age;
}
```

2. 反射获取Unsafe并测试CAS

```java
@Slf4j
public class UnsafeTest {

    private static Unsafe reflectGetUnsafe() {
        try {
            Field field = Unsafe.class.getDeclaredField("theUnsafe");
            field.setAccessible(true);
            return (Unsafe) field.get(null);
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            return null;
        }
    }

    public static void main(String[] args) throws Exception{
        Unsafe unsafe = UnsafeTest.reflectGetUnsafe();
        // allocateInstance: 对象操作。绕过构造方法、初始化代码来创建对象
        User user = (User)unsafe.allocateInstance(User.class);
        user.setName("admin");
        user.setAge(17);


        Field name = User.class.getDeclaredField("name");
        Field age = User.class.getDeclaredField("age");

        // objectFieldOffset: 返回对象成员属性在内存地址相对于此对象的内存地址的偏移量
        long nameOffset = unsafe.objectFieldOffset(name);
        long ageOffset = unsafe.objectFieldOffset(age);

        System.out.println("name内存偏移地址:" + nameOffset);
        System.out.println("age 内存偏移地址:" + ageOffset);

        System.out.println("---------------------");

        // CAS操作
        int currentValue = unsafe.getIntVolatile(user, ageOffset);
        System.out.println("age内存当前值:" + currentValue);
        boolean casAge = unsafe.compareAndSwapInt(user, ageOffset, 17, 18);
        System.out.println("age进行CAS更新成功:" + casAge);
        System.out.println("age更新后的值:" + user.getAge());

        System.out.println("---------------------");

        // volatile修饰,保证可见性、有序性
        unsafe.putObjectVolatile(user, nameOffset, "test");
        System.out.println("name更新后的值:" + unsafe.getObjectVolatile(user, nameOffset));
        
    }
}
```

结果输出

```
name内存偏移地址:16
age 内存偏移地址:12
---------------------
age内存当前值:17
age进行CAS更新成功:true
age更新后的值:18
---------------------
name更新后的值:test
```

Unsafe中CAS操作是原子性的，所以在秒杀、库存扣减中也可以使用Unsafe来扣减库存。

# 结语

本文对Java中的sun.misc.Unsafe的用法及应用场景进行了基本介绍，仅做后续源码阅读的铺垫。到此，本篇文章就写完了，感谢大家的阅读！如果您觉得对您有帮助，请关注公众号【当我遇上你】。