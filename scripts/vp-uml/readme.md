# 使用说明

 
```shell

docker run  -it -p 1999:1999 --name vp cheshuai/vpserver:16.3

docker run  -d -p 1999:1999 --name vp cheshuai/vpserver:16.3

docker logs -f vp

docker build -t cheshuai/vpserver:16.3 .

docker build -t cheshuai/vpserver:16.3 .


docker push cheshuai/vpserver:16.3

```
默认由于使用了AWT 处理成员头像，需要安装对应的组件

```

yum  install -y fontconfig libfreetype6
#install libfontconfig1

```






