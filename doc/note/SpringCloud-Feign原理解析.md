# SpringCloud-Feign原理解析



![feign是如何设计的](../assets/feign是如何设计的.png)

- 首先通过@EnableFeignCleints注解开启FeignCleint
- 根据Feign的规则实现接口，并加@FeignCleint注解
- 程序启动后，会进行包扫描，扫描所有的@ FeignCleint的注解的类，并将这些信息注入到ioc容器中。
- 当接口的方法被调用，通过jdk的代理，来生成具体的RequesTemplate
- RequesTemplate在生成Request
- Request交给Client去处理，其中Client可以是HttpUrlConnection、HttpClient也可以是Okhttp
- 最后Client被封装到LoadBalanceClient类，这个类结合类Ribbon做到了负载均衡。



## 参考

- https://xli1224.github.io/2017/09/14/feign-anaylsis/