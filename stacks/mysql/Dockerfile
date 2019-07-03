# FROM bitnami/minideb
FROM bitnami/mysql:5.7

LABEL maintainer "Davidche <davidche@outlook.com>"

ENV BITNAMI_PKG_CHMOD="-R g+rwX" \
    HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-9" \
    OS_NAME="linux" \
    TIMEZONE="Asia/Hongkong"


# User root is required for installing packages
USER root
#RUN install_packages vim

RUN echo $TIMEZONE > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

COPY ./my_custom.cnf /opt/bitnami/mysql/conf/my_custom.cnf

# RUN echo "Asia/Hongkong" > /etc/timezone && \
#     dpkg-reconfigure -f noninteractive tzdata

# RUN date
# apt-get update && apt-get install -y iputils-ping

RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

# Install required system packages
RUN install_packages ntpdate &&  ntpdate cn.pool.ntp.org
#RUN install_packages curl

# Return to previous non-root user
USER 1001


# Copy application files
#COPY /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 

# Install required system packages

# EXPOSE 80
# CMD ["npm", "start", "--prefix", "app"]