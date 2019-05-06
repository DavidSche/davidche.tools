#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -y

sudo apt-get install libseccomp2 -y

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update -y

sudo apt-get install docker-ce containerd.io -y

# curl -fsSL get.docker.com -o get-docker.sh
# sudo sh get-docker.sh
sudo usermod -aG docker vagrant
sudo service docker start

