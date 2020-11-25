## 静态代理

```java
/**
* 接口
*/
public interface IUserDao {
   void save();
}

/**
* 接口实现
* 目标对象
*/
public class UserDao implements IUserDao {
   public void save() {
       System.out.println("----已经保存数据!----");
   }
}


/**
* 代理对象,静态代理
*/
public class UserDaoProxy implements IUserDao{
   //接收保存目标对象
   private IUserDao target;
   public UserDaoProxy(IUserDao target){
       this.target=target;
   }

   public void save() {
       System.out.println("开始事务...");
       target.save();//执行目标对象的方法
       System.out.println("提交事务...");
   }
}

/**
* 测试类
*/
public class App {
   public static void main(String[] args) {
       //目标对象
       UserDao target = new UserDao();

       //代理对象,把目标对象传给代理对象,建立代理关系
       UserDaoProxy proxy = new UserDaoProxy(target);

       proxy.save();//执行的是代理的方法
   }
}
```

## jdk动态代理

```java
/**
* 创建动态代理对象
* 动态代理不需要实现接口,但是需要指定接口类型
*/
public class ProxyFactory{

   //维护一个目标对象
   private Object target;
   public ProxyFactory(Object target){
       this.target=target;
   }

  //给目标对象生成代理对象
   public Object getProxyInstance(){
       return Proxy.newProxyInstance(
               target.getClass().getClassLoader(),
               target.getClass().getInterfaces(),
               new InvocationHandler() {
                   @Override
                   public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                       System.out.println("开始事务2");
                       //执行目标对象方法
                       Object returnValue = method.invoke(target, args);
                       System.out.println("提交事务2");
                       return returnValue;
                   }
               }
       );
   }

}

/**
* 测试类
*/
public class App {
   public static void main(String[] args) {
       // 目标对象
       IUserDao target = new UserDao();
       // 【原始的类型 class cn.itcast.b_dynamic.UserDao】
       System.out.println(target.getClass());

       // 给目标对象，创建代理对象
       IUserDao proxy = (IUserDao) new ProxyFactory(target).getProxyInstance();
       // class $Proxy0   内存中动态生成的代理对象
       System.out.println(proxy.getClass());

       // 执行方法   【代理对象】
       proxy.save();
   }
}
```

## cglib动态代理

```java
/**
* 目标对象,没有实现任何接口
*/
public class UserDao {

   public void save() {
       System.out.println("----已经保存数据!----");
   }
}

/**
* Cglib子类代理工厂
* 对UserDao在内存中动态构建一个子类对象
*/
public class ProxyFactory implements MethodInterceptor{
   //维护目标对象
   private Object target;

   public ProxyFactory(Object target) {
       this.target = target;
   }

   //给目标对象创建一个代理对象
   public Object getProxyInstance(){
       //1.工具类
       Enhancer en = new Enhancer();
       //2.设置父类
       en.setSuperclass(target.getClass());
       //3.设置回调函数
       en.setCallback(this);
       //4.创建子类(代理对象)
       return en.create();

   }

   @Override
   public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy) throws Throwable {
       System.out.println("开始事务...");

       //执行目标对象的方法
       Object returnValue = method.invoke(target, args);

       System.out.println("提交事务...");

       return returnValue;
   }
}

/**
* 测试类
*/
public class App {

   @Test
   public void test(){
       //目标对象
       UserDao target = new UserDao();

       //代理对象
       UserDao proxy = (UserDao)new ProxyFactory(target).getProxyInstance();

       //执行代理对象的方法
       proxy.save();
   }
}
```