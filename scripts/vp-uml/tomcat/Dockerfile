FROM tomcat:10
USER root
#
MAINTAINER David.che <davidche@outlook.com>

# Install Packages
#RUN yum update -y; \
RUN apt-get install -y wget unzip curl fontconfig libfreetype6 ;

#RUN apt-get clean all

COPY ./ROOT /usr/local/tomcat/webapps/ROOT
COPY ./diagrams.war /usr/local/tomcat/webapps/
COPY ./forms.war /usr/local/tomcat/webapps/
COPY ./tabular.war /usr/local/tomcat/webapps/

WORKDIR usr/local/tomcat/bin

RUN tar -xvf /opt/VP_Server_16_1_20200231_Linux64.tar.gz
RUN rm /opt/VP_Server_16_1_20200231_Linux64.tar.gz -f

EXPOSE 8080

CMD ["catalina.sh", "run"]


