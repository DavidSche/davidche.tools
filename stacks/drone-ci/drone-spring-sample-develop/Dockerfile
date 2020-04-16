FROM adoptopenjdk/maven-openjdk11

ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.17
ENV TOMCAT_SHA512 f3427b7c5065a4f52af7bc00224afaae73226bf5def84b45aa305e18200a28e19463dd85a13f4ab1eb739366249cf1e99461014248f1f00b0c97f2afcef896a0

RUN mkdir -p /opt
RUN curl -jksSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
RUN tar -C /opt -xvzf /tmp/apache-tomcat.tar.gz
RUN ln -s /opt/apache-tomcat-${TOMCAT_VERSION} ${TOMCAT_HOME}
RUN rm -rf ${TOMCAT_HOME}/webapps/*

# RUN find / boot-sample-0.0.1-SNAPSHOT.war

ADD /boot-sample-0.0.1-SNAPSHOT.war ${TOMCAT_HOME}/webapps/

EXPOSE 8080

ENTRYPOINT [ "/opt/tomcat/bin/catalina.sh", "run" ]