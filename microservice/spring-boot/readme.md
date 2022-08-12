# 使用说明


## 参考内容

https://github.com/chudichen/spring-cloud-gateway-authorize.git

## Spring config file

使用环境变量配置属性资源文件信息（需 Spring.boot 2.1.8版本以上）

与docker config 一起配合使用


```
SPRING_CONFIG_LOCATION=file:/var/xy/*/
SPRING_CONFIG_ADDITIONALLOCATION=file:/var/xy/*/


java -jar myproject.jar --spring.config.location=\
    optional:classpath:/default.properties,\
    optional:classpath:/override.properties
    
```
或者
```shell


SPRING_APPLICATION_JSON='{"my":{"name":"test"}}'

java -Dspring.application.json='{"my":{"name":"test"}}' -jar myapp.jar

$ java -jar myapp.jar --spring.application.json='{"my":{"name":"test"}}'


spring.config.additional-location 

-Dspring.config.additional-location=/path/to/additional-location-application.yml



```

 
>**注意**：如果配置了 SPRING_CONFIG_ALLOCATION=file:/var/xy/*/ 则classpath:/application.properties 失效，


## 在使用外部化配置文件时，执行顺序为：

spring.config.location > spring.profiles.active > spring.config.additional-location > 默认的 application.proerties。

其中通过 spring.profiles.active 和 spring.config.additional-location指定的配置文件会与 默认的application.proerties merge 作为最终的配置，spring.config.location 则不会。

## 同时指定两个配置

通过 java -jar -Dspring.profiles.active=dev -Dspring.config.additional-location=conf/application-addition.properties guides-properties/target/guides-properties-0.0.1-SNAPSHOT.jar 启动工程，输出如下：

为了排除与 -D 参数顺序有关，也使用如下方式再执行一次：java -jar -Dspring.config.additional-location=conf/application-addition.properties -Dspring.profiles.active=dev  guides-properties/target/guides-properties-0.0.1-SNAPSHOT.jar，输出结果与前面相同，所以可以得出，spring.profiles.active 的优先级比 spring.config.additional-location 要高。
   

