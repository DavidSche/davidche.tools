# 说明

```
# docker node update --label-add consul=true cqy-efk-node01 
# cqy-efk-node01

# [root@cqy-efk-node01 ~]# docker network create -d overlay --attachable prod
```

Consul 集群至少要三个节点才能正常启动

docker service scale 扩展一个或多个服务

docker service scale webtier_nginx=5
