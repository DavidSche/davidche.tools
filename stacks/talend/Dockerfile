FROM ubuntu:16.04
# 
USER root

RUN apt-get -y update && \
	apt-get -y upgrade && \
	apt-get install -y \
		software-properties-common unzip \
                ca-certificates \
                openssh-client \
                curl \
		nano
				
# Java installation
RUN apt-add-repository -y ppa:openjdk-r/ppa && \
	apt-get -y update && \
	yes | apt-get install -y --force-yes openjdk-8-jdk
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
# Download Talend Open Studio for ESB

RUN curl -sSo /opt/TOS_ESB-20181026_1147-V7.1.1.zip https://download-mirror2.talend.com/esb/release/V7.1.1/TOS_ESB-20181026_1147-V7.1.1.zip> /dev/null

# Install Talend Open Studio for ESB


RUN unzip /opt/TOS_ESB-20181026_1147-V7.1.1.zip -d /opt/TOS_ESB && \
	rm /opt/TOS_ESB-20181026_1147-V7.1.1.zip && \
	rm -rf /opt/TOS_ESB/Studio && \	
	chmod 777 /opt/TOS_ESB/Runtime_ESBSE/container/bin/trun && \
 	chmod 777 /opt/TOS_ESB/Runtime_ESBSE/container/bin/start
	
VOLUME ["/opt/TOS_ESB/Runtime_ESBSE/container/deploy"]
VOLUME ["/opt/TOS_ESB/Runtime_ESBSE/container/etc"]

EXPOSE 8040 9001 1099 44444 8101 8000 8001 8888 61616 2181 1527 8082 8088 8090

CMD ["/opt/TOS_ESB/Runtime_ESBSE/container/bin/trun"]
