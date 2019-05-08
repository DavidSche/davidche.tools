# Docker cheatsheet

![Docker](https://www.docker.com/sites/default/files/social/docker_twitter_share.png)

## Terminology 

Image -> Container (called Task if it's in a Service) -> Service -> Stack -> Swarm

- **[Image](https://docs.docker.com/glossary/?term=image)**: An ordered collection of root filesystem changes and the corresponding execution parameters for use within a container runtime. Portable Docker images are defined by something called a `Dockerfile`. 
- **[Container](https://docs.docker.com/glossary/?term=container)**: A container is a runtime instance of a docker image.
- **[Service](https://docs.docker.com/glossary/?term=service)**: A service is the definition of how you want to run your application containers in a swarm (a.k.a.: containers in production). At the most basic level a service defines which container image to run in the swarm and which commands to run in the container. To define, run, and scale services just write a `docker-compose.yml` file.
- **[Task](https://docs.docker.com/glossary/?term=task)**: A single container running in a service is called a task.
- **[Swarm](https://docs.docker.com/glossary/?term=swarm)**: A swarm is a group of machines that are running Docker and joined into a cluster.
- **[Node](https://docs.docker.com/glossary/?term=node)**: The machines in a swarm can be physical or virtual. After joining a swarm, they are referred to as nodes.

## Images and containers

Reference: [Dockerizing a Node.js web app](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)

| Command | Description |
| - | - |
| `docker image ls` | List images in the local registry |
| `docker build -t username/repo:tag .` | Build Docker image | 
| `docker images` | List images |
| `docker run -p 49160:8080 -d username/repo:tag` | Run image |
| `docker ps` | List containers |
| `docker stop containerId` | Stop running container |
| `docker push username/repo:tag` | Push image to Docker Hub |

## Services and tasks

Reference: [Get Started, Part 3: Services](https://docs.docker.com/get-started/part3/)

| Command | Description |
| - | - |
| `docker swarm init` | Initialize a swarm | 
| `docker stack deploy -c docker-compose.yml appname` | Deploy a new stack or update an existing stack |
| `docker stack rm appname` | Take stack down |
| `docker swarm leave --force` | Take swarm down | 
| `docker service ls`| List services |
| `docker service ps getstartedlab_web` | List tasks |

## Swarms

Just remember that only swarm managers like myvm1 execute Docker commands; workers are just for capacity. Let's deploy the app on a swarm cluster.

| Command | Description |
| - | - |
| `docker swarm init` | Initialize a swarm | 
| `docker-machine create --driver virtualbox myvm1` | Create a Virtual Machine | 
| `docker-machine ls` | List Virtual Machines | 
| `docker-machine ssh <myvm1> "docker swarm init --advertise-addr <myvm1 ip>"` | Command VM to become a swarm manager | 
| `docker-machine ssh myvm1 "docker node ls"` | List nodes in the swarm managed by myvm1 |
| `docker swarm leave` | Leave swarm (node) |
| `docker-machine env myvm1` | Get command to configure shell to talk to VM |
| `eval $(docker-machine env myvm1)` | Configure shell to talk to VM (macOS) |
| `docker stack deploy -c docker-compose.yml appname` | Deploy the app on current machine (VM) |
| `docker stack ps appname` | List tasks |
| `eval $(docker-machine env -u)` | Unset `docker-machine` environment vars in current shell |
| `docker-machine start <machine-name>` | Restart machine | 
| `docker swarm join-token worker` | Get join-token of current swarm for workers (issued by manager |


docker swarm init --advertise-addr 192.168.9.10


