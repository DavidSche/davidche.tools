
# How To Ingress Using Portainer And Kubernates To Host A Website

Steps:

- On Portainer go to cluster and then setup
- then create an ingress controller as seen in the video
- set the type as traefik and the name as traefik
- Create a namespace (in the video its called test) and allow users to use ingress needs to be set to enabled
- Type in the domain or Sub-Domain that you want to use
- Then go to your router settings and port forward port 80 and port 443 and point it to your kubernates cluster
- Then add a A record in your DNS providers settings where the target is your public ip address (if you dont know your public ip address… type in what is my ip on google)
- now create a container as normal but on the publishing type you need to choose ingress port 80 and the route as /

## How To Create Persistent Volumes That Are Stored In A Host Directory

Find the instructions below on how to create the persistent volume.

Commands

sudo mkdir volume

cd volume

sudo nano volume.yaml
   
YAML Contents

Volume

apiVersion: v1
kind: PersistentVolume
metadata:
name: [NAME]
labels:
type: local
spec:
storageClassName: manual
capacity:
storage: 128Gi
accessModes:
– ReadWriteOnce
hostPath:
path: “[PATH]”

Volume Claim

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
name: [NAME]
namespace: [NAMESPACE]
spec:
storageClassName: manual
accessModes:
– ReadWriteOnce
resources:
requests:
storage: 128Gi


```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: [NAME]
  labels:
  type: local
spec:
  storageClassName: manual
  capacity:
    storage: 128Gi
  accessModes:
    – ReadWriteOnce
  hostPath:
    path: "[PATH]"
```

```yaml

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 8Gi
  storageClassName: slow
  selector:
    matchLabels:
      release: "stable"
    matchExpressions:
      - {key: environment, operator: In, values: [dev]}
```

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 100Gi
  # volumeMode field requires BlockVolume Alpha feature gate to be enabled.
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /mnt/disks/ssd1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - example-node
```


Instructions: https://lynxhost.co.uk/how-to-ingress-using-portainer-and-kubernates-to-host-a-website/
Website: https://lynxhost.co.uk

更新 CPU 共享数量
# f361b7d8465 为 容器ID
docker update --cpu-shares 512 f361b7d8465
更新容器的重启策略
docker update --restart=always f361b7d8465
更新容器内存
docker update -m 500M f361b7d8465
