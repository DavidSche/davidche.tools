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


