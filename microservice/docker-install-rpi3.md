## Introduction

I wrote this gist to record the steps I followed to get docker running in my Raspberry Pi 3. The ARM ported debian version (Jessie) comes with an old version of docker. It is so old that the docker hub it tries to interact with doesn't work anymore :)

Hopefully this gist will help someone else to get docker running in their Raspberry Pi 3.

## Installation

From original instructions at http://blog.hypriot.com/post/run-docker-rpi3-with-wifi/ 


`sudo apt-get install -y apt-transport-https`

`wget -q https://packagecloud.io/gpg.key -O - | sudo apt-key add -`

`echo 'deb https://packagecloud.io/Hypriot/Schatzkiste/debian/ wheezy main' | sudo tee /etc/apt/sources.list.d/hypriot.list`

`sudo apt-get update`

`sudo apt-get install -y docker-hypriot`

`sudo systemctl enable docker`

## Verifying your docker installation

Once installed run the following verifications.

### Confirm that we have the newest version of docker

`pi@raspberrypi:~ $ docker version`

      Client:
         Version:      1.10.3
         API version:  1.22
         Go version:   go1.4.3
         Git commit:   20f81dd
         Built:        Thu Mar 10 22:23:48 2016
         OS/Arch:      linux/arm
         Cannot connect to the Docker daemon. Is the docker daemon running on this host?


### Remove the error about the docker deamon by adding the current user (pi) to the docker group

`pi@raspberrypi:~ $ sudo usermod -aG docker pi`

NOTE: After this command, log out and log in as the pi user to refresh your session.

### Run ARM version of docker hello-world

`pi@raspberrypi:~ $ docker run armhf/hello-world`

      Unable to find image 'armhf/hello-world:latest' locally
      latest: Pulling from armhf/hello-world
      8c4f258b5966: Pull complete 
      Digest: sha256:bd9444c789932e7525c1f2a78ad2cf261fa4056048fc1ce24adde3b26835a089
      Status: Downloaded newer image for armhf/hello-world:latest
      
      Hello from Docker.
      This message shows that your installation appears to be working correctly.
      
      To generate this message Docker took the following steps:
       1. The Docker client contacted the Docker daemon.
       2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
       3. The Docker daemon created a new container from that image which runs the
          executable that produces the output you are currently reading.
       4. The Docker daemon streamed that output to the Docker client which sent it
          to your terminal.
      
      To try something more ambitious you can run an Ubuntu container with:
       $ docker run -it ubuntu bash
      
      Share images automate workflows and more with a free Docker Hub account:
       https://hub.docker.com
      
      For more examples and ideas visit:
       https://docs.docker.com/engine/userguide/

## Run an example application and confirm your Pi 3 docker instances are accessible from anywhere in the network.

`pi@raspberrypi:~ $ docker run -d -p 8081:8081 resin/rpi-google-coder`

Once the container is pulled and started, confirm that it's running 

`pi@raspberrypi:~ $ docker ps`

      CONTAINER ID        IMAGE                    COMMAND                  CREATED             STATUS              PORTS                  NAMES
      3a163325ba16        resin/rpi-google-coder   "/opt/node/bin/node s"   11 minutes ago      Up 10 minutes       0.0.0.0:8081->8081/tcp   sick_hugle

If you see the above output, our resin/rpi-google-coder container is runing. The app inside is a Node.js application, bound to port 8081 in our Raspberry Pi 3 host via port forwarding.

Now open a browser inside any computer on your network and go to ...

      https://<rpi ip address here>:8081  

Your browser should load the Coder Node.js application above. You might get an SSL certificate warning, since the URL is HTTPS and the certificate is self signed. 

## Accessing USB ports from your docker container

If you are like me, and want access to your Arduino from docker containers, run your container with elevated privileges as below.

`pi@raspberrypi:~ $ docker run -dti --privileged tyrell/control-things-from-the-internet:rpi-latest`

In the above instance, I'm running a container from my repository named tyrell/control-things-from-the-internet. rpi-0.1 is the TAG I used while commiting my docker image to the repository.

TIP: If you are testing a Dockerfile in your mac, before deploying to your RPi, follow https://medium.com/google-cloud/developing-for-arduino-with-docker-and-johnny-five-on-osx-cc6813ae6e9d#.gfuupc8mr to give VirtualBox access to USB ports.

## License
Copyright (c) 2016 Tyrell Perera <tyrell.perera@gmail.com>
Licensed under the MIT license.