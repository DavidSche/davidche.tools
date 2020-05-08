FROM alpine:3.9

ADD 'https://github.com/msoap/shell2http/releases/download/1.13/shell2http-1.13.linux.amd64.tar.gz' /tmp/
ADD 'https://github.com/mikefarah/yq/releases/download/2.4.0/yq_linux_amd64' /tmp/
COPY yaml-endpoint.sh /usr/local/sbin/

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
    && apk add --no-cache jq bash curl \
    && tar -C /tmp -xzf /tmp/shell2http-1.13.linux.amd64.tar.gz \
    && mv /tmp/shell2http /usr/local/bin/ \
    && mv /tmp/yq_linux_amd64 /usr/local/bin/yq \
    && chmod 755 /usr/local/bin/yq \
    && rm -rf /tmp/*

USER nobody:nobody

EXPOSE 8080
CMD ["shell2http", "-cgi", "-no-index", "-export-all-vars", "-timeout=30", "/", "yaml-endpoint.sh"]