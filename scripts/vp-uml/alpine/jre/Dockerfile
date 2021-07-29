FROM alpine:3.14

MAINTAINER David.che <davidche@outlook.com>

ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre

RUN apk add --no-cache openjdk11-jre; \
    rm -rf /tmp/* /var/cache/apk/*

RUN echo $JAVA_HOME && \
    echo $PATH

#RUN which java

RUN java -version

CMD ["java", "-version"]
