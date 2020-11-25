# Java8新特性

## Lambda表达式

## 函数式接口

## 接口的默认方法和静态方法

**默认方法**使得开发者可以在 不破坏二进制兼容性的前提下，往现存接口中添加新的方法，即不强制那些实现了该接口的类也同时实现这个新加的方法。

默认方法和抽象方法之间的区别在于抽象方法需要实现，而默认方法不需要。接口提供的默认方法会被接口的实现类继承或者覆写，例子代码如下：

```java
public interface Interface8 {

    default String defaultInterf() {
        return "default";
    }
}
```

```java
public class Java8Demo implements Interface8 {

    /**
     * 该方法非必须实现，不实现走父类默认方法，覆盖则走子类实现。
     * @return
     */
    @Override
    public String defaultInterf() {
        return "child";
    }

    public static void main(String[] args) {
        Java8Demo demo = new Java8Demo();
        String tes = demo.defaultInterf();
        System.out.println(tes);
    }
}
```



## 方法和构造函数引用

## Streams(流)

首先创建一个集合用于测试

```java
List<String> stringCollection = new ArrayList<>();
        stringCollection.add("ddd2");
        stringCollection.add("aaa2");
        stringCollection.add("bbb1");
        stringCollection.add("aaa1");
        stringCollection.add("bbb3");
        stringCollection.add("ccc");
        stringCollection.add("bbb2");
        stringCollection.add("ddd1");
```



**Filter(过滤)**

过滤通过一个predicate接口来过滤并只保留符合条件的元素，该操作属于**中间操作**，所以我们可以在过滤后的结果来应用其他Stream操作（比如forEach）。forEach需要一个函数来对过滤后的元素依次执行。forEach是一个最终操作，所以我们不能在forEach之后来执行其他Stream操作。

```java
        stringCollection
                .stream()
                .filter(p -> p.startsWith("a"))
                .forEach(System.out::println);
```

输出结果

```
aaa2
aaa1
```



**Sorted(排序)**

排序只创建了一个排列好后的Stream，而不会影响原有的数据源，排序之后原数据stringCollection是不会被修改的

```java
        stringCollection
                .stream()
                .sorted((a, b) -> a.compareTo(b))
                .filter(p -> p.startsWith("a"))
                .forEach(System.out::println);
```

输出

```
aaa1
aaa2
```



**Map(映射)**

中间操作 map 会将元素根据指定的 Function 接口来依次将元素转成另外的对象。

```java
        stringCollection
                .stream()
                .map(String::toUpperCase)
                .sorted((a, b) -> a.compareTo(b))
                .filter(p -> p.startsWith("A"))
                .forEach(System.out::println);
```

输出

```
AAA1
AAA2
```



**Match(匹配)**

Stream提供了多种匹配操作，允许检测指定的Predicate是否匹配整个Stream。所有的匹配操作都是 **最终操作** ，并返回一个 boolean 类型的值。

```java
        // 测试 Match (匹配)操作
        boolean anyStartsWithA = stringCollection                        
                        .stream()
                        .anyMatch((s) -> s.startsWith("a"));
        System.out.println(anyStartsWithA); // true

        boolean allStartsWithA = stringCollection
                        .stream()
                        .allMatch((s) -> s.startsWith("a"));

        System.out.println(allStartsWithA); // false

        boolean noneStartsWithZ = stringCollection                        
                        .stream()
                        .noneMatch((s) -> s.startsWith("z"));

        System.out.println(noneStartsWithZ); // true
```



**Count(计数)**

计数是一个 **最终操作**，返回Stream中元素的个数，**返回值类型是 long**。

```java
        //测试 Count (计数)操作
        long startsWithB = stringCollection
                        .stream()
                        .filter((s) -> s.startsWith("b"))
                        .count();
        System.out.println(startsWithB); // 3
```



**Reduce(规约)**

这是一个 **最终操作** ，允许通过指定的函数来讲stream中的多个元素规约为一个元素，规约后的结果是通过Optional 接口表示的：

```java
//测试 Reduce (规约)操作
        Optional<String> reduced =
                stringCollection
                        .stream()
                        .sorted()
                        .reduce((s1, s2) -> s1 + "#" + s2);

        reduced.ifPresent(System.out::println);//aaa1#aaa2#bbb1#bbb2#bbb3#ccc#ddd1#ddd2
```



## Data API(日期相关API)

- Clock
- Timezones(时区)
- LocalTime(本地时间)
- LocalDate(本地日期)
- LocalDateTime(本地日期时间)