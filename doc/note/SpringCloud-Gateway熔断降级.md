# SpringCloud-Gateway熔断降级



## 超时降级

pom文件引入依赖

```xml
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-hystrix</artifactId>
        </dependency>
```



在application.yml配置文件中加入超时降级配置

```yaml
server:
  port: 8100
spring:
  application:
    name: idc-cloud-gateway
  cloud:
    consul:
      host: localhost
      port: 8500
    gateway:
      discovery:
        locator:
          enabled: true # gateway可以通过开启以下配置来打开根据服务的serviceId来匹配路由,默认是大写
      routes:
        - id: provider  # 路由 ID，保持唯一
          uri: lb://idc-cloud-provider # uri指目标服务地址，lb代表从注册中心获取服务
          predicates: # 路由条件。Predicate 接受一个输入参数，返回一个布尔值结果。该接口包含多种默认方法来将 Predicate 组合成其他复杂的逻辑（比如：与，或，非）
            - Path=/p/**
          filters:
            - StripPrefix=1 # 过滤器StripPrefix，作用是去掉请求路径的最前面n个部分截取掉。StripPrefix=1就代表截取路径的个数为1，比如前端过来请求/test/good/1/view，匹配成功后，路由到后端的请求路径就会变成http://localhost:8888/good/1/view
        - id: consumer
          uri: lb://idc-cloud-consumer
          predicates:
            - Path=/c/**
          filters:
            - StripPrefix=1
            - name: Hystrix
              args:
                name: default
                fallbackUri: forward:/defaultfallback # 只有该id下的服务会降级
# hystrix 信号量隔离，1.5秒后自动超时
hystrix:command.fallbackCmdA.execution.isolation.thread.timeoutInMilliseconds: 1500

```

新建降级处理类FallbackController

```java
@RestController
public class FallbackController {

    @RequestMapping("/defaultfallback")
    public Map<String,String> defaultfallback(){
        System.out.println("降级操作...");
        Map<String,String> map = new HashMap<>();
        map.put("resultCode","fail");
        map.put("resultMessage","服务异常");
        map.put("resultObj","null");
        return map;
    }
}
```



同时修改provider模块，让接口休眠2s，大于网关中设置超时的1.5秒，因此会触发熔断降级。

测试结果如下

```shell
➜  GitNote git:(master) curl http://localhost:8100/c/consumer
{"resultObj":"null","resultCode":"fail","resultMessage":"服务异常"}
```

可见超时降级配置生效。

