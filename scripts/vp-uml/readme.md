# 使用说明

 
```shell

docker run  -it -p 1999:1999 --name vp cheshuai/vpserver:16.3

docker run  -d -p 1999:1999 --name vp cheshuai/vpserver:16.3

docker logs -f vp

docker build -t cheshuai/vpserver:16.3 .

docker build -t cheshuai/vpserver:17.0 .

docker build -t cheshuai/vps:16.3 .

docker run  -d -p 1998:8080 --name vps cheshuai/vps:16.3

cheshuai/vps:16.3

docker build  --no-cache  -t cheshuai/vps:17.0  . 


docker run  -d -p 1996:1999 --name vps cheshuai/vps:16

docker push cheshuai/vpserver:16.3

```
默认由于使用了AWT 处理成员头像，需要安装对应的组件

```

yum  install -y fontconfig libfreetype6
#install libfontconfig1

```

```Dockerfile

FROM adoptopenjdk/openjdk8:jdk8u252-b09-alpine
MAINTAINER JhonLarru
EXPOSE 7105
COPY src/main/resources/reportes/ /app/
COPY build/libs/*.jar /app/application.jar
RUN apk add --no-cache msttcorefonts-installer fontconfig
RUN update-ms-fonts
# Google fonts
RUN wget https://github.com/google/fonts/archive/master.tar.gz -O gf.tar.gz --no-check-certificate
RUN tar -xf gf.tar.gz
RUN mkdir -p /usr/share/fonts/truetype/google-fonts
RUN find $PWD/fonts-master/ -name "*.ttf" -exec install -m644 {} /usr/share/fonts/truetype/google-fonts/ \; || return 1
RUN rm -f gf.tar.gz
RUN fc-cache -f && rm -rf /var/cache/*
ENTRYPOINT ["java", "-Djava.awt.headless=true", "-Duser.timezone=America/Lima", "-Xms128m", "-Xmx128m", "-jar", "/app/application.jar", "server", "--spring.config.location=file:/config/application.yaml"]


freetype-dev
libjpeg-turbo-dev
libpng-dev


apk add fontconfig
apk add --update ttf-dejavu
fc-cache --force

curl -X DELETE -u "$user:$pass" https://index.docker.io/v1/repositories/$namespace/$reponame/

yum install fontconfig
fc-cache --force

```


