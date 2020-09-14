# 实用K3S/K3D 管理集群

## How To: Deploy K3S using K3D with all node ports available, and then managing it with Portainer



So, deploying a K3S single node lab is easy, but what if you want to up the "realism" of your lab, and have multiple Kubernetes Nodes running as a cluster, but all of this actually running on a single Server; well thats where K3D comes in... K3D makes the process of creation a virtual multi-node cluster, that runs on a single server, easy.. however... if you want to externally expose Kubernetes services you deploy within the K3S Cluster, how can you do that? Watch and learn..


Commands used in the Video:
apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubu... | sudo apt-key add
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
apt-get update
apt-get install docker-ce

curl -LO https://storage.googleapis.com/kubern...`curl -s https://storage.googleapis.com/kubern...`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

curl -s https://raw.githubusercontent.com/ran... | bash

k3d cluster create portainer --api-port 6443 --servers 1 --agents 3 -p 30000-32767:30000-32767@server[0]

curl -LO https://raw.githubusercontent.com/por...
kubectl apply -f portainer-nodeport.yaml