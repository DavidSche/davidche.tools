# DOCKER NOTES

#### Basic Commands:

- Get a docker image
``` bash
docker image pull <docker-image-path>
```

- List docker images
```bash
docker image ls
```

- Instantiate a image
``` bash
docker container run -p <external-portnumber>:<internal-portnumber> <image-name>

# p: Stands for publish, if P is not mentioned, it will not expose the port.
```
- Connect the container to the terminal
``` bash
docker container run -it ubuntu

# it: Interactive command. It connects the container to the terminal.
```
- Detached execution of a container
```bash
docker container run -d -p 80:8080 <image-name>

# d: Means detached (in background)
```

- Verify running containers
```bash
# For docker in Windows 10
docker container ls
docker container ls -a

# For docker toolbox
docker-machine ip
```
- Stop a running container
```bash
docker container stop <container-id>
```

- Get other images (based on dockerhub images)
```bash
docker pull ubuntu
#or
docker image pull ubuntu
#both are the same command.
```
- Verify docker processes
```bash
docker ps
docker ps -a
```

- Starting a stopped container
```bash
docker container start <container-id>
```

- Attach by ID and Name
```bash
docker attach 665b4a1e17b6 # By ID
docker attach loving_heisenberg # By Name
```

- Removing containers
```bash
docker container rm <container-id> # Removing a specific container
docker container prune # Removing all containers
```

- Logs from Docker Containers
```bash
docker container logs <container-id>
```

- SSH executions
```bash
docker container exec <container-id> bash
docker container exec -it <container-id> bash
```

## CREATE A NEW DOCKER IMAGE WITH JDK INSTALLED IN IT
###### STEPS
```bash
docker image ls
docker container run -it ubuntu (connected to its terminal)
apt-get update
apt-get install # We can use the command line to install JDK, but sometimes we may not know about the correct package, so we can proceed in another way.
apet-cache search jdk # before executing install
                      # Choose one option from the list
apt-get install -y openjdk-8-jdk
javac # For verifying that java is installed.
exit
docker container ls # For verifying that no containers are running.

# -----------------------------------------------------------------
# Now we will create a new image from our current state: docs.docker.com for more information.
# -----------------------------------------------------------------

docker container commit [many-parameters]
docker container commit -a "Franco Arratia franco.robert.fral@gmail.com" <container-id> <new-image-name>

# -----------------------------------------------------------------
# If the image will not be published to dockerhub, the image name my-jdk-image will be helpful locally.
# -----------------------------------------------------------------

docker image ls
docker container prune # Remove all unused containers
docker container run -it <my-new-image-name>


# -----------------------------------------------------------------
# Once executed, we should able to verify the java version that we have installed in previous steps.
# -----------------------------------------------------------------
```

## DOCKER FILES
A docker file is a set of instructions that tell docker how to build your container image as a very simple but powerful syntax that you will use to create and combine binary artifacts in order to generate your desired end result.

###### DOCKER FILE SYNTAX
```dockerfile
FROM image-name:tag
Uses the named image as the starting point for creating your own.
ADD some-file-on-host some-path-inside-container
COPY some-file-on-host some-path-inside-container
Use ADD and COPY to load your container with your required files.
RUN <some command(s)>
Use run to execute commands within the container.
CMD ["command", "parameters"]
Use CMD as an entry point command to initially launch your application. Such as "catalina.sh run"
VOLUME some-folder-between-the-container

Use WORKDIR to switch within folders, between the container as you execute ADD, COPY, RUM, commands as needed.
```

###### STEPS

```dockerfile
FROM ubuntu:latest
MAINTAINER Franco Arratia "contact@mail.com"
RUN apt-get update && apt-get install -y openjdk-8-jdk
CMD ["/bin/bash"]
```

```bash
# For creating an image from dockerfile:

docker image build -t jdk-image-from-dockerfile .
# -t: give a name
# Example: -t <some-name> <location>

docker container run -it jdk-image-from-dockerfile
# Java should be installed there.
```

###### EXECUTING A JAR FILE

```dockerfile
FROM ubuntu:latest
MAINTAINER Franco Arratia "contact@mail.com"
RUN apt-get update && apt-get install -y openjdk-8-jdk
WORKDIR /usr/local/bin/
COPY myjarfile.jar .
CMD ["/bin/bash"]
```

```dockerfile
FROM ubuntu:latest
MAINTAINER Franco Arratia "contact@mail.com"
RUN apt-get update && apt-get install -y openjdk-8-jdk
WORKDIR /usr/local/bin/
COPY myjarfile.jar .
CMD ["java", "-jar", "jarfile.jar"] # Here we need to add the command we need to execute
```

###### RUN IMAGE BUILD

``` bash
docker image build -t jdk-image-from-dockerfile .
```
It is necesary to add the dot (.) as a parameter. We just need a dot there to say we are working in this folder.

Docker files will only take into account the files that are located in the current folder (. parameter means current) and subfolders from the current location.

When executing this with the latest version of docker until April 2sd, 2019. I got the following error message: 

```bash
Get https://registry-1.docker.io/v2/library/ubuntu/manifests/latest: unauthorized: incorrect username or password
```

This was solved by executing: ```docker logout```

###### EXECUTE THE CONTAINER

```bash
docker container run -it <docker-image-name>
# -it: interactive does not kill the process when pressing CTRL+C

# If the container has been stopped, re execute it with the following command.
docker container start <container-id>
```
```
# For starting stopped containers:
docker container start <container-id>

# For reviewing the logs: It also shows the standart System.out. messages.
docker container logs -f <container-id>

# For stopping the execution of a container
docker container stop <container-id>
```

###### COPY vs ADD

COPY: 
ADD: Has some extra features, for example it can work with remotes URLs, it can also do things like unzipping, unpacking archives. Now therefore it looks like ADD is generally more useful and flexible but in fact the docker peope seems to recommend that copy is preferred because it is just simpler and is more obvious what copy is going to do. 

However if you use add I just wanted to mention in case you think we are missing something by not using ADD.

ENTRYPOINT: Is very similar to CMD command. The difference is that we can not override the execution commands. But there are quite significant differences. EntryPoints will always run whereas CMD is just a default.

When we are using CMD, we can change the execution command when running the container as follows

```bash
docker container run -it jdk-image-from-dockerfile /bin/bash
# The previous command will execute the bash of the OS.
```


## CHAPTER 7 -  TOMCAT APPLICATION
###### SETTING UP THE IDE

Run as: arguments:
-Dspring.profiles.active=development

###### TOMCAT BASE IMAGE

```dockerfile
FROM tomcat:9.0.17-jre8-alpine
MAINTAINER Franco Arratia "franco.robert.fral@gmail.com"
CMD ["catalina.sh", "run"]
```

```bash

docker image build -t <some name> .

docker container run -it <docker image>
docker container run -p 8080:8080 -it <docker image>
```


###### Removing the default webapps

```dockerfile
FROM tomcat:9.0.17-jre8-alpine
MAINTAINER Franco Arratia "franco.robert.fral@gmail.com"
EXPOSE 8080
CMD ["catalina.sh", "run"]
```

We need to expose the port if we need to use a port in a container. But we may not need to do that in this case, since the docker files inherits the configuration from parent ones.

At the end, it may be useful and informative to who that is going to see our docker files.

```bash
docker container run -p 80:8080 -it <docker image>
docker container run -p 80:8080 -d <docker image>

# -d: Detached mode 

docker container exec -it <container-id> /bin/bash
docker container exec -it <container-id> /bin/sh
```

Previous commands will depend on image of OS and version.

```dockerfile
FROM tomcat:9.0.17-jre8-alpine
MAINTAINER Franco Arratia "franco.robert.fral@gmail.com"
EXPOSE 8080
RUN rm -rf /usr/local/tomcat/webapps/*
CMD ["catalina.sh", "run"]
```

```bash
docker container stop <container-id>
docker image build -t <some name> .
docker container run -p 80:8080 -d <docker image> 

[docker container exec -it <container-id> /bin/bash
# or
docker container exec -it <container-id> /bin/sh]

docker container stop <container-id>
```

How to See Memory and CPU Usage for All Your Docker Containers (on CentOS 6)
rubberduck profile image Christopher McClellan  Jul 22 '17 ・2 min read

#docker
Originally posted on my blog.

I run a bunch of Docker containers on a single CentOS 6 server with a limited amount of memory. (I only recently bumped it from 0.5 to 1 whole whopping gig!) Before I bring another container online, I like to check to see how much room I've got. Being the newest versions of Docker aren't available for CentOS 6, I'm running an ancient version, 1.7 or so. On the new versions of Docker, running docker stats will return statistics about all of your running container, but on old versions, you must pass docker stats a container id. Here's a quick one-liner that displays stats for all of your running containers for old versions.

```
$ docker ps -q | xargs  docker stats --no-stream

CONTAINER           CPU %               MEM USAGE/LIMIT     MEM %               NET I/O
31636c70b372        0.07%               130.8 MB/1.041 GB   12.57%              269.7 kB/262.8 kB
8d184dfbeeaf        0.00%               112.8 MB/1.041 GB   10.84%              45.24 MB/32.66 MB
a63b24fe6099        0.45%               50.09 MB/1.041 GB   4.81%               1.279 GB/1.947 GB
fd1339522e04        0.01%               108.2 MB/1.041 GB   10.40%              8.262 MB/23.36 MB
```

docker ps -q returns the list of running container ids, which we then pipe through xargs and into docker stats. Adding --no-stream gives us just the first result instead of continually updating the stats, but this works just fine without it.

It’s a neat little trick. If anyone knows how to make this return container names instead of ids, please comment below.

Again, this is unnecessary for the newest versions. Just run docker stats and you'll get nearly identical output.










