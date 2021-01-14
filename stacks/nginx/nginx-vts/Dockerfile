ARG NGINX_VSERSION=1.18.0
ARG VTS_VERSION=0.1.18
FROM alpine:3.11.6 AS nginx-vts

ARG NGINX_VSERSION
ARG VTS_VERSION

RUN mkdir /workspace
WORKDIR /workspace

RUN apk --update add \
  curl \
  gd-dev \
  geoip-dev \
  gnupg1 \
  libc-dev \
  libxslt-dev \
  linux-headers \
  make \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  gcc

RUN wget http://nginx.org/download/nginx-${NGINX_VSERSION}.tar.gz
RUN tar xvf nginx-${NGINX_VSERSION}.tar.gz

RUN wget https://github.com/vozlt/nginx-module-vts/archive/v${VTS_VERSION}.tar.gz
RUN tar xvf v${VTS_VERSION}.tar.gz

WORKDIR /workspace/nginx-${NGINX_VSERSION}

RUN ./configure --with-compat --add-dynamic-module=/workspace/nginx-module-vts-${VTS_VERSION}
RUN make modules
RUN cp objs/ngx_http_vhost_traffic_status_module.so /workspace/ngx_http_vhost_traffic_status_module.so

###########################################################
ARG NGINX_VSERSION
FROM nginx:${NGINX_VSERSION}-alpine

COPY --from=nginx-vts /workspace/ngx_http_vhost_traffic_status_module.so /etc/nginx/modules/
ADD ./nginx.conf /etc/nginx/nginx.conf