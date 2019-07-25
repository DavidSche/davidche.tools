# redis cluster in kubernetes


部署命令

``` bash
$ kubectl apply -f redis-sts.yaml
configmap/redis-cluster created
statefulset.apps/redis-cluster created

$ kubectl apply -f redis-svc.yaml
service/redis-cluster created

```

验证部署

检查Redis节点是否已启动并正在运行：

``` bash

$ kubectl get pods

NAME                               READY   STATUS    RESTARTS   AGE
redis-cluster-0                    1/1     Running   0          7m
redis-cluster-1                    1/1     Running   0          7m
redis-cluster-2                    1/1     Running   0          6m
redis-cluster-3                    1/1     Running   0          6m
redis-cluster-4                    1/1     Running   0          6m
redis-cluster-5                    1/1     Running   0          5m
```

``` bash
$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                          STORAGECLASS   REASON   AGE
pvc-ae61ad5c-f0a5-11e8-a6e0-42010aa40039   1Gi        RWO            Delete           Bound    default/data-redis-cluster-0   standard                7m
pvc-b74b6ef1-f0a5-11e8-a6e0-42010aa40039   1Gi        RWO            Delete           Bound    default/data-redis-cluster-1   standard                7m
pvc-c4f9b982-f0a5-11e8-a6e0-42010aa40039   1Gi        RWO            Delete           Bound    default/data-redis-cluster-2   standard                6m
pvc-cd7af12d-f0a5-11e8-a6e0-42010aa40039   1Gi        RWO            Delete           Bound    default/data-redis-cluster-3   standard                6m
pvc-d5bd0ad3-f0a5-11e8-a6e0-42010aa40039   1Gi        RWO            Delete           Bound    default/data-redis-cluster-4   standard                6m
pvc-e3206080-f0a5-11e8-a6e0-42010aa40039   1Gi        RWO            Delete           Bound    default/data-redis-cluster-5   standard                5m
```

检查任何Pod以查看其附加量：

``` bash
$ kubectl describe pods redis-cluster-0 | grep pvc
  Normal  SuccessfulAttachVolume  29m   attachdetach-controller                          AttachVolume.Attach succeeded for volume "pvc-ae61ad5c-f0a5-11e8-a6e0-42010aa40039"

```

部署Redis群集

下一步是形成Redis群集。为此，我们运行以下命令并键入yes以接受配置。前三个节点成为主节点，后三个节点成为奴隶。

``` bash

$ kubectl exec -it redis-cluster-0 -- redis-cli --cluster create --cluster-replicas 1 $(kubectl get pods -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 ')

```

验证群集部署

检查群集详细信息以及每个成员的角色。

``` bash

$ kubectl exec -it redis-cluster-0 -- redis-cli cluster info

```

``` bash
$ for x in $(seq 0 5); do echo "redis-cluster-$x"; kubectl exec redis-cluster-$x -- redis-cli role; echo; done
```

相关参考文件


http://redisdoc.com/topic/cluster-spec.html#cluster-spec

https://my.oschina.net/neuront/blog/758622


## swarm搭建6节点集群文档及脚本

https://blog.newnius.com/setup-redis-cluster-based-on-docker-swarm.html

https://github.com/newnius/scripts/tree/master/redis-cluster


