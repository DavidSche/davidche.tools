# 说明

```
# docker node update --label-add consul=true cqy-efk-node01 
# cqy-efk-node01

# [root@cqy-efk-node01 ~]# docker network create -d overlay --attachable prod
```

Consul 集群至少要三个节点才能正常启动

docker service scale 扩展一个或多个服务

docker service scale webtier_nginx=5


```

curl \
    --request PUT \
    http://192.168.9.21:8500/v1/agent/service/deregister/website-manager-9283e4a4e43965aa6206a019953b0dc8


curl \
    --request PUT \
    http://192.168.9.41:8500/v1/agent/service/deregister/user-manager-80ff3753a42f5cd974d4e701e2d36796

curl \
    --request PUT \
    http://192.168.9.10:8500/v1/agent/service/deregister/server-provider-9000
	
```

curl \
    --request PUT \
    http://192.168.9.40:8500/v1/agent/service/deregister/hj-trade-manager-hjjlocal-80090f1a8aab66c2dc9a5178c04f9e52
	

启动服务命令 

	./consul agent -dev   -client 0.0.0.0 -ui

nohup ./consul agent -dev   -client 0.0.0.0 -ui  &

需要加上红色这段才能指定ip访问

/home/minio server http://192.168.9.70/home/cqy/data

/root/mc policy set public 9.70/noauthorizefiles

noauthorizefiles

