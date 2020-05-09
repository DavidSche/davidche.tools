FROM debian:buster
LABEL maintainer="docker@ix.ai" \
      ai.ix.repository="ix.ai/mariadb-backup"

ENV DEBIAN_FRONTEND=noninteractive TERM=linux
ENV TIMEZONE=Asia/Shanghai TZ=Asia/Shanghai

COPY src/ /app

RUN chmod 755 /app/*.sh && \
    groupadd -g 666 mybackup && \
    useradd -u 666 -g 666 -d /backup -c "MariaDB Backup User" mybackup && \
    apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y mydumper && \
    apt-get -y --purge autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done;

VOLUME ["/backup"]
WORKDIR /backup

ENV DB_PORT=3306 DB_USER=root

ENTRYPOINT ["/app/mariadb-backup.sh"]