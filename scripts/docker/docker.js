Help
	$ docker --help
	$ docker image --help
	$ docker image ls --help

Versions
	See the Docker version
		$ docker --version
	See the Docker client and server versions
		$ docker version

List
	docker image ls
	docker container ls
	docker network ls
	docker volume ls

Delete
	docker image rm -f $(docker image ls -q)
	docker container rm -f $(docker container ls -a -q)
	
docker
	info
	--help
	system df
		to see space usage
	system prune
		to remove dangling (not associated to a container) images, containers, volumes, and networks
		-a
			also remove stopped resources
	search [keyword_to_search_in_repository_registry]
		To find an image. Same as doing it from https://hub.docker.com
	login
		To login to your Docker.com account

IMAGES
An image is every file that makes up just enough of the Operating System to perform a task.
The Dockerfile provides the instructions to build a container image using the 'build' command.
It starts from a previously existing Base image (through the FROM clause) followed by any other needed Dockerfile instructions.

$ docker image...
	ls
		list all images
	pull [image_name]
		downloads image to local repo. This is done automatically when you 'docker container run...'
			e.g. docker image pull centos:latest
	history [image_name]
		show history of image changes or additions
	inspect [image_name]
		see all configurations and properties
	tag [image_name] [new_image_name]
		associates a new tag to an existing tag
		e.g. $ docker image tag old_name:old_version new_name:new_version
	push [image_name]
		pushes image to Docker Hub
			e.g. docker image push percyvega/nginx



CONTAINERS
The image at runtime; it''s a process. There can be multiple containers of the same image.
Use an image and creates from it a container with a running process.
$ docker container...
	ls
		list all running containers
		-a
			list all running and non-running containers
		-l
			list the last container run
	commit [container_name] [[image_name:image_tag]]
		creates a new image from a container
	start [container_name]
		start an existing container currently stopped
	stop [container_name]
		stop a container gracefully (if that doesn't work after a few seconds, then forcefully)
		crtl + d
			if you are inside the main process, this will stop the container (same as exit in bash)
	kill [container_name]
		stop a container forcefully
	attach [container_name]
		jump into the main process of the container
		ctrl + p, ctrl + q
			to detach (jump out) of the container without stopping it
	exec -ti [container_name] [[process_to_run]]
		connect to a running container and execute a (non-main) process
		e.g. exec -ti [container_name] bash
	rm [container_name]
		remove a container that is not running
		-f
			remove a container forcefully (even if it’s running)
	logs [container_name]
		look at logs
		-f
			look at logs by tailing them
	inspect [service_id]
		see all configurations and properties
		--format <json path>
			to find a specific value
				e.g. docker inspect --format '{{.State.Pid}}' percy_new
	stats [container_name]
		see usage statistics of the container

$ docker container run [image_name] [process_to_run]
	creates a new container from an image and runs it
		e.g.	$ docker container run -ti [image_name] bash
				$ docker container run -d -ti [image_name] bash
				$ docker container run --rm -ti [image_name] bash -c "sleep 5; echo all done"
	image_name
		name of the image from which the container will be created
	process_to_run
		name of the process to execute. This is the main process of the container.
		The container will stop as soon as this specific process stops.
	--rm
		Delete the container when its main process stops.
	-tiss
		For manually running commands.
		terminal interactive, tty (-t, terminal on foreground) and interactive mode (-i)
	-d
		detached mode; to leave the container running in the background instead of hanging the terminal until exit.
	--name [container_name]
		give this container a specific name
	-P [external_port:internal_port]
		the container will expose its internal port to the external port
		if external_port is not specified, Docker randomly chooses one available.
		To show the port for a running container, you can enter:
			$ docker ports [container_name]
	--privileged=true
		to turn off some of the Docker security features
	--pid=host
		to turn off even more of the Docker security features

Volumes:
	Two main varieties: Persistent and Ephemeral.
	Volumes are not part of images.
	Shared container resourse (folders or files) are created automatically.
	Sharing persistent data between host and containers
		Ensure specified host folders and files exist before mapping.
		Specified container folders and files will be created if they don't exist.
			e.g. docker container run -ti -v [host_file_path]:[container_file_path] [image_name] [process_to_run]
				docker container run -ti -v [host_folder_path]:[container_folder_path] [image_name] [process_to_run]
	Sharing ephemeral data between containers
		Shared "disks" that exist only until the last container uses it.
			e.g. docker container run -ti -v [container_folder_path] [image_name] [process_to_run]
				then the other containers have to run
					docker container run -ti --volumes-from [the_other_container_path] [image_name] [process_to_run]
Networking:
	Programs in container are isolated from the internet by default.
	You can group your containers into "private" networks.
	You explicitly choose who can connec to whom.
	Use host.docker.internal to refer to the container's hosting pod.
	$ docker network
		ls
			will show the networks created by default to be used by containers
				- bridge: by default
				- host: that need to access the host's networking stack; turns off all the protections
				- none: with no network at all
		create [network_name]
			this will create a network to which containers will be able to connect
				$ docker container run --rm -ti --net [network_name] ubuntu bash
					this container will join a network with name [network_name]
		connect [network_name] [container_name]
			will make [container_name] join the [network_name] network
DOCKERFILES (Dockerfile)
A Dockerfile is a simple text file that contains a list of commands that the Docker client calls while creating an image.
Each line in the Dockerfile file is its own call to `docker run...` and then its own call to `docker commit...`.
Each command takes the image from the previous line and makes another image.
If you need to have one program start and then another program start, they ned to be on the same line, so that they are in the same container.
Environment Variables persist across lines if you use the ENV command to set them.
Processes you start on one line will not be running on the next line.
It's a simple way to automate the image creation process.
Commands:
	FROM [image_name]
		the image to start with. Must be the first command.
			e.g. FROM ubuntu
	RUN
		to run a command through the shell.
			e.g. RUN unzip install.zip /opt/install/
				RUN echo hello docker
	CMD
		in the newly created image, run a command when the image is started.
			e.g. CMD java -jar /deployments/myapp-1.0-SNAPSHOT.jar
		replaced if a command is specified at the end of docker run [image_name]...
	ADD
		used to add a local file to the container.
			e.g. ADD run.sh /run.sh
		add the contents of a tar archive (uncompressed)
			e.g. ADD PromiseRejectionEvent.tar.gz /install/
		add the contents of a URL
			e.g. ADD https://download-files.com/percy.mp3 /music/
	ENV
		add environment variables to both the Dockerfile and to the resulting image.
			e.g. DB_PORT=5432
	ENTRYPOINT
		the command to run when the container runs
		allows for the user to specify arguments to this entry point by appending them after docker run [image_name]...
	EXPOSE
		maps ports itto a container
			e.g. EXPOSE 8080
	VOLUME
		defines shared or ephemeral volumes
			e.g. VOLUME ["/host/path/" "/container/path/"]
				VOLUME ["/shared-data"]
	WORKDIR
		sets the directory the container starts in
			e.g. WORKDIR /install/
	USER
		sets which user the container will as
			e.g. USER percy
				USER 1000

e.g. docker image build -t [name_of_image_to_create] .
		executes the Dockerfile in this directory and creates an image created using the recipe
		Create an image with a tag name and a context (i.e. current directory)
			e.g. $ docker image build -t helloworld:1.0 .

 
FROM ubuntu as builder
RUN apt-get update
RUN apt-get -y install curl
RUN curl https://google.com | wc -c > google-size
ENTRYPOINT echo google is this big; cat google-size
# then build with: docker build -t hellojava .
# then run with: docker container run --rm -ti hellojava bash
	
FROM debian
RUN apt-get -y update
RUN apt-get install nano
CMD ["bin/nano", "/tmp/notes"]
# then build with: docker build -t nanoer .
# then run with: docker container run --rm -ti nanoer

FROM nanoer
CMD ["touch", "notes.txt"]
CMD "nano" "/notes.txt"

FROM example/nanoer
ADD notes.txt /notes.txt
CMD "nano" "/notes.txt"
# file notes.txt must exist in the host's current folder


FROM jboss/wildfly
COPY webapp.war /opt/jboss/wildfly/standalone/deployments/webapp.war

FROM openjdk:alpine
COPY myapp/target/myapp-1.0-SNAPSHOT.jar /deployments/
CMD java -jar /deployments/myapp-1.0-SNAPSHOT.jar




DOCKER COMPOSE (docker-compose.yml)
Docker Compose is a tool for defining and running multi-container applications.
The context of all operations is the default: current folder name context.

docker compose...
	up
		Start docker compose
	up -d
		Start docker compose in detached mode
	-f docker-compose.yml up
		Start docker compose with a non-default docker-compose.yml file
	-p non-default-context up
		Start docker compose with a non-default context
	ls
		List name and status of docker compose components
	ps
		List information for all docker compose components
	logs -f
		Look at all logs by tailing them
	down
		Shutdown all services


version: "3.9"
services:
    web:
        image: "jboss/wildfly"
        volumes:
            - ~/deployments:/opt/jboss/wildfly/standalone/deployments
        ports:
            - "8080:8080"


version: "3.9"
services:
	web:
		image: "arungupta/couchbase-javaee:travel"
		environment:
			- "COUCHBASE_URI=db"
		ports:
			- "8080:8080"
			- "9990:9990"
		depends_on:
			- "db"
	db:
		image: "arungupta/couchbase:travel"
		ports:
			- "8091:8091"
			- "8092:8092"
			- "8093:8093"
			- "11210:11210"

docker-compose.override.yml
version: "3.9"
services:
    web:
        ports:
            - "80:8080"




DOCKER SWARM
Is an orquestration system to manage a cluster of application services

A Swarm Manager (e.g. a Service of 3 nginx replicas) orquestrates
	3 Nodes (each, a nginx Task composed of a nginx container)

e.g. docker stack deploy -c example-voting-app-stack.yml voteapp

docker
	swarm init
		to start swarm
	swarm leave
		to stop swarm
	node
		ls
			list all nodes
	service
		ls
			list all services
		ps [service_name]
			see service tasks and containers
		create [image] [command]
			create a new service
			e.g. docker service create ping 8.8.8.8
			e.g. docker service create --name vote -p 80:80 --network frontend nodejs
		update [service_id]
			--replicas 3
				will try to reach 3 simultaneous tasks
		inspect [service_id]
			see all configurations and properties
		--name [name]
			name of the service
		--network [network_name]
			join this network
		--replicas [number]
			number of replicas
		-p [localPort:containerPort] | --publish ...
			channels a local (host) port to a container port
	stack
		deploy
			deploy a group of services
		services [application_name]
			display services
		ps [application_name]
			display tasks