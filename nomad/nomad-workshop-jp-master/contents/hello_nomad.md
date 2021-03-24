# Nomad 快速上手

第一次游牧

让我们在这里简短地认识Nomad。

首先，创建一个工作目录。

```shell
$ mkdir nomad-workshop
$ cd nomad-workshop
```

请从[这里](https://www.nomadproject.io/downloads.html)下载与您的操作系统匹配的操软件。

与其他HashiCorp产品一样，Nomad是单个二进制文件，因此您可以通过将下载的二进制文件路径简单地加入到Path中来使用它。

```console
$ unzip nomad*.zip
$ chmod + x nomad
$ mv nomad /usr/local/bin
$ nomad -version
Nomad v0.10.0 (25ee121d951939504376c70bf8d7950c1ddb6a82)
```

让我们检查一下当前安装的Nomad的版本。

```console
$ nomad -version

Nomad v0.11.1 (1cbb2b9a81b5715be2f201a4650293c9ae517b87)
```

接下来，尝试以开发模式启动服务器。

**如果您正在使用MacOS并获取JDK或Java相关消息，请从[此处]（https://support.apple.com/kb/DL1572?locale=zh_CN）安装Java软件包。 ** **

```shell
$ nomad agent -dev
```

> 如果您正在使用sudo运行Docker `sudo nomad agent -dev`

Nomad通常会启动运行实际工作负载的客户端和提供管理功能（如计划）作为单独选项的服务器。

启动具有服务器和客户端特征的开发模式，以使其更易于查看和测试Nomad的功能。 同样，在开发模式下，侦听器和存储设置是预先配置的。

要查看服务器的状态和列表，请运行以下命令。

```console
$ nomad server members

Name                        Address    Port  Status  Leader  Protocol  Build  Datacenter  Region
masa-mackbook.local.global  127.0.0.1  4648  alive   true    2         0.9.5  dc1         global
```

要查看客户端的状态，请运行以下命令。

```console
$ nomad node status
ID        DC   Name                 Class   Drain  Eligibility  Status
33a379fc  dc1  masa-mackbook.local  <none>  false  eligible     ready
```

让我们运行一个简单的作业。

Nomad可以创建示例Job文件。

```shell
$ nomad job init -short     # 如果添加-short选项，将创建不带注释的作业文件。
```

将在目录中创建一个名为example.nomad的文件。 Nomad Job文件的扩展名为.nomad。 有关作业文件的详细信息，
请参阅[here]（https://www.nomadproject.io/docs/job-specification/index.html）。

```console
$ cat example.nomad

job "example" {
  datacenters = ["dc1"]

  group "cache" {
    task "redis" {
      driver = "docker"

      config {
        image = "redis:3.2"
        port_map {
          db = 6379
        }
      }

      resources {
        cpu    = 500
        memory = 256
        network {
          mbits = 10
          port "db" {}
        }
      }

      service {
        name = "redis-cache"
        tags = ["global", "cache"]
        port = "db"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
```

在Job文件中，以*声明方式*描述要部署的“内容”和“位置”。

在这个例子中，我们将使用Docker为`redis：3.2`镜像启动一个容器。 而且，它将仅在具有500Mhz CPU，256MB内存和10Mbit / s网络带宽的节点上运行。

让我们实际执行它。

```console
$ nomad job run example.nomad

==> Monitoring evaluation "9b9e5f9b"
    Evaluation triggered by job "example"
    Evaluation within deployment: "a3022d8f"
    Allocation "701f3254" created: node "33a379fc", group "cache"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "9b9e5f9b" finished with status "complete"
```

让我们检查容器是否真正启动。

```console
$ docker ps

CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                                                  NAMES
8dd1bfd98166        redis:3.2           "docker-entrypoint.s…"   About a minute ago   Up About a minute   127.0.0.1:28646->6379/tcp, 127.0.0.1:28646->6379/udp   redis-0450729c-179f-b373-0cc9-513514275d91
```

`redis:3.2`您可以看到它正在运行。
您可以从“ nomad logs”命令中查看日志。 在参数中指定分配ID。 在此示例中，您可以从运行Job的输出中看到它是“ 701f3254”。

```console
$ nomad logs 701f3254

1:C 29 Aug 06:53:41.954 # Warning: no config file specified, using the default config. In order to specify a config file use redis-server /path/to/redis.conf
                _._
           _.-``__ ''-._
      _.-``    `.  `_.  ''-._           Redis 3.2.12 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 1
  `-._    `-._  `-./  _.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |           http://redis.io
  `-._    `-._`-.__.-'_.-'    _.-'
 |`-._`-._    `-.__.-'    _.-'_.-'|
 |    `-._`-._        _.-'_.-'    |
  `-._    `-._`-.__.-'_.-'    _.-'
      `-._    `-.__.-'    _.-'
          `-._        _.-'
              `-.__.-'

1:M 29 Aug 06:53:41.955 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:M 29 Aug 06:53:41.955 # Server started, Redis version 3.2.12
1:M 29 Aug 06:53:41.955 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
1:M 29 Aug 06:53:41.955 * The server is now ready to accept connections on port 6379
```

现在，让我们对作业文件进行一些更改。 尝试将容器数量从默认值1增加到3。
打开作业文件，然后将[`count`属性]（https://www.nomadproject.io/docs/job-specification/group.html#count）添加到`group`节中。

```hcl
group "cache" {
  count = 3

  task "redis" {
```

Nomad具有通过更改作业文件来计划要更改的内容以及更改方式的功能。 这使您可以验证更改并事先确保更改正确。

```console
$ nomad job plan example.nomad

+/- Job: "example"
+/- Stop: "true" => "false"
+/- Task Group: "cache" (3 create)
  +/- Count: "1" => "3" (forces create)
      Task: "redis"

Scheduler dry-run:
- All tasks successfully allocated.

Job Modify Index: 254
To submit the job with version verification run:

nomad job run -check-index 254 example.nomad

When running the job with the check-index flag, the job will only be run if the
server side version matches the job modify index returned. If the index has
changed, another user has modified the job and the plan's results are
potentially invalid.
```

查看计划的内容，您可以看到计数已从1更改为3。
让我们运行一个新的Job文件。

```console
$ nomad job run example.nomad

==> Monitoring evaluation "164d6cf5"
    Evaluation triggered by job "example"
    Allocation "8cf4812b" created: node "33a379fc", group "cache"
    Allocation "b8c71633" created: node "33a379fc", group "cache"
    Allocation "bb7db1e3" created: node "33a379fc", group "cache"
    Allocation "bb7db1e3" status changed: "pending" -> "running" (Tasks are running)
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "164d6cf5" finished with status "complete"
```

过了一会儿，让我们看一下docker ps的容器信息。

```console
$ docker ps

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                  NAMES
94401e464ba7        redis:3.2           "docker-entrypoint.s…"   56 seconds ago      Up 55 seconds       127.0.0.1:31303->6379/tcp, 127.0.0.1:31303->6379/udp   redis-8cf4812b-c0fe-c817-acfa-3b42920743a2
834de1552749        redis:3.2           "docker-entrypoint.s…"   56 seconds ago      Up 56 seconds       127.0.0.1:28871->6379/tcp, 127.0.0.1:28871->6379/udp   redis-bb7db1e3-c015-a9fe-1388-dd3016791e8b
a47d0ae31dd2        redis:3.2           "docker-entrypoint.s…"   56 seconds ago      Up 55 seconds       127.0.0.1:23735->6379/tcp, 127.0.0.1:23735->6379/udp   redis-b8c71633-c333-c6e9-8217-a4c0bdddf180
```

您可以看到三个容器正在按作业文件中的定义运行。
现在，Nomad监视作业以保持其写入作业文件中的状态。 因此，让我们强行“杀死”一个容器。 在这里，容器ID为“ 94401e464ba7”的容器被终止。

```console
$ docker kill 94401e464ba7

94401e464ba7

$ docker ps

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                  NAMES
834de1552749        redis:3.2           "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes        127.0.0.1:28871->6379/tcp, 127.0.0.1:28871->6379/udp   redis-bb7db1e3-c015-a9fe-1388-dd3016791e8b
a47d0ae31dd2        redis:3.2           "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes        127.0.0.1:23735->6379/tcp, 127.0.0.1:23735->6379/udp   redis-b8c71633-c333-c6e9-8217-a4c0bdddf180

```

容器的数量减少了一个。
Nomad监视幕后的变化并将其纠正为应有的状态。
等待一段时间，然后再次检查Docker的状态。

```console
$ docker ps

CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                  PORTS                                                  NAMES
d0d3dd071082        redis:3.2           "docker-entrypoint.s…"   1 second ago        Up Less than a second   127.0.0.1:31303->6379/tcp, 127.0.0.1:31303->6379/udp   redis-8cf4812b-c0fe-c817-acfa-3b42920743a2
834de1552749        redis:3.2           "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes            127.0.0.1:28871->6379/tcp, 127.0.0.1:28871->6379/udp   redis-bb7db1e3-c015-a9fe-1388-dd3016791e8b
a47d0ae31dd2        redis:3.2           "docker-entrypoint.s…"   2 minutes ago       Up 2 minutes            127.0.0.1:23735->6379/tcp, 127.0.0.1:23735->6379/udp   redis-b8c71633-c333-c6e9-8217-a4c0bdddf180
```

它已返回到作业文件中定义的状态。
要查看此Nomad的工作状态，请使用“ nomad job status”命令。

```console
$ nomad job status example

ID            = example
Name          = example
Submit Date   = 2019-08-30T13:42:31+09:00
Type          = service
Priority      = 50
Datacenters   = dc1
Status        = running
Periodic      = false
Parameterized = false

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
cache       0       1         2        1       5         0

Allocations
ID        Node ID   Task Group  Version  Desired  Status    Created     Modified
b65b0dba  33a379fc  cache       7        run      pending   0s ago      0s ago
8cf4812b  33a379fc  cache       7        stop     failed    24m5s ago   0s ago
b8c71633  33a379fc  cache       7        run      running   24m5s ago   23m51s ago
bb7db1e3  33a379fc  cache       7        run      running   24m5s ago   23m45s ago
701f3254  33a379fc  cache       5        stop     complete  22h12m ago  4h54m ago
```

您可以看到一个容器“失败”，并且正在执行“启动”分配以恢复它。


使用“ nomad job stop”命令结束Nomad Job。

```console
$ nomad job stop example

==> Monitoring evaluation "8b5de473"
    Evaluation triggered by job "example"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "8b5de473" finished with status "complete"
```

完成后，将清理由Nomad分配的作业。

## Nomadを通常モードで起動する

接下来，以普通模式而不是开发人员模式启动。 在正常模式下，服务器和客户端可以分别启动，并且可以进行各种灵活的设置。 这次，我将尝试使用一个服务器端和三个客户端的配置。

为服务器创建以下文件。

```shell
$ cd nomad-workshop
$ MY_PATH=$(pwd)

$ cat << EOF > nomad-local-config-server.hcl
data_dir  = "${MY_PATH}/local-nomad-data"

bind_addr = "127.0.0.1"

server {
  enabled          = true
  bootstrap_expect = 1
}

advertise {
  http = "127.0.0.1"
  rpc  = "127.0.0.1"
  serf = "127.0.0.1"
}
EOF
```

接下来，为客户端创建一个文件。 这次，我们需要在本地启动所有文件并更改每个端口号，因此请创建三个文件。

```shell
$ cat << EOF > nomad-local-config-client-1.hcl

data_dir  = "${MY_PATH}/local-cluster-data-1"

bind_addr = "127.0.0.1"

client {
  enabled = true
  servers = ["127.0.0.1:4647"]
}

advertise {
  http = "127.0.0.1"
  rpc  = "127.0.0.1"
  serf = "127.0.0.1"
}

ports {
  http = 5641
  rpc  = 5642
  serf = 5643
}
EOF

$ cat << EOF > nomad-local-config-client-2.hcl

data_dir  = "${MY_PATH}/local-cluster-data-2"

bind_addr = "127.0.0.1"

client {
  enabled = true
  servers = ["127.0.0.1:4647"]
}

advertise {
  http = "127.0.0.1"
  rpc  = "127.0.0.1"
  serf = "127.0.0.1"
}

ports {
  http = 5644
  rpc  = 5645
  serf = 5646
}
EOF

$ cat << EOF > nomad-local-config-client-3.hcl

data_dir  = "${MY_PATH}/local-cluster-data-3"

bind_addr = "127.0.0.1"

client {
  enabled = true
  servers = ["127.0.0.1:4647"]
}

advertise {
  http = "127.0.0.1"
  rpc  = "127.0.0.1"
  serf = "127.0.0.1"
}

ports {
  http = 5647
  rpc  = 5648
  serf = 5649
}
EOF
```

创建启动外壳。

```shell
$ cat << EOF > run.sh
#!/bin/sh
pkill nomad
pkill java

sleep 10

nomad agent -config=${MY_PATH}/nomad-local-config-server.hcl &

nomad agent -config=${MY_PATH}/nomad-local-config-client-1.hcl &
nomad agent -config=${MY_PATH}/nomad-local-config-client-2.hcl &
nomad agent -config=${MY_PATH}/nomad-local-config-client-3.hcl &
EOF
```

<details><summary>sudoでDockerを起動している場合</summary>
  
```shell
$ cat << EOF > run.sh
#!/bin/sh
sudo pkill nomad
sudo pkill java

sleep 10

sudo nomad agent -config=${MY_PATH}/nomad-local-config-server.hcl &

sudo nomad agent -config=${MY_PATH}/nomad-local-config-client-1.hcl &
sudo nomad agent -config=${MY_PATH}/nomad-local-config-client-2.hcl &
sudo nomad agent -config=${MY_PATH}/nomad-local-config-client-3.hcl &
EOF
```
</details>

让我们开始启动 Nomad。

```shell
$ chmod +x run.sh
$ ./run.sh
```

`http://localhost:4646/ui/`にブラウザでアクセスし、一つのサーバと三つのクライアントが起動していることを確認してください。


>如果您在服务器上运行它，但无法在本地访问浏览器，请尝试设置端口转发。
>对于macOS，在本地计算机上ssh -L 4646：127.0.0.1：4646 <username> @ <SERVERS_PUBLIC_IP> -N

让我们尝试开始与以前相同的工作。

```console
$ nomad job run example.nomad
==> Monitoring evaluation "164d6cf5"
    Evaluation triggered by job "example"
    Allocation "8cf4812b" created: node "33a379fc", group "cache"
    Allocation "b8c71633" created: node "33a379fc", group "cache"
    Allocation "bb7db1e3" created: node "33a379fc", group "cache"
    Allocation "bb7db1e3" status changed: "pending" -> "running" (Tasks are running)
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "164d6cf5" finished with status "complete"
```

在这里显示

* 记下“分配”（在上面的示例中为“ bb7db1e3”）。
* 记下“评估”（在上面的示例中为“ 164d6cf5”）。

从现在开始，我们将使用此环境尝试Nomad的各种功能。

##参考链接

## 参考リンク

* [Nomad Architecture](https://www.nomadproject.io/docs/internals/architecture.html)
* [Nomad Agent Configuration](https://www.nomadproject.io/docs/configuration/index.html)

