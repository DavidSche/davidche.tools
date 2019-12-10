# 服用基础镜像

构建镜像

```

FROM maven:3.6.0-alpine as build

COPY src src
COPY pom.xml .

RUN mvn package

FROM alpine:3.8

COPY --from=build target/composition-example-1.0-SNAPSHOT.jar .

ENTRYPOINT ["sh", "-c", "/usr/bin/java -jar composition-example-1.0-SNAPSHOT.jar"]

```

构建镜像

``` bash


$ docker build -t compose-this .

$ docker run compose-this

-jar: line 1: java: not found


```


构建基础 Docker 配置

``` Dockerfile
FROM openjdk:8-jre-alpine

VOLUME /usr/bin
VOLUME /usr/lib
```

运行基础镜像实例

```
$ docker build -t myjava:8 .

$ docker run --name java myjava:8

```

运行应用

```
docker run -it --volumes-from java compose-this
```

参考

https://blog.frankel.ch/composition-over-inheritance-applied-docker/


