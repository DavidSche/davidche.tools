# FROM bitnami/minideb
FROM bitnami/redis:5.0.4

LABEL maintainer "Davidche <davidche@outlook.com>"

# User root is required for installing packages
USER root

RUN  cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata	

RUN rm -f /etc/localtime
RUN ln -s /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime

# Return to previous non-root user
USER 1001