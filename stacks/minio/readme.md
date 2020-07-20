
```bash
docker run -d -p 9000:9000 --name minio1 --restart=on-failure\
  -e "MINIO_ACCESS_KEY=12345678" \
  -e "MINIO_SECRET_KEY=12345678" \
  -v /minio_data:/data \
  minio/minio server /data


RELEASE.2019-08-21T19-40-07Z
docker pull minio/minio:RELEASE.2019-08-21T19-40-07Z

docker run -d -p 9000:9000 --name minio1 --restart=on-failure\
  -e "MINIO_ACCESS_KEY=12345678" \
  -e "MINIO_SECRET_KEY=12345678" \
  minio/minio server /data


docker run -d -p 9000:9000 --name minio1 --restart=on-failure\
  -v /home/minio_data:/data \
  -e "MINIO_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE" \
  -e "MINIO_SECRET_KEY=wJalrXUtnFEMIK7MDENGbPxRfiCYEXAMPLEKEY" \
  minio/minio server /data
```

5. 客户端mc安装

5.1 下载

wget https://dl.min.io/client/mc/release/linux-amd64/mc

5.2 启动

./mc ls

5.3 编辑配置

mc启动时会自动生成配置文件，vi /root/.mc/config.json

增加配置：

                "29": {

                        "url": "http://192.168.9.29:9000",

                        "accessKey": "12345678",

                        "secretKey": "12345678",

                        "api": "S3v4",

                        "lookup": "auto"

                },

                "30": {

                        "url": "http://192.168.9.30:9000",

                        "accessKey": "12345678",

                        "secretKey": "12345678",

                        "api": "S3v4",

                        "lookup": "auto"

                },

                "31": {

                        "url": "http://192.168.9.31:9000",

                        "accessKey": "12345678",

                        "secretKey": "12345678",
r
                        "api": "S3v4",

                        "lookup": "auto"

                },

二、mc使用
1、创建桶

/root/mc mb 40/noauthorizefiles/

2、上传文件
/root/mc cp 1.PNG 29/mybucket1/test/

3、上传文件夹
/root/mc cp --recursive test 29/mybucket1/test/

4、设置公开访问
/root/mc policy set public 40/noauthorizefiles

5、访问下载
http://192.168.9.31:9000/myb                                                                                                                                                                                                                                                                               ucket1/test/test/1.PNG

设置公开访问后才可通过此方法下载

6、新增节点后数据同步

新增节点需重启集群，重启后执行

./mc admin heal -r 32

32为/root/mc/config.json中增加的节点

7、宕机启动后数据同步

./mc admin heal -r 31/mybucket1/test

需指定桶名称，不能只指定节点名称


scp -r root@192.168.5.164:/root/minioserver/data/noauthorizefiles ./




