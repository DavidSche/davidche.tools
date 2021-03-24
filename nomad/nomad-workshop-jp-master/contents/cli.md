# Nomad CLI上手

在这里，我想通过关于游牧cli基本用法的指南来解释游牧的各种功能。

如果您还没有启动Nomad，请参考`First Nomad`启动Nomad集群。

## completion

Nomad提供输入补充以支持命令输入。 让我们使用以下命令进行安装。

```shell
$ nomad -autocomplete-install
```

如果使用此选项卡，则选项卡将完成子命令的输入。

## node 节点

首先，让我们获取客户端节点的信息。

```console
$ nomad node status
ID        DC   Name           Class   Drain  Eligibility  Status
6477d9ed  dc1  Takayukis-MBP  <none>  false  eligible     ready
4b635091  dc1  Takayukis-MBP  <none>  false  eligible     ready
8f5984b6  dc1  Takayukis-MBP  <none>  false  eligible     ready
```

我得到了客户端节点的列表和状态。 这对于所有命令都是通用的，但是您可以使用`-verbose`选项查看更详细的结果。

```console
$ nomad node status -verbose
ID                                    DC   Name           Class   Address    Version  Drain  Eligibility  Status
6477d9ed-8bfd-2258-91f9-cab5965ff787  dc1  Takayukis-MBP  <none>  127.0.0.1  0.10.0   false  eligible     ready
4b635091-f444-34d6-5b33-a8aedcc49664  dc1  Takayukis-MBP  <none>  127.0.0.1  0.10.0   false  eligible     ready
8f5984b6-faf6-a485-c3cf-2729e26fc775  dc1  Takayukis-MBP  <none>  127.0.0.1  0.10.0   false  eligible     ready
```

另外，如果添加`-json`选项，结果将以JSON返回。 当您想从输出结果中获取值时，这非常方便。

```shell
$ nomad node status -json
```

<details><summary>出力結果例</summary>
	
```json
[
    {
        "Address": "127.0.0.1",
        "CreateIndex": 8,
        "Datacenter": "dc1",
        "Drain": false,
        "Drivers": {
            "java": {
                "Attributes": {
                    "driver.java": "true",
                    "driver.java.version": "12",
                    "driver.java.runtime": "OpenJDK Runtime Environment (build 12+33)",
                    "driver.java.vm": "OpenJDK 64-Bit Server VM (build 12+33, mixed mode, sharing)"
                },
                "Detected": true,
                "HealthDescription": "Healthy",
                "Healthy": true,
                "UpdateTime": "2020-01-30T13:12:15.609103+09:00"
            },
            "exec": {
                "Attributes": null,
                "Detected": false,
                "HealthDescription": "exec driver unsupported on client OS",
                "Healthy": false,
                "UpdateTime": "2020-01-30T13:12:15.518818+09:00"
            },
            "qemu": {
                "Attributes": null,
                "Detected": false,
                "HealthDescription": "",
                "Healthy": false,
                "UpdateTime": "2020-01-30T13:12:15.519712+09:00"
            },
            "raw_exec": {
                "Attributes": {
                    "driver.raw_exec": "true"
                },
                "Detected": true,
                "HealthDescription": "Healthy",
                "Healthy": true,
                "UpdateTime": "2020-01-30T13:12:15.520184+09:00"
            },
            "docker": {
                "Attributes": {
                    "driver.docker.volumes.enabled": "true",
                    "driver.docker.bridge_ip": "172.17.0.1",
                    "driver.docker.runtimes": "runc",
                    "driver.docker.os_type": "linux",
                    "driver.docker": "true",
                    "driver.docker.version": "19.03.5"
                },
                "Detected": true,
                "HealthDescription": "Healthy",
                "Healthy": true,
                "UpdateTime": "2020-01-30T13:12:15.554516+09:00"
            }
        },
        "ID": "6477d9ed-8bfd-2258-91f9-cab5965ff787",
        "ModifyIndex": 5688,
        "Name": "Takayukis-MBP",
        "NodeClass": "",
        "SchedulingEligibility": "eligible",
        "Status": "ready",
        "StatusDescription": "",
        "Version": "0.10.0"
    },
    {
        "Address": "127.0.0.1",
        "CreateIndex": 7,
        "Datacenter": "dc1",
        "Drain": false,
        "Drivers": {
            "java": {
                "Attributes": {
                    "driver.java": "true",
                    "driver.java.version": "12",
                    "driver.java.runtime": "OpenJDK Runtime Environment (build 12+33)",
                    "driver.java.vm": "OpenJDK 64-Bit Server VM (build 12+33, mixed mode, sharing)"
                },
                "Detected": true,
                "HealthDescription": "Healthy",
                "Healthy": true,
                "UpdateTime": "2020-01-30T13:12:16.643388+09:00"
            },
            "exec": {
                "Attributes": null,
                "Detected": false,
                "HealthDescription": "exec driver unsupported on client OS",
                "Healthy": false,
                "UpdateTime": "2020-01-30T13:12:16.561606+09:00"
            },
            "raw_exec": {
                "Attributes": {
                    "driver.raw_exec": "true"
                },
                "Detected": true,
                "HealthDescription": "Healthy",
                "Healthy": true,
                "UpdateTime": "2020-01-30T13:12:16.561737+09:00"
            },
            "qemu": {
                "Attributes": null,
                "Detected": false,
                "HealthDescription": "",
                "Healthy": false,
                "UpdateTime": "2020-01-30T13:12:16.561927+09:00"
            },
            "docker": {
                "Attributes": {
                    "driver.docker.runtimes": "runc",
                    "driver.docker.os_type": "linux",
                    "driver.docker": "true",
                    "driver.docker.version": "19.03.5",
                    "driver.docker.volumes.enabled": "true",
                    "driver.docker.bridge_ip": "172.17.0.1"
                },
                "Detected": true,
                "HealthDescription": "Healthy",
                "Healthy": true,
                "UpdateTime": "2020-01-30T13:12:16.604953+09:00"
            }
        },
        "ID": "4b635091-f444-34d6-5b33-a8aedcc49664",
        "ModifyIndex": 5689,
        "Name": "Takayukis-MBP",
        "NodeClass": "",
        "SchedulingEligibility": "eligible",
        "Status": "ready",
        "StatusDescription": "",
        "Version": "0.10.0"
    },
    {
        "Address": "127.0.0.1",
        "CreateIndex": 6,
        "Datacenter": "dc1",
        "Drain": false,
        "Drivers": {
            "qemu": {
                "Attributes": null,
                "Detected": false,
                "HealthDescription": "",
                "Healthy": false,
                "UpdateTime": "2020-01-30T13:12:16.584247+09:00"
            },
            "raw_exec": {
                "Attributes": {
                    "driver.raw_exec": "true"
                },
                "Detected": true,
                "HealthDescription": "Healthy",
                "Healthy": true,
                "UpdateTime": "2020-01-30T13:12:16.584363+09:00"
            },
            "docker": {
                "Attributes": {
                    "driver.docker.bridge_ip": "172.17.0.1",
                    "driver.docker.runtimes": "runc",
                    "driver.docker.os_type": "linux",
                    "driver.docker": "true",
                    "driver.docker.version": "19.03.5",
                    "driver.docker.volumes.enabled": "true"
                },
                "Detected": true,
                "HealthDescription": "Healthy",
                "Healthy": true,
                "UpdateTime": "2020-01-30T13:12:16.613387+09:00"
            },
            "java": {
                "Attributes": {
                    "driver.java.runtime": "OpenJDK Runtime Environment (build 12+33)",
                    "driver.java.vm": "OpenJDK 64-Bit Server VM (build 12+33, mixed mode, sharing)",
                    "driver.java": "true",
                    "driver.java.version": "12"
                },
                "Detected": true,
                "HealthDescription": "Healthy",
                "Healthy": true,
                "UpdateTime": "2020-01-30T13:12:16.66597+09:00"
            },
            "exec": {
                "Attributes": null,
                "Detected": false,
                "HealthDescription": "exec driver unsupported on client OS",
                "Healthy": false,
                "UpdateTime": "2020-01-30T13:12:16.584213+09:00"
            }
        },
        "ID": "8f5984b6-faf6-a485-c3cf-2729e26fc775",
        "ModifyIndex": 5690,
        "Name": "Takayukis-MBP",
        "NodeClass": "",
        "SchedulingEligibility": "eligible",
        "Status": "ready",
        "StatusDescription": "",
        "Version": "0.10.0"
    }
]
```
</details>

您可以通过执行命令`drain`在服务器维护，操作系统升级等过程中将工作负载迁移到Nomad。 那时，将每个节点切换到称为`ineligible`“不合格”的模式，并停止分配新任务。

```console
$ nomad node drain -enable -yes <NODE_ID>
2020-01-31T15:25:13+09:00: Ctrl-C to stop monitoring: will not cancel the node drain
2020-01-31T15:25:13+09:00: Node "6477d9ed-8bfd-2258-91f9-cab5965ff787" drain strategy set
2020-01-31T15:25:13+09:00: Drain complete for node 6477d9ed-8bfd-2258-91f9-cab5965ff787
2020-01-31T15:25:13+09:00: All allocations on node "6477d9ed-8bfd-2258-91f9-cab5965ff787" have stopped.
```

当实际的应用程序正在运行时，此过程会将其移动到另一个节点。 如果再次检查状态，它将切换为`ineligible`“不合格”。 在这种状态下，不会有新任务分配给该节点。

```console
$ nomad node status -verbose
ID                                    DC   Name           Class   Address    Version  Drain  Eligibility  Status
6477d9ed-8bfd-2258-91f9-cab5965ff787  dc1  Takayukis-MBP  <none>  127.0.0.1  0.10.0   false  ineligible   ready
4b635091-f444-34d6-5b33-a8aedcc49664  dc1  Takayukis-MBP  <none>  127.0.0.1  0.10.0   false  eligible     ready
8f5984b6-faf6-a485-c3cf-2729e26fc775  dc1  Takayukis-MBP  <none>  127.0.0.1  0.10.0   false  eligible     ready
```

维护结束后，如果您想再次接受任务，请再次切换到`eligible`“合格”状态。

```console
$ nomad node eligibility -enable 6477d9ed-8bfd-2258-91f9-cab5965ff787
$ nomad node  status -verbose
ID                                    DC   Name           Class   Address    Version  Drain  Eligibility  Status
6477d9ed-8bfd-2258-91f9-cab5965ff787  dc1  Takayukis-MBP  <none>  127.0.0.1  0.10.0   false  eligible     ready
4b635091-f444-34d6-5b33-a8aedcc49664  dc1  Takayukis-MBP  <none>  127.0.0.1  0.10.0   false  eligible     ready
8f5984b6-faf6-a485-c3cf-2729e26fc775  dc1  Takayukis-MBP  <none>  127.0.0.1  0.10.0   false  eligible     ready
```

## alloc

您可以使用`nomad alloc`获得有关分配的各种信息。 我将尝试获取日志。

在环境变量的“第一个Nomad”一章中设置您写下的分配ID，然后执行。


```shell
$ export ALLOC=<ALLOCAION_ID>
$ nomad alloc logs $ALLOC
```

接下来，我们将使用文件系统进行此分配。 通常，您必须遵循原始目录等，但是通过使用`fs`命令，将获得与分配ID相关联的信息。

```console
$ nomad alloc fs $ALLOC
Mode        Size   Modified Time              Name
drwxrwxrwx  160 B  2020-01-31T15:55:22+09:00  alloc/
drwxrwxrwx  160 B  2020-01-31T15:55:22+09:00  redis/

$ nomad alloc fs $ALLOC alloc/
Mode        Size   Modified Time              Name
drwxrwxrwx  64 B   2020-01-31T15:55:22+09:00  data/
drwxrwxrwx  192 B  2020-01-31T15:55:22+09:00  logs/
drwxrwxrwx  64 B   2020-01-31T15:55:22+09:00  tmp/

$ nomad alloc fs -stat $ALLOC alloc/logs/redis.stdout.0
Mode        Size     Modified Time              Content Type               Name
-rw-r--r--  2.0 KiB  2020-01-31T15:55:23+09:00  text/plain; charset=utf-8  redis.stdout.0

$ nomad alloc fs $ALLOC alloc/logs/redis.stdout.0
```

您应该已经能够获取日志。 对于目录，fs具有与ls相同的输出，对于文件具有与cat相同的输出。 我也可以通过使用-stat选项来检查文件信息。 还有`-tail`选项和更多。

另外，`nomad alloc status`可以检查分配状态。

```console
$ nomad alloc status $ALLOC
ID                  = 4d51a7ea
Eval ID             = 401db6fb
Name                = example.cache[0]
Node ID             = 4b635091
Node Name           = Takayukis-MBP
Job ID              = example
Job Version         = 1
Client Status       = running
Client Description  = Tasks are running
Desired Status      = run
Desired Description = <none>
Created             = 24m25s ago
Modified            = 1m33s ago
Deployment ID       = 5ca611b5
Deployment Health   = unhealthy

Task "redis" is "running"
Task Resources
CPU        Memory           Disk     Addresses
7/500 MHz  984 KiB/256 MiB  300 MiB  db: 192.168.3.38:26883

Task Events:
Started At     = 2020-01-31T07:18:15Z
Finished At    = N/A
Total Restarts = 1
Last Restart   = 2020-01-31T16:17:57+09:00

Recent Events:
Time                       Type             Description
2020-01-31T16:18:15+09:00  Started          Task started by client
2020-01-31T16:17:57+09:00  Restarting       Task restarting in 16.669875916s
2020-01-31T16:17:57+09:00  Terminated       Exit Code: 137, Exit Message: "Docker container exited with non-zero exit code: 137"
2020-01-31T16:17:57+09:00  Signaling        Task being sent a signal
2020-01-31T16:00:22+09:00  Alloc Unhealthy  Task not running for min_healthy_time of 10s by deadline
2020-01-31T15:55:23+09:00  Started          Task started by client
2020-01-31T15:55:22+09:00  Task Setup       Building Task Directory
2020-01-31T15:55:22+09:00  Received         Task received by client
```

这是一个非常常见的命令，例如分配失败时。

也可以使用其他处理生命周期的命令，例如`restart`, `stop` “重新启动”和“停止”。

## job

`job` “作业”命令是用于显示关于作业的各种操作和信息的命令。

让我们先尝试`deployments`“部署”。 您可以获取分配历史记录和状态。

```console
$ nomad job deployments example
ID        Job ID     Job Version  Status      Description
56f8ca80  mysql-5.7  0            successful  Deployment completed successfully
```

`history`打印版本。 用于在更改作业和升级版本时检查当前版本以及升级版本的日期和时间。 尽管此处未执行，但可以使用`job revert`命令回滚该作业。

```console
$ nomad job history example
Version     = 0
Stable      = true
Submit Date = 2020-01-31T15:53:24+09:00
```

`eval`命令是检查评估状态的命令。 复制您在“第一个Nomad”一章中记下的评估ID。

```console
$ nomad eval status <EVAL_ID>

ID                 = 720ff6d0
Create Time        = 35m23s ago
Modify Time        = 35m23s ago
Status             = complete
Status Description = complete
Type               = service
TriggeredBy        = job-register
Job ID             = mysql-5.7
Priority           = 50
Placement Failures = true

Failed Placements
Task Group "mysql-group" (failed to place 1 allocation):
  * Constraint "missing compatible host volumes" filtered 2 nodes

Evaluation "0d142ec3" waiting for additional capacity to place remainder
```

我经常使用`status`“状态”。 您可以检查作业状态和与该作业关联的分配ID。

```console
$ nomad job status example
ID            = example
Name          = example
Submit Date   = 2020-01-31T15:50:09+09:00
Type          = service
Priority      = 50
Datacenters   = dc1
Status        = running
Periodic      = false
Parameterized = false

Summary
Task Group  Queued  Starting  Running  Failed  Complete  Lost
cache       0       0         1        2       0         0

Latest Deployment
ID          = 5ca611b5
Status      = failed
Description = Failed due to progress deadline

Deployed
Task Group  Desired  Placed  Healthy  Unhealthy  Progress Deadline
cache       1        2       0        2          2020-01-31T16:00:09+09:00

Allocations
ID        Node ID   Task Group  Version  Desired  Status   Created     Modified
4d51a7ea  4b635091  cache       1        run      running  43m35s ago  20m43s ago
96209690  6477d9ed  cache       1        stop     failed   49m ago     43m35s ago
3761cbaf  4b635091  cache       0        stop     failed   53m32s ago  43m48s ago
```

`inspect` “检查”是用于获取Nomad的职位信息的详细信息的命令。 另外，当您想要JSON格式的结果时，请使用它。 似乎`nomad job status`使用`inspect` “检查”而不是“ -json”选项。

```shell
$ nomad inspect example
```

<details><summary>出力結果例</summary>
	
```json
{
    "Job": {
        "Affinities": null,
        "AllAtOnce": false,
        "Constraints": null,
        "CreateIndex": 6992,
        "Datacenters": [
            "dc1"
        ],
        "Dispatched": false,
        "ID": "example",
        "JobModifyIndex": 7017,
        "Meta": null,
        "Migrate": null,
        "ModifyIndex": 7103,
        "Name": "example",
        "Namespace": "default",
        "ParameterizedJob": null,
        "ParentID": "",
        "Payload": null,
        "Periodic": null,
        "Priority": 50,
        "Region": "global",
        "Reschedule": null,
        "Spreads": null,
        "Stable": false,
        "Status": "running",
        "StatusDescription": "",
        "Stop": false,
        "SubmitTime": 1580453409843865000,
        "TaskGroups": [
            {
                "Affinities": null,
                "Constraints": null,
                "Count": 1,
                "EphemeralDisk": {
                    "Migrate": false,
                    "SizeMB": 300,
                    "Sticky": false
                },
                "Meta": null,
                "Migrate": {
                    "HealthCheck": "checks",
                    "HealthyDeadline": 300000000000,
                    "MaxParallel": 1,
                    "MinHealthyTime": 10000000000
                },
                "Name": "cache",
                "Networks": null,
                "ReschedulePolicy": {
                    "Attempts": 0,
                    "Delay": 30000000000,
                    "DelayFunction": "exponential",
                    "Interval": 0,
                    "MaxDelay": 3600000000000,
                    "Unlimited": true
                },
                "RestartPolicy": {
                    "Attempts": 2,
                    "Delay": 15000000000,
                    "Interval": 1800000000000,
                    "Mode": "fail"
                },
                "Services": null,
                "Spreads": null,
                "Tasks": [
                    {
                        "Affinities": null,
                        "Artifacts": null,
                        "Config": {
                            "port_map": [
                                {
                                    "db": 6379.0
                                }
                            ],
                            "image": "redis:3.2"
                        },
                        "Constraints": null,
                        "DispatchPayload": null,
                        "Driver": "docker",
                        "Env": null,
                        "KillSignal": "",
                        "KillTimeout": 5000000000,
                        "Kind": "",
                        "Leader": false,
                        "LogConfig": {
                            "MaxFileSizeMB": 10,
                            "MaxFiles": 10
                        },
                        "Meta": null,
                        "Name": "redis",
                        "Resources": {
                            "CPU": 500,
                            "Devices": null,
                            "DiskMB": 0,
                            "IOPS": 0,
                            "MemoryMB": 256,
                            "Networks": [
                                {
                                    "CIDR": "",
                                    "Device": "",
                                    "DynamicPorts": [
                                        {
                                            "Label": "db",
                                            "To": 0,
                                            "Value": 0
                                        }
                                    ],
                                    "IP": "",
                                    "MBits": 10,
                                    "Mode": "",
                                    "ReservedPorts": null
                                }
                            ]
                        },
                        "Services": [
                            {
                                "AddressMode": "auto",
                                "CanaryTags": null,
                                "CheckRestart": null,
                                "Checks": [
                                    {
                                        "AddressMode": "",
                                        "Args": null,
                                        "CheckRestart": null,
                                        "Command": "",
                                        "GRPCService": "",
                                        "GRPCUseTLS": false,
                                        "Header": null,
                                        "Id": "",
                                        "InitialStatus": "",
                                        "Interval": 10000000000,
                                        "Method": "",
                                        "Name": "alive",
                                        "Path": "",
                                        "PortLabel": "",
                                        "Protocol": "",
                                        "TLSSkipVerify": false,
                                        "TaskName": "",
                                        "Timeout": 2000000000,
                                        "Type": "tcp"
                                    }
                                ],
                                "Connect": null,
                                "Id": "",
                                "Meta": null,
                                "Name": "redis-cache",
                                "PortLabel": "db",
                                "Tags": [
                                    "global",
                                    "cache"
                                ]
                            }
                        ],
                        "ShutdownDelay": 0,
                        "Templates": null,
                        "User": "",
                        "Vault": null,
                        "VolumeMounts": null
                    }
                ],
                "Update": {
                    "AutoPromote": false,
                    "AutoRevert": false,
                    "Canary": 0,
                    "HealthCheck": "checks",
                    "HealthyDeadline": 300000000000,
                    "MaxParallel": 1,
                    "MinHealthyTime": 10000000000,
                    "ProgressDeadline": 600000000000,
                    "Stagger": 30000000000
                },
                "Volumes": null
            }
        ],
        "Type": "service",
        "Update": {
            "AutoPromote": false,
            "AutoRevert": false,
            "Canary": 0,
            "HealthCheck": "",
            "HealthyDeadline": 0,
            "MaxParallel": 1,
            "MinHealthyTime": 0,
            "ProgressDeadline": 0,
            "Stagger": 30000000000
        },
        "VaultToken": "",
        "Version": 1
    }
}
```
</details>

另外，还可以通过“ job”命令执行各种操作，例如`run`, `stop`“运行”，“停止”以及其他用于启动和停止作业的命令，调用事件处理的`dispatch`“派遣”以及使用Canary进行促进工作的`promote`“促进”。使用它。

## monitor

`monitor`命令是获取Nomad代理日志的命令，当您要检查调试日志等时非常方便。 除非有异常，事件或操作，否则什么也不显示是正确的。

```console
$ nomad monitor -log-level=DEBUG
2020-02-01T23:38:02.316+0900 [WARN]  nomad: raft: Heartbeat timeout from "" reached, starting election
2020-02-01T23:38:02.316+0900 [INFO]  nomad: raft: Node at 127.0.0.1:4647 [Candidate] entering Candidate state in term 34
2020-02-01T23:38:02.353+0900 [DEBUG] nomad: raft: Votes needed: 1
2020-02-01T23:38:02.353+0900 [DEBUG] nomad: raft: Vote granted from 127.0.0.1:4647 in term 34. Tally: 1
```

也可以使用`-node-id`和`-server-id来缩小日志范围，并使用`-json`来输出JSON格式的日志。。

使用`Ctrl+C`退出。 由于在以下各章中将执行各种操作，因此可以将其保留并在另一个终端上进行操作。

## 其他命令


其他命令，例如`namespace`, `quota`や`sentinel`“名称空间”，“配额”和“前哨”仅适用于企业版。 请在“企业功能简介”幻灯片上检查此区域。

また`operator`コマンドに関しては[Consul Workshop](https://github.com/hashicorp-japan/consul-workshop/blob/master/contents/cli.md)具有相同机制的解释和过程。因此，如果您有兴趣，请尝试一下。

最后，让我们停止工作。

```shell
$ nomad job stop example
```

## 参考资料
* [nomad cli](https://www.nomadproject.io/docs/commands/index.html)