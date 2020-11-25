# Spring之AOP简单用法.md



## 1. aop的定义

来自百度的解释:

> 在软件业，AOP为Aspect Oriented Programming的缩写，意为：面向切面编程，通过预编译方
> 式和运行期动态代理实现程序功能的统一维护的一种技术。AOP是OOP的延续，是软件开发中的一个
> 热点，也是Spring框架中的一个重要内容，是函数式编程的一种衍生范型。利用AOP可以对业务逻辑
> 的各个部分进行隔离，从而使得业务逻辑各部分之间的耦合度降低，提高程序的可重用性，同时提高
> 了开发的效率。



## 2. aop的原理

1. 初始化AOP容器
2. 读取配置文件或注解
3. 解析配置文件，将配置文件转换成为AOP容器能够识别的数据结构Advisor，Advisor中包含了两个重要的数据结构。Advice：描述一个切面行为，即干什么；Pointcut：描述切面的位置，即在哪里
4. Spring将这个Advisor转换成自己能够识别的数据结构-AdvisorSupport，Spring动态的将这些方法植入到对应的方法中
5. 生成动态代理类，使用jdk动态代理和cglib动态代理
6. 提供调用，在使用的时候调用方调用的就是代理方法，也就是已经植入了增强方法的方法。



## 3. aop的使用

创建注解

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Log {

    String value() default "";
}
```

aop切面处理

```java
/**
 * 1. 执行顺序:
 *
 * Around Before
 * Before
 * aop目标方法体
 * Around After
 * After
 * AfterReturning
 *
 *
 * 2. 异常顺序：
 *
 * Around Before
 * Before
 * aop目标方法体
 * After
 * AfterThrowing
 *
 * 3. @within @target
 */
@Aspect
@Component
public class LogAspect {

    @Pointcut("@annotation(com.example.demojava.aop.Log)")
    public void logPointCut() {

    }

    /**
     * 前置方法: 目标方法运行之前运行
     */
    @Before(value = "logPointCut()")
    public void logBefore(JoinPoint point) {
        System.out.println("Before");
    }

    /**
     * 后置通知: 目标方法结束之后
     */
    @AfterReturning(value = "logPointCut()")
    public void afterReturning(JoinPoint point) {
        System.out.println("AfterReturning");
    }

    /**
     * 返回通知: 方法正常执行并返回
     */
    @AfterThrowing(value = "logPointCut()")
    public void afterThrowing(JoinPoint point) {
        System.out.println("AfterThrowing");
    }

    /**
     * 异常通知: 方法出现异常以后调用
     */
    @After(value = "logPointCut()")
    public void after(JoinPoint point) {
        System.out.println("After");
    }

    /**
     * 环绕通知: 最强大的通知（这就是动态代理）
     */
    @Around(value = "logPointCut()")
    public void around(ProceedingJoinPoint point) throws Throwable {
        System.out.println("Around Before");
        Object result = point.proceed();
        System.out.println("Around After");
    }
}
```

测试

```java
@RestController
public class LogController {


    @Log(value = "测试aop")
    @GetMapping("/log")
    public void log() {
//        System.out.println("aop目标方法体");
        throw new RuntimeException("");
    }
}
```

