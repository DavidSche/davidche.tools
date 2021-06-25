# 保持主机的数据清洁

## 保持主机的数据清洁是必要的
当您推出新图像时，您面临着每个主机不断下载图像，以及可能已死和停止容器花费您宝贵的资源（我看着你）。
当我第一次设置清理时， 使用设置一个 cron 工作， 每小时运行， 并清理一切 （除了卷！
唯一的麻烦是使用cron的工作，需要明确地在主机上服务器上设置（除了docker安装）。

## 清理堆栈
最后找到了一个聪明的解决方案， 替代cron 工作： 一个全局服务工作， 将永远重新启动每个节点与一个小时的延迟。
与 cron 工作不同，这不会在特定时间运行，但考虑到我的需要，这已经足够了。
下面的堆栈每小时将修剪集群中所有主机的容器和图像。
值得注意的是，这里明确不修剪此配置中的卷，因为我将它们视为可靠的数据。
您可以通过运行创建：
```shell
$ docker stack deploy --compose-file cleaner.yaml
```

```yaml
version: "3.3"
services:
  swarm-cleanup:
    image: docker
    command: |
      sh -c "
        docker container prune -f &&
        docker image prune -f -a"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    deploy:
      mode: global
      restart_policy:
        delay: 1h
      resources:
        limits: { cpus: '0.1', memory: '32M' }
        reservations: { cpus: '0.025', memory: '16M' }
```

享受！