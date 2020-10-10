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


### 中文 

``` bash
#  https://github.com/renyinping/portainer-cn
# wget -O- https://raw.githubusercontent.com/renyinping/portainer-cn/master/Portainer-CN.zip | unzip -d /Portainer-CN/ -
docker volume create portainer_data
docker run -d -p 9000:9000 --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data -v /Portainer-CN:/public --name portainer portainer/portainer:1.20.2



```

```
docker network create --driver overlay --attachable portainer_agent_network


$ docker service create --name portainer_agent --network portainer_agent_network --publish mode=host,target=9001,published=9001 -e AGENT_CLUSTER_ADDR=tasks.portainer_agent --mode global --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock --mount type=bind,src=//var/lib/docker/volumes,dst=/var/lib/docker/volumes --mount type=bind,src=/,dst=/host portainer/agent



```