#Docker Commands: Camunda BPM Platform

Docker Commands: Camunda BPM Platform

The Docker cheatsheet for Camunda BPM Platform contains a list of the frequently used docker commands. This list includes commands to run, stop and start the docker container containing the Camunda BPM Platform. The cheatsheet does not provide an exhaustive list of all docker commands, for which you should refer to the official docker documentation page.

## Docker Hub & Camunda BPM Platform Images

Docker Hub is the default registry where Docker looks for images. There is a single Camunda BPM Platform image on Docker Hub.

>Camunda: The ***camunda/camunda-bpm-platform image*** is built and maintained by the Camunda BPM community. the image can be used to test and demonstrate the Camunda BPM platform. For more information, see Docker Hub.
Quick Commands
The following commands are all you need to get a docker container with the Camunda BPM Platform running. This examples also defines the container name and the port to expose on the host.

```shell
# Creates a container layer over the camunda bpm platform image and then starts it.
$ docker run -d --name camunda -p 8080:8080 camunda/camunda-bpm-platform:latest

# Fetches the logs of the container.
$ docker logs camunda

# Rest API: http://localhost:8080/engine-rest

# Browser: http://localhost:8080/camunda-welcome/index.html
# Username: demo
# Password: demo
```
 
## Docker Commands

The following sections contain a list of the most used docker commands with the Camunda BPM Platform image and container.

Container Lifecycle Commands
The docker run command runs a container named camunda using the camunda/camunda-bpm-platform:latest image. Here is a description of the options:

   - The --detach, -d option runs the container in background and print container ID.
   - The --env, -e option sets environment variables.
   - The --name option assigns a name to the container.
   - The --publish, -p option publishes a container’s port(s) to the host.

```shell
# Creates a container layer over the camunda bpm platform image and then starts it.
$ docker run -d --name camunda -p 8080:8080 camunda/camunda-bpm-platform:latest

# Removes one or more containers.
$ docker rm <container>
```

### Container Start & Stop Commands

The following commands are used to stop, start, restart and kill the docker container. The <container> operator identifies the container in three ways, UUID long identifier, UUID short identifier or name.

````shell
# Stops one or more containers.
$ docker stop <container>

# Starts one or more containers.
$ docker start <container>

# Restarts one or more containers.
$ docker restart <container>

# Kills one or more running containers.
$ docker kill <container>
````

### Container Info Commands

The following commands are used to obtain information about the docker container. The <container> operator identifies the container in three ways, UUID long identifier, UUID short identifier or name.

```shell
# Lists all the running containers. (Running Containers)
$ docker ps

# Lists all the running containers. (All Containers)
$ docker ps --all

# Fetches the logs of the container.
$ docker logs <container>

# Lists the port mappings for the container.
$ docker port <container>

# Displays a live stream of the container resource usage statistics.
$ docker stats <container>

```

### Container Executing Commands

The following command is used to run commands within the docker container. The <container> operator identifies the container in three ways, UUID long identifier, UUID short identifier or name.

```shell
# Runs a bash session inside the running container.
$ docker exec -it <container> bash
```

### Images Lifecycle Commands
The following commands are used to manage the lifecycle of a docker image.

```shell
# Shows all top level images, their repository and tags, and their size.
$ docker images

# Removes one or more images and can be used to remove the Camunda images with specific tags.
$ docker image rm <image>:<tag>
$ docker image rm camunda/camunda-bpm-platform:latest

# Removes one or more images and can be used to remove the Camunda images with specific tags.
$ docker rmi <image>
$ docker rmi camunda/camunda-bpm-platform:latest
```

### Images Info Commands
The following commands are used to provide information of a docker image.

```shell
# Shows the history of an image.
$ docker history <image>
$ docker history camunda/camunda-bpm-platform:latest
```

### Registry & Repository Commands
The following commands are used to navigate, search and retrieve images from the Docker Repository.

```shell
# Search the Docker Hub for images.
$ docker search <term>
$ docker search camunda

# Pulls the Camunda BPM Platform image.
$ docker pull camunda/camunda-bpm-platform:<tag>
$ docker pull camunda/camunda-bpm-platform:latest
```

### Docker Help
The following commands are used to get help via the command line.

```shell
# Information on the docker command itself.
$ docker --help

# Information on a specific docker command.
$ docker <COMMAND> --help
```

### Tags & Releases

The user has the choice between different application server distributions of Camunda BPM platform. ${DISTRO} can either be tomcat, wildfly or run. If no ${DISTRO} is specified the tomcat distribution is used.

 - latest, ${DISTRO}-latest: Alywas the latest minor release of Camunda BPM platform.
 - SNAPSHOT, ${VERSION}-SNAPSHOT, ${DISTRO}-SNAPSHOT, ${DISTRO}-${VERSION}-SNAPSHOT: The latest SNAPSHOT version of Camunda BPM platform, which is not released yet.
 - ${VERSION}, ${DISTRO}-${VERSION}: A specific version of Camunda BPM platform.

### Docker: Camunda BPM Platform Environment Variables

When you start the Camunda BPM Platform image, you can adjust the configuration of the Camunda instance by passing one or more environment variables on the docker run command line. The used database can be configured by providing the following environment variables:

- DB_CONN_MAXACTIVE the maximum number of active connections (default: 20), for tomcat, this is internally mapped to the maxTotal configuration property.
- DB_CONN_MAXIDLE the maximum number of idle connections (default: 20), ignored when app server = wildfly or run
- DB_CONN_MINIDLE the minimum number of idle connections (default: 5)
- DB_DRIVER the database driver class name, supported are h2, mysql, and postgresql:
    - h2: DB_DRIVER=org.h2.Driver
    - mysql: DB_DRIVER=com.mysql.jdbc.Driver
    - postgresql: DB_DRIVER=org.postgresql.Driver
- DB_URL the database jdbc url
- DB_USERNAME the database username
- DB_PASSWORD the database password

For more details, see the Camunda BPM Platform Docker Image documentation.

## Summary

Please feel free to share the Docker cheat sheet for Camunda BPM Platform commands with friends and colleagues. Follow me on any of the different social media platforms and feel free to leave comments.

24 Jul 2020

[source](https://www.javanibble.com/docker-commands-camunda-bpm-platform/)

