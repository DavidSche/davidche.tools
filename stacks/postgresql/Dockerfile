FROM bitnami/postgresql:10.7.0
LABEL maintainer "David <davidche@outlook.com>"
ENV BITNAMI_PKG_CHMOD="-R g+rwX" \
    HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-9" \
    OS_NAME="linux" \
    TIMEZONE="Asia/Hongkong" \
    DEBIAN_FRONTEND="noninteractive" \
    DOWNLOAD_URL="https://www.zombodb.com/releases/v10-1.0.3/zombodb_jessie_pg10-10-1.0.3_amd64.deb"

# User root is required for installing packages
USER root
#echo $TIMEZONE > /etc/timezone
#RUN echo Asia/Hongkong > /etc/timezone && \
#    dpkg-reconfigure -f noninteractive tzdata

RUN  cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata	

RUN install_packages  wget curl -y
RUN wget $DOWNLOAD_URL
RUN dpkg -i zombodb_jessie_pg10-10-1.0.3_amd64.deb

#RUN cp -rf  /usr/pgsql-10/share/extension/* /opt/rh/rh-postgresql10/root/usr/share/pgsql/extension
#RUN cp /usr/pgsql-10/lib/zombodb.so  /opt/rh/rh-postgresql10/root/lib64/pgsql/
#RUN cp /usr/pgsql-10/lib/example.so  /opt/rh/rh-postgresql10/root/lib64/pgsql/

RUN cp -rf  /usr/share/postgresql/10/extension/* /opt/bitnami/postgresql/share/extension
RUN cp /usr/lib/postgresql/10/lib/zombodb.so  /opt/bitnami/postgresql/lib

# Return to previous non-root user
USER 1001