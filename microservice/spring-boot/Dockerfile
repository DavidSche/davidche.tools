#FROM openjdk:11-jre-slim as builder
#build #1
#FROM adoptopenjdk/openjdk11:alpine-slim as builder
FROM 192.168.9.10:5000/openjdk11:alpine-slim as builder
LABEL maintainer ="Davidche <davidche@outlook.com>"

WORKDIR application
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} application.jar
RUN java -Djarmode=layertools -jar application.jar extract

#build #2
FROM 192.168.9.10:5000/openjdk11:alpine-slim
LABEL maintainer ="Davidche <davidche@outlook.com>"

#ENV TZ=Asia/Shanghai LC_ALL='zh_CN.UTF-8'
#
#RUN apk add --no-cache curl jq tzdata && \
#    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone && \
#    apk del tzdata
#
#EXPOSE ${PORT:-8080}
#HEALTHCHECK --start-period=15s --interval=1m --timeout=10s --retries=5 \
#            CMD curl --silent --fail --request GET http://localhost:${PORT:-8080}/app/actuator/health \
#                | jq --exit-status '.status == "UP"' || exit 1

WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]