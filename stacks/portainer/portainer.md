 ### 安全方式启动portainer

#### 生成证书

```
$ mkdir -p /certs
$ cd /certs
$ openssl genrsa -out portainer.key 2048
$ openssl ecparam -genkey -name secp384r1 -out portainer.key
$ openssl req -new -x509 -sha256 -key portainer.key -out portainer.crt -days 3650
$ ls 

```

#### 启动 portainer

```
 docker run -d -p 443:9000 -p 8000:8000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock  -v /certs:/certs -v portainer_data:/data portainer/portainer --ssl --sslcert /certs/portainer.crt --sslkey /certs/portainer.key
```
 
 
securityEnhance

