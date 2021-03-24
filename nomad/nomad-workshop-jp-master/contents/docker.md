## 使用Nomad运行Docker映像

Nomad不仅限于像Docker这样的容器工作负载，它还可以执行各种类型的任务，例如独立的`Java`, `RaW Exec`和`Qemu`。

每个任务都由客户端上的`Task Driver`“任务驱动程序”隔离并执行。Task Driver任务驱动程序是可插入的，每个驱动程序的定义由Job定义Taskn中的`plugin stanza`设置。

在这里，我将在Nomad上运行一些Docker映像。我们还将在本章中尝试持久化硬盘数据。

## Docker Task Driver 处理Docker任务驱动程序

顾名思义，Docker Task Driver是用于运行Docker Image的驱动程序。通过使用它，可以声明性地设置下载pull Docker Image并执行它所需的卷和网络。

首先，让我们在Nomad上运行一个简单的Docker Image。

如下所示创建作业定义文件。

```shell
$ cd nomad-workshop
$ export DIR=$(pwd)
$ cat << EOF > mysql.nomad
job "mysql-5.7" {
  datacenters = ["dc1"]

  type = "service"

  group "mysql-group" {
    count = 1
    task "mysql-task" {
      driver = "docker"
      config {
        image = "mysql:5.7.28"
        port_map {
          db = 3306
        }
      }
      env {
        "MYSQL_ROOT_PASSWORD" = "rooooot"
      }
      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 10
          port "db" {
            static = 3306
          }
        }
      }
    }
  }
}
EOF
```

`job` 默认的`dc1`用于“作业”的`datacenters`“数据中心”。作业的类型设置为`type`，但是这次将其设置为`service`，因为它是MySQL中的长时间运行的进程。

`group`是任务组，`count`是任务数。这次是MySQL1即时，所以它是1。实际的应用程序位于`task`内部。驱动程序指定Docker，然后是与Docker相关的`image`, `port_map`, `env` 映像，端口映射和环境设置。

`image`默认情况下，“ image”是从Docker Hub提取的，但是您可以通过编写URL从其他注册表获取它。启动MySQL映像所需的root密码在`env`中设置。

`network` 由于这次使用网络的端口的是MySQL，因此在静态中将其设置为`3306`。同样，它被转发到task.config.port_map中指定的`3306`端口，以便可以在本地进行通信。

现在让我们运行MySQL。

```shell
$ nomad job run -hcl1 mysql.nomad
```

一段时间后，Docker进程将启动。

The default `dc1` is used for` datacenters` of `job`. The type of job is set to `type`, but this time it is set to` service` because it is a Long Running Process in MySQL.

`group` is the Task Group and` count` is the number of Tasks. This time it is MySQL1 instant, so it is `1`. The actual app is inside `task`. `driver` specifies Docker, and after that are Docker-related` image`, `port_map`, and` env` settings.

By default, `image` is pulled from Docker Hub, but you can get it from other registries by writing the URL. The root password required to start the MySQL image is set in `env`.

Since `port` of` network` is MySQL this time, it is set as `3306` in Static. Also, this is port-forwarded to `3306` specified in` task.config.port_map` so that it can be communicated locally.

Now let's run MySQL.

```console
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                                   NAMES
9072cdae373f        mysql:5.7.28        "docker-entrypoint.s…"   About an hour ago   Up About an hour    192.168.3.183:3306->3306/tcp, 192.168.3.183:3306->3306/udp, 33060/tcp   mysql-task-9752bf56-26bf-1f39-ae69-e53b654521c9
```

```console
$ nomad job status mysql-5.7
ID            = mysql-5.7
Name          = mysql-5.7
Submit Date   = 2020-02-19T05:30:16Z
Type          = service
Priority      = 50
Datacenters   = dc1
Status        = running
Periodic      = false
Parameterized = false

Summary
Task Group   Queued  Starting  Running  Failed  Complete  Lost
mysql-group  0       0         1        0       0         0

Latest Deployment
ID          = a85e7c45
Status      = successful
Description = Deployment completed successfully

Deployed
Task Group   Desired  Placed  Healthy  Unhealthy  Progress Deadline
mysql-group  1        1       1        0          2020-02-19T05:40:39Z

Allocations
ID        Node ID   Task Group   Version  Desired  Status   Created  Modified
fc0c5fcf  31528bd6  mysql-group  0        run      running  27s ago  4s ago
```

让我们登录。 IP地址取决于环境。 复制docker ps的输出。

```console
$ mysql -u root -p -h192.168.3.183
Enter password:rooooot
```

## Persistence Disk 持久化数据

接下来，设置Persistence Disk持久性磁盘以持久化数据。 首先，尝试按原样写入数据，然后重新启动，并确保数据不会持久保存。

让我们输入数据并重新启动。

```
mysql> create database handson;
mysql> show databases;
```

在这种状态下，重新启动Nomad Job。 当前Nomad没有存储设置，而Job没有永久性磁盘。 因此，数据应在重新启动时重置。

```shell
$ nomad job stop mysql-5.7
$ nomad job run -hcl1 mysql.nomad
```

再次登录并尝试浏览数据。

```shell
$ mysql -u root -p -h192.168.3.183
```

```
mysql> show databases;
```

您刚刚创建的`handson`数据库消失了。 在使用Docker时，请使用Nomad的`volume`功能来处理需要磁盘（例如数据库）的有状态工作负载。

使用Persistent Disk永久磁盘

1.进行设置以处理客户端中的主机卷
2.进行设置以在“作业”定义中使用它

你需要两个。

首先，设置客户端。

```shell
$ cd nomad-workshop
$ mkdir mysql-data
```

` `nomad-local-config-client-1.hcl`,`nomad-local-config-client-2.hcl`,`nomad-local-config-client-3.hcl`的每个文件中的client项。
请添加如下。 其他保持不变。 将<DIR>替换为当前目录的绝对路径。

```hcl
client {
  enabled = true
  servers = ["127.0.0.1:4647"]
  host_volume "mysql-vol" {
    path = "<DIR>/mysql-data"
    read_only = false
  }
}
```

重写三个文件后重新启动。

```shell
$ ./run.sh
```

接下来，按如下所示重写MySQL作业文件。

```shell
$ cd nomad-workshop
$ sudo mkdir /var/lib/mysql
$ cat << EOF > mysql.nomad
job "mysql-5.7" {
  datacenters = ["dc1"]

  type = "service"

  group "mysql-group" {
    count = 1

    volume "mysql-vol" {
      type      = "host"
      read_only = false
      source    = "mysql-vol"
    }


    task "mysql-task" {
      driver = "docker"

      volume_mount {
        volume      = "mysql-vol"
        destination = "/var/lib/mysql"
        read_only   = false
      }

      config {
        image = "mysql:5.7.28"
        port_map {
          db = 3306
        }
      }
      env {
        "MYSQL_ROOT_PASSWORD" = "rooooot"
      }
      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 10
          port "db" {
            static = 3306
          }
        }
      }
    }
  }
}
EOF
```

在这里，由`host_volume`创建的卷被映射到Task Group任务组并安装在实际Task任务上。

使用它来启动MySQL。

```shell
$ nomad job run -hcl1 mysql.nomad
``` 

之后，以相同的方式输入数据并重新启动

```console
$ mysql -u root -p -h192.168.3.183
Enter password:rooooot
```

让我们输入数据并重新启动。

```
mysql> create database handson;
mysql> show databases;
```

重新启动Nomad Job。

```shell
$ nomad job stop mysql-5.7
$ nomad job run -hcl1 mysql.nomad
```

再次登录并尝试浏览数据。

```shell
$ mysql -u root -p -h192.168.3.183
```

```
mysql> show databases;
```

您会看到`handson`数据仍然存在。 另外，请查看主机的目录。

```console
$ ls mysql-data
auto.cnf           client-key.pem     ib_logfile1        performance_schema server-key.pem
ca-key.pem         handson            ibdata1            private_key.pem    sys
ca.pem             ib_buffer_pool     ibtmp1             public_key.pem
client-cert.pem    ib_logfile0        mysql              server-cert.pem
```

您应该看到MySQL数据存储在主机上。 这次我使用了`host_volume`，但是Nomad支持`CSI Plugin`并且可以处理各种类型的存储。

在这里，已经设置了Docker驱动程序的基础知识和Persistence Disk的设置，但是仍然可以进行各种设置。

最后，让我们停止工作。

```shell
$ nomad job stop mysql-5.7
```

### 参考资料
* [Drivers](https://www.nomadproject.io/docs/drivers/index.html)
* [Docker Driver](https://www.nomadproject.io/docs/drivers/docker.html)
* [Volume Configuration](https://www.nomadproject.io/docs/job-specification/volume.html)
* [Volume Mount Configuration](https://www.nomadproject.io/docs/job-specification/volume_mount.html)
* [CSI Plugin](https://www.hashicorp.com/blog/hashicorp-nomad-container-storage-interface-csi-beta/)
* [CSI Plugin Configuration](https://www.nomadproject.io/docs/job-specification/csi_plugin/)