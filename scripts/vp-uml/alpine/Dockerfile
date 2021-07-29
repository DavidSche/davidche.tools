FROM alpine:3.14

#RUN apk add --no-cache tar fontconfig freetype-dev libjpeg-turbo-dev libpng-dev
#
MAINTAINER David.che <davidche@outlook.com>

USER root
ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre

RUN apk add --no-cache openjdk11-jre; \
    rm -rf /tmp/* /var/cache/apk/*

RUN apk add --no-cache  fontconfig && apk add --update ttf-dejavu && fc-cache --force

#COPY ./VP_Server_16_1_20200231_Linux64.tar.gz /opt/

COPY ./VPServer/webserver/  /opt/VPServer/webserver/
COPY ./VPServer/scripts/  /opt/VPServer/scripts/

WORKDIR /opt/VPServer

#RUN tar -xvzf /opt/VP_Server_16_1_20200231_Linux64.tar.gz -C /opt
#RUN rm /opt/VP_Server_16_1_20200231_Linux64.tar.gz -f
#RUN rm /opt/VPServer/jre -rf

RUN ln -s /usr/lib/jvm/default-jvm/jre /opt/VPServer/jre

EXPOSE 1999

#ENV CATALINA_HOME=/opt/VPServer/webserver
#ENV JRE_HOME=/opt/VPServer/jre
#ENV JAVA_HOME=/opt/VPServer/jre
#ENV PATH="/opt/VPServer/jre/bin:${PATH}"
#ENV PATH="/opt/VPServer/webserver/bin:${PATH}"

ENV CATALINA_HOME /opt/VPServer/webserver

ENV PATH $PATH:/opt/VPServer/jre/bin:/opt/VPServer/webserver/bin
#ENV PATH $PATH:/opt/VPServer/webserver/bin

#RUN echo $JAVA_HOME && \
#    echo $PATH

#RUN which java
#RUN java -version

CMD ["/opt/VPServer/scripts/startup.sh"]

