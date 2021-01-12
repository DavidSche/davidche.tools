#Docker Swarm 使用记录



##  Docker Swarm 历史任务显示数量

How to alter task history retention inside Docker Swarm cluster

```shell
docker swarm update --task-history-limit 0

```

Update service to reapply task history retention.

```shell

$ docker service update --with-registry-auth --image registry.example.com/websites/blog:staging blog_staging | grep ^verify:\ Service"

verify: Service converged


```

[脚本出处](https://blog.sleeplessbeastie.eu/2020/12/09/how-to-alter-task-history-retention-inside-docker-swarm-cluster/
)
