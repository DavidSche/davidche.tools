# FROM bitnami/minideb
FROM consul:1.9.3

LABEL maintainer "Davidche <davidche@outlook.com>"

RUN apk --no-cache add tzdata  && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone 
	
