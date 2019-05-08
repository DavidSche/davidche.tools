# Docker swarm cluster on raspberry pi's
The goal is to create a very cheap docker cluster for the home environment, but still is capable of running multiple docker services. The idea is to use raspberry pi 3 B+ units. These small computers have a 1,4 GHz quadcore ARM cortex A53 soc and 1GB of memory. This should be sufficient to run [pi-hole](https://pi-hole.net), [home-assistant](https://github.com/home-assistant) and [wordpress](https://www.wordpress.com) websites.

## Requirements
- [2 or more raspberry pi 2/3 B/B+](http://www.voc-electronics.com/a-51822614/raspberry-pi/raspberry-pi-3-model-b/)
- 2 or more 2.5A micro-usb powersupplies
- 2 or more 8GB or bigger mirco sdhc cards
- [HypriotOS image](https://blog.hypriot.com/downloads)
- [Etcher sdcard flasher](https://etcher.io)
- (optional): 5 or more ports 100/1000Gbit switch
- (optional): 3 or more ethernet network patch cables

## Flashing sd cards
Because the flash procedure can vary with the version of HypriotOS it is best to follow their [getting started with hypriot](https://blog.hypriot.com/getting-started-with-docker-on-your-arm-device/).

This image is customizable for headless deployment. And you may change setting of /boot/user-data. But do this before the first boot of the raspberry pi.

## Configuration of the cluster
### Network and hostnames
```
192.168.99.100 -> swarm-manager01.example.com
192.168.99.101 -> swarm-worker01.example.com
192.168.99.102 -> swarm-worker02.example.com
```

### Configuration of swarm-manager01.example.com
swarm-manager01.example.com is the docker swarm manager, this node will allow you to use the docker swarm as a single docker instance. In this case we have only one manager node, but the more raspberry pi's you use the more managers you could add to the cluster. if you have 5 raspberry pi's it's recommend to use 2 manager nodes and 3 worker nodes.
``` bash
# first generate a ssh keychain, if you have this you can skip this step
ssh-keygen
# copy ssh publickey to the manager node
ssh-copy-id swarm-manager01.example.com -l pirate

# creating the docker swarm manager
ssh swarm-manager01.example.com -l pirate
docker swarm init --listen-addr 192.168.99.100 --advertise-addr 192.168.99.100
```
And you raspberry pi is now a docker swam manager node

### Configuration of swarm-worker0{1..2}.example.com
``` bash
for n in {1..2}; do
  ssh-copy-id swarm-worker0${n}.example.com -l pirate
  ssh swarm-worker0${n}.example.com "docker swarm join --token <worker token> \ 
    192.168.99.100:2377" -l pirate
done
```
## Adding a local registry
if you build your own docker images it's recommened to create your own registry services. This service will ensure that your own build images are accessable on all worker nodes. If you use only images from dockerhub this step is not required.
``` bash
# first we need to create a certificate for the registry. I do this on my local machine this is easier for me
openssl req -newkey rsa:4096 -nodes -sha256 -keyout registry.key -x509 -days 730 -out registry.crt
for nodes in manager01 worker01 worker02; do
  scp registry.crt pirate@swarm-${node}.example.com:
  ssh swarm-${node}.example.com -l pirate
    # actions on the node
    sudo mkdir -p /etc/docker/certs.d/swarm-manager01.example.com:5000/
    sudo cp registry.crt /etc/docker/certs.d/swarm-manager01.example.com:5000/ca.crt
    sudo vi /etc/hosts
      # append the folling line
      192.168.99.100  swarm-manager01.example.com
done

ssh swarm-manager01.example.com
# actions on manager node
docker service create --name registry --publish=5000:5000 \ 
  --constraint=node.role==manager \ 
  --mount=type=bind,src=/home/haraldvdlaan/certs,dst=/certs \ 
  -e REGISTRY_HTTP_ADDR=0.0.0.0:5000 \ 
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry.crt \ 
  -e REGISTRY_HTTP_TLS_KEY=/certs/registry.key budry/registry-arm
```
## Portainer
Manager you docker environments with ease.
Portainer is an open-source lightweight management UI which allows you to easily manager your docker hosts or swarm clusters.

``` bash
# this should be runned on the docker swarm manager node
docker service create --name portainer --publish 9000:9000 \ 
  --constraint 'node.role == manager' \ 
  --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \ 
  portainer/portainer -H unix:///var/run/docker.sock
```

## Visualizer
Visualizer is a docker servers that will show you what container/service is running on which swarm node. This function is also in portainer, but is works just a but better imho.

``` bash
# this should be runned on the docker swarm manager node
docker service create --name=visualizer --publish=8080:8080/tcp \ 
  --constraint=node.role==manager \ 
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \ 
  alexellis2/visualizer-arm
```