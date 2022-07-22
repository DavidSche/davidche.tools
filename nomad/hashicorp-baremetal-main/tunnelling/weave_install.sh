#!/bin/bash
curl -L git.io/weave -o /usr/local/bin/weave
chmod a+x /usr/local/bin/weave
echo "Installing docker..."
apt update
apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" -y
apt update
apt install docker-ce docker-ce-cli containerd.io -y
echo '{ "dns" : [ "172.17.0.1" , "8.8.8.8" ] }'  > /etc/docker/daemon.json
systemctl enable docker
service docker reload
docker run hello-world
# https://www.weave.works/docs/net/latest/install/systemd/
# Not working btw