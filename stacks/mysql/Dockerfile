# FROM bitnami/minideb
FROM bitnami/mysql:5.7

LABEL maintainer "Davidche <davidche@outlook.com>"

ENV BITNAMI_PKG_CHMOD="-R g+rwX" \
    HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-9" \
    OS_NAME="linux" \
    TIMEZONE="Asia/Shanghai"
# RUN rm -f /etc/localtime && 
RUN ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime
# RUN date
# apt-get update && apt-get install -y iputils-ping

# Install required system packages
#RUN install_packages tzdata ntpdate;ntpdate cn.pool.ntp.org curl

# Copy application files
#COPY /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 

# Install required system packages

# EXPOSE 80
# CMD ["npm", "start", "--prefix", "app"]