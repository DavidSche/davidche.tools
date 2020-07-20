# docker-swarm-cheat-sheet

## 概述

A swarm consists of multiple Docker hosts which run in swarm mode and act as managers (to manage membership and delegation) and workers (which run swarm services).

### swarm 命令	

| **命令** | **说明**  |
| ----------|------------------ |
| docker swarm init	| initialises a new docker swarm |
| docker swarm join –token	| join a worker node to an existing swarm |
| docker swarm leave	| leave the swarm |
| docker swarm init –autolock	| enables autolock on the swarm |

### 应用栈命令	

| **命令** | **说明**  |
| ----------|------------------ |
| docker stack deploy |	used to deploy a new stack |
| docker stack ls |	lists all the stacks and services that make up the stacks |
| docker stack services |	list the services in a given stack |
| docker stack ps |	list all the tasks for a given stack |
| docker stack rm |	removes the stack |

### 服务命令

| **命令** | **说明**  |
| ----------|------------------ |
| docker service create –replicas 5 -p 80:80 –name web nginx	|	creates a new docker service, based on nginx image with 5 replicas	|
| docker service logs	|	outputs the logs of a service	|
| docker service ls	|	lists all the services in the swarm	|
| docker service rm	|	deletes a service	|
| docker service scale	|	used to add or remove replicas from a service	|
| docker service update	|	used to update a service with a new image	|

### 节点命令

| **命令** | **说明**  |
| ----------|------------------ |
| docker node ls	| lists the docker nodes in a swarm	|
| docker node ps	| lists the tasks on a docker node	|
| docker node rm	| removes a node from the swarm	|
| docker node demote	| demotes a manager node	|
| docker node promote	| promotes a node to swarm manager	|

### docker swarm 网络命令	

| **命令** | **说明**  |
| ----------|------------------ |
| docker network ls	| lists networks	|
| docker network create -d overlay network_name	| create overlay network	|
| docker network rm network_name	| remove network	|


### 关键 概念	

| **关键字** | **说明**  |
| ----------|------------------ |
| Node | A physical or virtual machine on which docker is running |
| Manager |	Performs swarm management and orches­tration duties. Also acts as a worker node by default |
| Worker |	Runs Docker Swarm tasks |
| Swarm Cluster | A group of Docker nodes working together |
| Stack | A collection of services that typically make up an application |
| Service |	When you create a service, you define its optimal state (number of replicas, network and storage resources available to it, ports the service exposes to the outside world, and more). |
| Task | Services start tasks. A task is a running container which is part of a swarm service and managed by a swarm manager, as opposed to a standalone container. |

### swarm 特性	

| **关键字** | **说明**  |
| --------|-------------------- |
| cluster management |	fully integrated with the docker engine. No additional software required for docker swarm mode |
| decentralized design |	You can deploy both kinds of nodes, managers and workers, using the Docker Engine.  |
| declarative service model |	Docker Engine uses a declarative approach to let you define the desired state of the various services in your application stack. |
| scaling |	For each service, you can declare the number of tasks you want to run. |
| desired state |	The swarm manager node constantly monitors the cluster state and reconciles any differences. |
| multi-host networking |	You can specify an overlay network for your services. |
| service discovery |	Swarm manager nodes assign each service in the swarm a unique DNS name |
| load balancing |	You can expose the ports for services to an external load balancer. |
| rolling updates |	If anything goes wrong, you can roll back to a previous version of the service. |



## Locking and Unlocking a Docker Swarm

When the Docker daemon restarts, the TLS key used to encrypt communication between the swarm nodes 
and the key used to encrypt and decrypt Raft logs on disk, are loaded into each manager node’s memory. 
Docker allows us to protect these keys by allowing us to take ownership of them and to require manual unlocking of the swarm manager node. 
This is the docker swarm autolock feature. This article will cover how to enable the autolock feature and how to unlock the swarm cluster.

###Article Contents

- Enabling Autolock when Creating a New Docker Swarm
- Enabling Autolock on an Existing Docker Swarm
- Testing the Autolock Feature
- Unlocking a Docker Swarm
- Viewing the auto lock key
- Rotating the Swarm Unlock Key
- Disable Auto lock


#### Enabling Autolock when Creating a New Docker Swarm

When creating a new docker swarm, autolock can be enabled by including it in the docker swarm init command. 

For example:

```shell script
$ docker swarm init --autolock
```

The unlock key will be included in the output from the command:

```shell script
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-WdfH/IX284+lRcXuoVfejiow33HJEKY13MIHX+tTt8
```

Ensure the key is stored in a very safe place, such as your password repository. 
It will be needed when the docker manager restarts and you then need to unlock the swarm.

#### Enabling Autolock on an Existing Docker Swarm

You can also enable autolock on an existing docker swarm. 
To do so you would run the following on a swarm manager node:

```shell script
$ docker swarm update --autolock=true
 Swarm updated.
 To unlock a swarm manager after it restarts, run the docker swarm unlock
 command and provide the following key:

```

Once again, ensure you store the unlock key safely!

#### Testing the Autolock Feature

On my test system, I will restart docker, with the autolock feature enabled:

```shell script
$ sudo service docker restart
```

Now if we try to list docker services there is the following message:

```shell script
$ docker service ls
Error response from daemon: Swarm is encrypted and needs to be unlocked before it can be used. Please use "docker swarm unlock" to unlock it.
We now need to unlock the swarm before it is usable.
```

#### Unlocking a Docker Swarm

A docker swarm can be unlocked using the docker swarm unlock command:
```shell script

ker swarm unlock
 Please enter unlock key: 
```

Once unlocked, docker service commands can be ran as before.

#### Viewing the auto lock key

On an unlocked swarm manager node you can view the unlock key by running the docker swarm unlock-key command
```shell script

$ docker swarm unlock-key
To unlock a swarm manager after it restarts, run the docker swarm unlock
command and provide the following key:
 SWMKEY-1-Ueyx3eHnHexgQNXQNVyHHA7ea2G5GCxYUPpmxQ+TfrQ 

```
Please remember to store this key in a password manager, since without it you
 will not be able to restart the manager.
Rotating the Swarm Unlock Key
You can rotate the unlock key by using the following command:

$ docker swarm unlock-key --rotate
Be sure store the new key safely. It’s also recommended to keep a note of the old key for a little while, if you have multiple manager nodes, to ensure all managers have the new key.

Disable Auto lock
Finally, if you wish to disable the auto-lock feature then you can do so, on an unlocked manager node, with the following command:

$ docker swarm update --autolock=false
Don’t forget to check out the official documentation on this feature, which can be found here.

Learning Docker?
If you are starting out, then I highly recommend this book. Thirsty for more?

Then it’s time to take your Docker skills to the next level with this book (It’s my favorite). Also, check out my page on Docker Certification. 

### 更多详情

[swarm官方文档](https://docs.docker.com/engine/swarm/)
[services官方文档](https://docs.docker.com/engine/swarm/how-swarm-mode-works/services/)
[文章出处](https://buildvirtual.net/docker-swarm-cheat-sheet/)

