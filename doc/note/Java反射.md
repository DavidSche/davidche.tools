# 反射基础

* [基本介绍](#基本介绍)
* [实例操作](#实例操作)

## 基本介绍

基本过程: 

1、编译Java文件，生成`.class`文件

2、使用Java虚拟机（JVM）将字节码文件（字节码文件在内存中使用Class类表示）加载到内存

4、使用反射的时候，首先获取到Class类，就可以得到class文件里的所有内容，包含属性、构造方法、普通方法

5、属性通过Filed类表示、构造方法通过Constructor表示、普通方法通过Method表示


## 实例操作

```java
public interface Pc {
    void run();
}
```

```java
public class Dell implements Pc {

    // 私有变量
    private String cpu;

    public int price;

    // 无参构造方法
    public Dell() {
    }

    // 有构造方法
    public Dell(String cpu) {
        this.cpu = cpu;
    }

    @Override
    public void run() {
        System.out.println("Dell PC");
    }

    public String getCpu() {
        return cpu;
    }

    public void setCpu(String cpu) {
        this.cpu = cpu;
    }

    public int getPrice() {
        return price;
    }

    public void setPrice(int price) {
        this.price = price;
    }

    // 私有方法
    private void desc() {
        System.out.println("私有方法: 散热不好");
    }
}
```

```java
public class ReflectEntrance {
    public static void main(String[] args) throws Exception{

        // 1. Class.forName()
        Class<?> dClazz = Class.forName("com.idcmind.demo1.Dell");
        System.out.println(dClazz);

        // 2. 类名.class
        Class<Dell> dClazz2 = Dell.class;
        System.out.println(dClazz2);

        // 3. 对象.getClass()
        Dell dell = new Dell();
        Class<?> dClazz3 = dell.getClass();
        System.out.println(dClazz3);

        System.out.println("---------------------");

        // 获取所有的公共方法(没有private),但是有它所有有关联的类的方法，包括接口，它的父类Object
        Method[] methods = dClazz.getMethods();
        for (Method method: methods) {
            System.out.println(method.getName());
        }

        System.out.println("---------------------");

        // 可以得到当前类的所有的方法: 包括私有的方法
        Method[] declaredMethods = dClazz.getDeclaredMethods();
        for(Method method : declaredMethods)
            System.out.println(method.getName());

        System.out.println("---------------------");

        // 获取Dell实现的所有的接口
        Class<?>[] interfaces = dClazz.getInterfaces();
        for(Class<?>inter : interfaces)
            System.out.println(inter);

        System.out.println("---------------------");

        // 获取公共变量
        Field[] fields = dClazz.getFields();
        for(Field field : fields)
            System.out.println(field);

        System.out.println("---------------------");

        // 获取私有变量
        Field[] declaredFields = dClazz.getDeclaredFields();
        for(Field field : declaredFields)
            System.out.println(field);

        System.out.println("---------------------");

        // 获取构造器
        Constructor<?>[] constructors = dClazz.getConstructors();
        for (Constructor<?> c : constructors)
            System.out.println(c);

        System.out.println("---------------------");

        // 获取父类
        Class<?> superclass = dClazz.getSuperclass();
        System.out.println(superclass); // 默认就是Object

        System.out.println("---------------------");

        // 用反射创建实例
        Dell dell1 = (Dell)dClazz.newInstance();
        System.out.println(dell1);
        dell1.run();

        System.out.println("---------------------");

        // 设置变量
        Field cpu = dClazz.getDeclaredField("cpu");
        cpu.setAccessible(true);
        cpu.set(dell1, "intel");
        System.out.println(dell1.getCpu());

        System.out.println("---------------------");

        // 调用方法
        Method setCpu = dClazz.getDeclaredMethod("setCpu", String.class);
        setCpu.setAccessible(true);
        setCpu.invoke(dell1, "AMD");
        System.out.println(dell1.getCpu());

        System.out.println("---------------------");

        // 操作构造方法
        Constructor<?> declaredConstructor = dClazz.getDeclaredConstructor(String.class);
        Dell hw = (Dell)declaredConstructor.newInstance("华为");
        System.out.println(hw.getCpu());

    }
}
```