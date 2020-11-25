# 前言

曾经有一次，面试官问到类加载机制，相信大多数小伙伴都可以答上来`双亲委派机制`，也都知道JVM出于安全性的考虑，全限定类名相同的String是不能被加载的。但是如果加载了，会出现什么样的结果呢？异常？那是什么样的异常。如果包名不相同呢？自定义类加载器是否可以加载呢？相信面试官从各种不同的角度出击，很快就会答出漏洞，毕竟咱没有深入研究过虚拟机...

接下来笔者就针对上述问题进行一一验证。该篇文章抱着求证答案的方向出发，并无太多理论方面的详解。如有理解上的偏差，还望大家不吝赐教。

# JVM都有哪些类加载器

首先我们放上一张节选自网络的JVM类加载机制示意图

![](https://gitee.com/idea360/oss/raw/master/images/jvm-load-class-diagram.png)

JVM 中内置了三个重要的 ClassLoader，除了 BootstrapClassLoader 其他类加载器均由 Java 实现且全部继承自java.lang.ClassLoader：

- **BootstrapClassLoader(启动类加载器)** ：最顶层的加载类，由C++实现，负责加载 %JAVA_HOME%/lib目录下的jar包和类或者或被 -Xbootclasspath参数指定的路径中的所有类。

- **ExtensionClassLoader(扩展类加载器)** ：主要负责加载目录 %JRE_HOME%/lib/ext 目录下的jar包和类，或被 java.ext.dirs 系统变量所指定的路径下的jar包。

- **AppClassLoader(应用程序类加载器)** :面向我们用户的加载器，负责加载当前应用classpath下的所有jar包和类。


# JVM类加载方式

类加载有三种方式：

- 1、命令行启动应用时候由JVM初始化加载
- 2、通过Class.forName()方法动态加载
- 3、通过ClassLoader.loadClass()方法动态加载


**Class.forName()和ClassLoader.loadClass()区别**

- `Class.forName()`：将类的.class文件加载到jvm中之外，还会对类进行解释，执行类中的static块；
- `ClassLoader.loadClass()`：只干一件事情，就是将.class文件加载到jvm中，不会执行static中的内容,只有在newInstance才会去执行static块。
- `Class.forName(name,initialize,loader)`带参函数也可控制是否加载static块。并且只有调用了newInstance()方法采用调用构造函数，创建类的对象 。


# JVM类加载机制

- **全盘负责**，当一个类加载器负责加载某个Class时，该Class所依赖的和引用的其他Class也将由该类加载器负责载入，除非显示使用另外一个类加载器来载入

- **父类委托**，先让父类加载器试图加载该类，只有在父类加载器无法加载该类时才尝试从自己的类路径中加载该类

- **缓存机制**，缓存机制将会保证所有加载过的Class都会被缓存，当程序中需要使用某个Class时，类加载器先从缓存区寻找该Class，只有缓存区不存在，系统才会读取该类对应的二进制数据，并将其转换成Class对象，存入缓存区。这就是为什么修改了Class后，必须重启JVM，程序的修改才会生效


# JVM类加载机制源码

双亲委派模型实现源码分析

```java
private final ClassLoader parent; 
protected Class<?> loadClass(String name, boolean resolve)
        throws ClassNotFoundException
    {
        synchronized (getClassLoadingLock(name)) {
            // 首先，检查请求的类是否已经被加载过
            Class<?> c = findLoadedClass(name);
            if (c == null) {
                long t0 = System.nanoTime();
                try {
                    if (parent != null) {//父加载器不为空，调用父加载器loadClass()方法处理
                        c = parent.loadClass(name, false);
                    } else {//父加载器为空，使用启动类加载器 BootstrapClassLoader 加载
                        c = findBootstrapClassOrNull(name);
                    }
                } catch (ClassNotFoundException e) {
                   //抛出异常说明父类加载器无法完成加载请求
                }

                if (c == null) {
                    long t1 = System.nanoTime();
                    //自己尝试加载
                    c = findClass(name);

                    // this is the defining class loader; record the stats
                    sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
                    sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
                    sun.misc.PerfCounter.getFindClasses().increment();
                }
            }
            if (resolve) {
                resolveClass(c);
            }
            return c;
        }
    }
```

**双亲委派模型的好处**

双亲委派模型保证了Java程序的稳定运行，可以避免类的重复加载（JVM 区分不同类的方式不仅仅根据类名，相同的类文件被不同的类加载器加载产生的是两个不同的类），也保证了 Java 的核心 API 不被篡改。如果没有使用双亲委派模型，而是每个类加载器加载自己的话就会出现一些问题，比如我们编写一个称为 `java.lang.Object` 类的话，那么程序运行的时候，系统就会出现多个不同的 `Object` 类。


**如果我们不想用双亲委派模型怎么办？**

为了避免双亲委托机制，我们可以自己定义一个类加载器，然后重写 `loadClass()` 即可。


# 系统类加载器加载自定义String


**1. 首先我们看下普通的类加载过程**

```java
package com.example.demojava.loadclass;
public class ClassLoaderDemo{

    public static void main(String[] args) {
        System.out.println("ClassLodarDemo's ClassLoader is " + ClassLoaderDemo.class.getClassLoader());
        System.out.println("The Parent of ClassLodarDemo's ClassLoader is " + ClassLoaderDemo.class.getClassLoader().getParent());
        System.out.println("The GrandParent of ClassLodarDemo's ClassLoader is " + ClassLoaderDemo.class.getClassLoader().getParent().getParent());
    }
}
```

结果输出
```
ClassLodarDemo's ClassLoader is sun.misc.Launcher$AppClassLoader@18b4aac2
The Parent of ClassLodarDemo's ClassLoader is sun.misc.Launcher$ExtClassLoader@75bd9247
The GrandParent of ClassLodarDemo's ClassLoader is null
```

`AppClassLoader`的父类加载器为`ExtClassLoader`
`ExtClassLoader`的父类加载器为null，**null并不代表`ExtClassLoader`没有父类加载器，而是 `BootstrapClassLoader`** 。

**2. 我们自己定义一个String类,看下会发生什么**

```java
package com.example.demojava.loadclass;

public class String {
    public static void main(String[] args) {
        System.out.println("我是自定义的String");
    }
}
```

结果输出
```
➜  demo-java javac src/main/java/com/example/demojava/loadclass/String.java 
➜  demo-java java src.main.java.com.example.demojava.loadclass.String 
错误: 找不到或无法加载主类 src.main.java.com.example.demojava.loadclass.String
```

这里分明有main方法，全限定类名又和jdk的String不在同一个package(不会造成冲突)，为什么会输出找不到或无法加载主类呢？

细心的小伙伴一定会发现该类'没有导入'系统的String类，会不会因为JVM的类加载机制，AppClassLoader加载类的时候，由于自定义的String被加载，拦截了上层的String类呢？String对象是自定义的，不符合main()方法的定义方式，故系统抛找不到main()方法。

我们反过来验证下刚才的推测，再次运行刚才的ClassLoaderDemo会发生什么呢？what？IDE中的main()方法去哪里了？还是手动编译运行下吧

```
➜  demo-java javac src/main/java/com/example/demojava/loadclass/ClassLoaderDemo.java 
➜  demo-java java src.main.java.com.example.demojava.loadclass.ClassLoaderDemo 
错误: 找不到或无法加载主类 src.main.java.com.example.demojava.loadclass.ClassLoaderDemo
```

结果显示: 之前正常运行的java类也找不到主类了。

我们导入正确的String类再来验证下
```java
package com.example.demojava.loadclass;

public class String {
    public static void main(java.lang.String[] args) {
        System.out.println("我是自定义的String");
    }
}
```

结果输出
```
我是自定义的String
```

**3. 能否覆写lang包下的String类?**

上边的案例修改包路径即可

```java
package java.lang;

public class String {
    public static void main(java.lang.String[] args) {
        System.out.println("我是自定义的String");
    }
}
```
输出报错
```
Connected to the target VM, address: '127.0.0.1:63569', transport: 'socket'
错误: 在类 java.lang.String 中找不到 main 方法, 请将 main 方法定义为:
   public static void main(String[] args)
否则 JavaFX 应用程序类必须扩展javafx.application.Application
```

**分析:**首先由于全限定类名java.lang.String等于jdk中的String类，根据上边类加载源码可知，当AppClassLoader加载该String时，判断java.lang.String已经加载，便不会再次加载。所以执行的依旧是jdk中的String，但是系统的java.lang.String中没有main()方法，所以会报错。这是一种安全机制。

然后`验证下默认的类加载器能否加载自定义的java.lang.String`。==，默认的AppClassLoader能加载Everything？

```java
public class LoadStringDemo {

    public static void main(String[] args) {
        URLClassLoader systemClassLoader = (URLClassLoader)ClassLoader.getSystemClassLoader();
        URL[] urLs = systemClassLoader.getURLs();
        for (URL url: urLs) {
            System.out.println(url);
        }
    }
}
```
输出日志如下

```
...
file:/Users/cuishiying/work/demo-java/target/classes/
...
```

日志太多，但是绝对没有其他的包路径(当前包下的java.lang.String默认只能时jdk中的)


# 自定义类加载器

**为什么会存在自定义类加载器呢**

自定义类加载器的核心在于对字节码文件的获取，如果是加密的字节码则需要在该类中对文件进行解密。

因为实际项目中，会有多种加载.class文件的方式，

- 从本地系统中直接加载
- 通过网络下载.class文件
- 从zip，jar等归档文件中加载.class文件
- 从专有数据库中提取.class文件
- 将Java源文件动态编译为.class文件

**如何自定义类加载器**

```java
package com.example.demojava.loadclass;

import com.demo.ClassLoaderDemo;

import java.io.*;
import java.lang.reflect.Method;


public class MyClassLoader extends ClassLoader {

    private String root;


    /**
     * @param name 全限定类名
     * @return
     * @throws ClassNotFoundException
     */

    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {
        byte[] classData = loadClassData(name);

        if (classData == null) {
            throw new ClassNotFoundException();
        } else {
            return defineClass(name, classData, 0, classData.length);
        }
    }


    private byte[] loadClassData(String className) {
        String fileName = root + File.separatorChar +
                className.replace('.', File.separatorChar) + ".class";

        try {
            InputStream ins = new FileInputStream(fileName);

            ByteArrayOutputStream baos = new ByteArrayOutputStream();

            int bufferSize = 1024;

            byte[] buffer = new byte[bufferSize];

            int length = 0;

            while ((length = ins.read(buffer)) != -1) {
                baos.write(buffer, 0, length);
            }

            return baos.toByteArray();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
    }

    public String getRoot() {
        return root;
    }

    public void setRoot(String root) {
        this.root = root;
    }

    public static void main(String[] args) throws Exception {

        MyClassLoader classLoader = new MyClassLoader();
        classLoader.setRoot("/Users/cuishiying/Desktop/demo");

        Class<?> clz = Class.forName("LoadDemo", true, classLoader);
        Object  instance = clz.newInstance();
        Method test = clz.getDeclaredMethod("test");
        test.setAccessible(true);
        test.invoke(instance); 

        System.out.println(instance.getClass().getClassLoader());

    }
}
```

结果输出

```
test
com.example.demojava.loadclass.MyClassLoader@75bd9247
```

由此可知，自定义类加载器已可以正常工作。这里我们不能把LoadDemo放在类路径下，由于双亲委托机制的存在，会直接导致该类由 AppClassLoader加载，而不会通过我们自定义类加载器来加载。



**自定义类加载器加载手写java.lang.String**

改写自定义类加载器的main()方法
```java
    public static void main(String[] args) throws Exception {

        MyClassLoader classLoader = new MyClassLoader();
        classLoader.setRoot("/Users/cuishiying/Desktop/demo");

        Class<?> clz = classLoader.findClass("java.lang.String");
        Object  instance = clz.newInstance();

        System.out.println(instance.getClass().getClassLoader());
    }
```

JVM由于安全机制抛出了SecurityException
```
/Users/cuishiying/Desktop/demo/java/lang/String.class
Exception in thread "main" java.lang.SecurityException: Prohibited package name: java.lang
    at java.lang.ClassLoader.preDefineClass(ClassLoader.java:662)
    at java.lang.ClassLoader.defineClass(ClassLoader.java:761)
    at java.lang.ClassLoader.defineClass(ClassLoader.java:642)
    at com.example.demojava.loadclass.MyClassLoader.findClass(MyClassLoader.java:25)
    at com.example.demojava.loadclass.MyClassLoader.main(MyClassLoader.java:71)
```
