# FROM bitnami/minideb
FROM bitnami/redis:5.0.4

LABEL maintainer "Davidche <davidche@outlook.com>"

# ENV BITNAMI_PKG_CHMOD="-R g+rwX" \
#     HOME="/" \
#     OS_ARCH="amd64" \
#     OS_FLAVOUR="debian-9" \
#     OS_NAME="linux" \
#     TIMEZONE="Asia/Shanghai"
# RUN rm -f /etc/localtime && 
#RUN ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime

# User root is required for installing packages
USER root

RUN  cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata	

# Return to previous non-root user
USER 1001