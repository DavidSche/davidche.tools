FROM adoptopenjdk/openjdk11:alpine-slim as backend

WORKDIR /opt/app

# Tomcat default port
#              "-Dspring.profiles.active=local", \
EXPOSE 8080

ENV TZ=Asia/Shanghai LC_ALL='zh_CN.UTF-8'

RUN apk add --no-cache curl jq tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone && \
    apk del tzdata

COPY ./target/myservice-0.0.7-SNAPSHOT.jar /opt/app/app.jar

#    -  -Djava.security.egd  Tomcat
#      (https://wiki.apache.org/tomcat/HowTo/FasterStartUp#Entropy_Source)

ENTRYPOINT ["java", \
            "-Djava.security.egd=file:/dev/./urandom", \
            "-jar", "/opt/app/app.jar" \
]

HEALTHCHECK --start-period=15s --interval=1m --timeout=10s --retries=5 \
            CMD curl --silent --fail --request GET http://localhost:8080/app/actuator/health \
                | jq --exit-status '.status == "UP"' || exit 1
