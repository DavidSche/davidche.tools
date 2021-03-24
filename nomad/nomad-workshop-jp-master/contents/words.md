# 您想要保持最少的Nomad词汇表

Nomad超越了像Docker这样的容器工作负载，可以运行各种类型的应用程序，例如独立的Java，RaW Exec和Qemu。

为此，Nomad声明性地做出了各种定义，但是在这里，我们将总结至少在部署实际应用程序之前需要理解的术语，这些应用程序将在接下来的章节中进行介绍。

没有动手工作，因此请在继续操作之前先阅读它。

## Nomad Job定義

Nomad的Job大致分为三层：“工作”，“任务组”和“任务”。 `Job`, `Task Group`, `Task`。

* Job
	* Nomad 部署到Nomad的应用程序在称为Job的单元中定义。作业定义了`desired status`即应用程序的期望状态。以下是典型定义的示例
		* 运行的位置（数据中心的位置，区域的位置）
		* 它是什么类型的工作（批处理或长时间运行的流程）(Batch or Long Running Process)
		* 移动什么
		* “如何”更新工作
	* Job在Job上运行的应用程序的详细设置包括以下任务组 Task Group 。
* Task Group
	* Job 可以在一个作业Job中定义多个作业组Task Group。在任务组Task Group中进行了以下定义。
		* Restart: 重新启动策略
		* Count: 要同时运行的任务数
		* Task: 实际任务的定义。下面是更详细的任务定义
* Task
	* Task Group可以在任务组中定义，并且可以在一个任务组Task Group中定义多个任务。在Task中进行以下定义。。
		* Driver:驱动程序：指定应用程序类型。 （java，docker，exec等）(java, docker, exec etc)
		* Config: 运行每个驱动程序的配置。对于Java，请指定jar路径和JVM选项，对于Docker，请指定端口映射Port Mapping。
		* Resouce: 资源：指定要分配给任务的CPU，内存，网络CPU, Memory, Network等。
	
在实际部署应用程序之前，这些定义以诸如`HCL`或`JSON`之类的格式定义，并在部署应用程序时设置为`nomad`命令的参数。 Nomad服务器将对其进行解释，然后按声明将应用程序部署到Nomad客户端。

接下来，我将总结Nomad服务器执行的内部处理的条款。

## Nomad的内部处理

Nomad的调度流程如下。

![](https://www.nomadproject.io/assets/images/nomad-data-model-39de5cfc.png)

在这里，我们将简要说明每个过程。

* Evaluation 评估
	* 当状态由于有意和无意的更改而更改时运行并在Nomad服务器上运行的进程。当发生新作业，更新现有作业，更改所需（Desired）等或发生意外更改（例如故障）并将状态更新为“所需状态”时，将创建该文件。评估将排队到服务器端的评估代理 Evaluation Broker，并由调度程序出队。
* Allocation 分配
	* 当一项任务中正在运行成百上千个任务时，决定要处理的节点非常重要。调度程序创建的用于实际处理评估过程的过程，该过程确定哪个作业在哪个节点上运行。调度程序获得评估后，将生成一个分配计划Applocation Plan。分配计划分为两个阶段。
		* Cheking: 检查“是否存在不正常的节点？”的阶段：“是否存在没有驱动程序的节点来运行任务中定义的工作负载？”
		* Ranking: 对任务执行的最佳节点进行排名的阶段。根据`Bin Packging`“装箱”结果评分。
	* Allocation Plan 在分配计划中排名后，排名较高的节点将分配给分配计划。节点检索排队的分配，并执行实际任务。。
* Bin Packing 装箱
	*  优化节点上的资源利用率和应用程序密度的过程。这样做是为了优化运行工作负载的节点上的放置和资源分配，并提高总体基础架构成本。

在这里，我们将简要说明每个过程。

## 参考资料
* [Nomad Architecture](https://www.nomadproject.io/docs/internals/architecture.html)
* [Nomad Scheduling](https://www.nomadproject.io/docs/internals/scheduling/scheduling.html)
* [Nomad Job Specification](https://www.nomadproject.io/docs/job-specification/index.html)