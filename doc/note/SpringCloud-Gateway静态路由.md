# SpringCloud-Gateway静态路由

## 1. 为什么引入API网关

使用 API 网关后的优点如下：

- 易于监控。可以在网关收集监控数据并将其推送到外部系统进行分析。
- 易于认证。可以在网关上进行认证，然后再将请求转发到后端的微服务，而无须在每个微服务中进行认证。
- 减少了客户端与各个微服务之间的交互次数。



## 2. 搭建环境

首先搭建一个微服务基本测试环境，服务发现组件选择consul。

### 2.1. 服务提供者

pom.xml

```xml
		<dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-consul-discovery</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>

		<dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>2.1.4.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Greenwich.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

pplication.yml

```yaml
spring:
  application:
    name: idc-cloud-provider
  cloud:
    consul:
      host: localhost
      port: 8500
server:
  port: 2001

```

ProviderApplication.java

```java
@EnableDiscoveryClient
@SpringBootApplication
public class ProviderApplication {

    public static void main(String[] args) {
        SpringApplication.run(ProviderApplication.class, args);
    }
}
```

ProviderController.java

```java
@RestController
public class ProviderController {

    @Autowired
    DiscoveryClient discoveryClient;

    @GetMapping("/provider")
    public String provider() {
        String services = "Services: " + discoveryClient.getServices();
        System.out.println(services);
        return services;
    }
}
```

访问: http://localhost:2001/provider 

结果如下:

```
Services: [consul, idc-cloud-consumer, idc-cloud-gateway, idc-cloud-provider]
```



### 2.2. 服务消费者

Pom.xml增加

```xml
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>
```

application.yml

```yaml
spring:
  application:
    name: idc-cloud-consumer
  cloud:
    consul:
      host: localhost
      port: 8500
server:
  port: 2101

```

ConsumerApplication.java

```java
@EnableFeignClients
@EnableDiscoveryClient
@SpringBootApplication
public class ConsumerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ConsumerApplication.class, args);
    }
}
```

RemoteService.java

```java
@FeignClient("idc-cloud-provider")
public interface RemoteService {

    /**
     * 方法名随意，url路径匹配即可
     * @return
     */
    @GetMapping("/provider")
    String test();
}
```

ConsumerController.java

```java
@RestController
public class ConsumerController {

    @Autowired
    RemoteService remoteService;

    @GetMapping("/consumer")
    public String consumer(@RequestParam(required = false) String name) {
        String result = remoteService.test();
        return result;
    }
}

```

访问: http://localhost:2101/consumer 

输出如下:

```
Services: [consul, idc-cloud-consumer, idc-cloud-gateway, idc-cloud-provider]
```



## 3. 静态路由

Pom.xml

```xml
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-webflux</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-consul-discovery</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
            <scope>compile</scope>
        </dependency>
    </dependencies>
```

Application.yml

```yaml
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
server:
  port: 8100
```

IdcGatewayApplication.java

```java
@SpringBootApplication
@EnableDiscoveryClient
public class IdcGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(IdcGatewayApplication.class, args);
    }
}
```

访问: http://localhost:8100/p/provider

输出结果

```
Services: [consul, idc-cloud-consumer, idc-cloud-gateway, idc-cloud-provider]
```

访问: http://localhost:8100/c/consumer

输出结果

```
Services: [consul, idc-cloud-consumer, idc-cloud-gateway, idc-cloud-provider]
```

可见静态路由配置已生效。



## 4. Predicate 断言条件介绍

### 4.1 通过请求参数匹配

Query Route Predicate 支持传入两个参数，一个是属性名一个为属性值，属性值可以是正则表达式。

```yaml
...
        - id: consumer
          uri: lb://idc-cloud-consumer
          predicates:
            - Path=/c/**
            - Query=name
          filters:
            - StripPrefix=1
```

这样配置，只要请求中包含 smile 属性的参数即可匹配路由。

Postman 测试

http://localhost:8100/c/consumer?name=1

经过测试发现只要请求汇总带有 name 参数即会匹配路由，不带 name 参数则不会匹配。

还可以将 Query 的值以键值对的方式进行配置，这样在请求过来时会对属性值和正则进行匹配，匹配上才会走路由。

```yaml
        - id: consumer
          uri: lb://idc-cloud-consumer
          predicates:
            - Path=/c/**
            - Query=name, ad.
          filters:
            - StripPrefix=1
```

这样只要当请求中包含 keep 属性并且参数值是以 pu 开头的长度为三位的字符串才会进行匹配和路由。

测试

http://localhost:8100/c/consumer?name=adm

测试可以返回页面代码，将 keep 的属性值改为 pubx 再次访问就会报 404,证明路由需要匹配正则表达式才会进行路由。



### 4.2 通过 Header 属性匹配

Header Route Predicate 和 Cookie Route Predicate 一样，也是接收 2 个参数，一个 header 中属性名称和一个正则表达式，这个属性值和正则表达式匹配则执行。

```yaml
        - id: consumer
          uri: lb://idc-cloud-consumer
          predicates:
            - Path=/c/**
            - Header=token, \d+
          filters:
            - StripPrefix=1
```

测试

curl http://localhost:8100/c/consumer -H "token:11"

则返回页面代码证明匹配成功。将参数-H "token:11"改为-H "token:spring"再次执行时返回404证明没有匹配。



### 4.3 通过 Cookie 匹配

Cookie Route Predicate 可以接收两个参数，一个是 Cookie name ,一个是正则表达式，路由规则会通过获取对应的 Cookie name 值和正则表达式去匹配，如果匹配上就会执行路由，如果没有匹配上则不执行。

```yaml
        - id: consumer
          uri: lb://idc-cloud-consumer
          predicates:
            - Path=/c/**
            - Cookie=sessionId, test
          filters:
            - StripPrefix=1
```

使用 curl 测试，命令行输入:

curl http://localhost:8100/c/consumer --cookie "sessionId=test"

则会返回页面代码，如果去掉--cookie "sessionId=test"，后台汇报 404 错误。



### 4.4 通过 Host 匹配

Host Route Predicate 接收一组参数，一组匹配的域名列表，这个模板是一个 ant 分隔的模板，用.号作为分隔符。它通过参数中的主机地址作为匹配规则。

```yaml
        - id: consumer
          uri: lb://idc-cloud-consumer
          predicates:
            - Path=/c/**
            - Host=**.baidu.com
          filters:
            - StripPrefix=1
```

使用 curl 测试，命令行输入:

curl http://localhost:8100/c/consumer -H "Host: www.baidu.com"

curl http://localhost:8100/c/consumer -H "Host: md.baidu.com"

经测试以上两种 host 均可匹配到 host_route 路由，去掉 host 参数则会报 404 错误。



### 4.5 通过请求方式匹配

可以通过是 POST、GET、PUT、DELETE 等不同的请求方式来进行路由。

```yaml
        - id: consumer
          uri: lb://idc-cloud-consumer
          predicates:
            - Path=/c/**
            - Method=GET
          filters:
            - StripPrefix=1
```

使用 curl 测试，命令行输入:

\# curl 默认是以 GET 的方式去请求

curl http://localhost:8100/c/consumer

测试返回页面代码，证明匹配到路由，我们再以 POST 的方式请求测试。

\# curl 默认是以 GET 的方式去请求

curl -X POST http://localhost:8100/c/consumer

返回 404 没有找到，证明没有匹配上路由



### 4.6 通过请求路径匹配

Path Route Predicate 接收一个匹配路径的参数来判断是否走路由。

```yaml
        - id: consumer
          uri: lb://idc-cloud-consumer
          predicates:
            - Path=/c/{segment}
          filters:
            - StripPrefix=1
```

如果请求路径符合要求，则此路由将匹配，例如：/foo/1 或者 /foo/bar。

使用 curl 测试，命令行输入:

curl http://localhost:8100/c/consumer

curl http://localhost:8100/a/consumer

经过测试第一可以正常获取到页面返回值，最后一个命令报404，证明路由是通过指定路由来匹配。



### 4.7 通过请求 ip 地址进行匹配

Predicate 也支持通过设置某个 ip 区间号段的请求才会路由，RemoteAddr Route Predicate 接受 cidr 符号(IPv4 或 IPv6 )字符串的列表(最小大小为1)，例如 192.168.124.5/16 (其中 192.168.124.5 是 IP 地址，16 是子网掩码)。

```yaml
        - id: consumer
          uri: lb://idc-cloud-consumer
          predicates:
            - Path=/c/**
            - RemoteAddr=192.168.124.5/16
          filters:
            - StripPrefix=1
```

可以将此地址设置为本机的 ip 地址进行测试。

curl http://192.168.124.5:8100/c/consumer

如果请求的远程地址是 192.168.124.5，则此路由将匹配。



### 4.8 组合使用

各种 Predicates 同时存在于同一个路由时，请求必须同时满足所有的条件才被这个路由匹配。

一个请求满足多个路由的断言条件时，请求只会被首个成功匹配的路由转发



