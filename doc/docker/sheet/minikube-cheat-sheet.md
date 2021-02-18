[comment]: <> (<img)

[comment]: <> (  src="https://miro.medium.com/max/400/0*KzqL3xqmXzV5PPjX.png")

[comment]: <> (  width="150")

[comment]: <> (  align="right")

[comment]: <> (/>)
![ss](./images/0*KzqL3xqmXzV5PPjX.png)
# Minikube 
Minikube creates a local Kubernetes cluster on macOS, Linux, and Windows. A production Kubernetes cluster setup consists of at least two master nodes and multiple worker nodes on separate virtual or physical machines. Minikube allows you to run a single-node Kubernetes cluster on your development machine. Both the master and worker processes are running on a single node. The docker runtime environment is pre-installed in the node.

Minikube supports Kubernetes features that makes sense locally like, DNS, NodePorts, PersistentVolumes, Ingress, ConfigMaps & Secrets, Dashboards, Container runtime (Docker, rkt, CRI-O), enabling CNI (Container Network Interface) and load balancer.

Minikube has several custom add-ons that can easily be enabled via the command line. The add-ons are dashboard, ingress, heapster, prometheus, registry-creds, and many more. The minikube deployment files in `~/.minikube/addons/deployment.yaml` can be used to run custom Kubernetes resources every time minikube starts.

Minikube is configurable via the config.json file, environment variables and flags. The $MINIKUBE_HOME resolves to the `~/.minikube` folder and contains all the minikube configuration and cached minikube artefacts. 

* Explicit Config: `~/.minikube/config/config.json (Via minikube config set commands)`
* Default Config: `~/.minikube/profiles/minikube/config.json`
* Applied Config: `~/.minikube/machines/minikube/config.json`

Configuration files can be mounted on the minikube node via `~/.minikube/files/home/config.yaml -> /home/config.yaml`. 

This cheatsheet is based on minikube version: **v1.15.1**

## Table of Contents
* [Installation](#installation)
* [Minikube Commands](#minikube-commands)
* [Minikube Tutorials](#minikube-tutorials)
* [Resources](#resources)


## Installation
The following links contain guides on how to install minikube on your machine:
* [JavaNibble: How to install minikube on macOS using Homebrew](https://www.javanibble.com/how-to-install-minikube-on-macos-using-homebrew/)
* [Minikube Installation](https://minikube.sigs.k8s.io/docs/start/)

## Minikube Commands

### Minikube Command Overview
**Basic Commands:**
* [`minikube start`](#minikube-start) - Starts a local Kubernetes cluster ([Reference](https://minikube.sigs.k8s.io/docs/commands/start/))
* [`minikube status`](#minikube-status) - Gets the status of a local Kubernetes cluster ([Reference](https://minikube.sigs.k8s.io/docs/commands/status/))
* [`minikube stop`](#minikube-stop) - Stops a running local Kubernetes cluster ([Reference](https://minikube.sigs.k8s.io/docs/commands/stop/))
* [`minikube delete`](#minikube-delete) - Deletes a local Kubernetes cluster ([Reference](https://minikube.sigs.k8s.io/docs/commands/delete/))
* [`minikube dashboard`](#minikube-dashboard) - Access the Kubernetes dashboard running within the minikube cluster ([Reference](https://minikube.sigs.k8s.io/docs/commands/dashboard/))
* [`minikube pause`](#minikube-pause) - Pause Kubernetes ([Reference](https://minikube.sigs.k8s.io/docs/commands/pause/))
* [`minikube unpause`](#minikube-unpause) - Unpause Kubernetes ([Reference](https://minikube.sigs.k8s.io/docs/commands/unpause/))

**Images Commands:**
* `minikube docker-env` - Configure environment to use minikube's Docker daemon ([Reference](https://minikube.sigs.k8s.io/docs/commands/docker-env/))
* `minikube podman-env` - Configure environment to use minikube's Podman service ([Reference]())
* [`minikube cache`](#minikube-cache ) - Add, delete, or push a local image into minikube ([Reference](https://minikube.sigs.k8s.io/docs/commands/cache/))

**Configuration and Management Commands:**
* [`minikube addons`](#minikube-addons) - Enable or disable a minikube addon ([Reference](https://minikube.sigs.k8s.io/docs/commands/addons/))
* [`minikube config`](#minikube-config) - Modify persistent configuration values ([Reference](https://minikube.sigs.k8s.io/docs/commands/config/))
* `minikube profile` - Get or list the current profiles (clusters) ([Reference](https://minikube.sigs.k8s.io/docs/commands/profile/))
* `minikube update-context` - Update kubeconfig in case of an IP or port change ([Reference](https://minikube.sigs.k8s.io/docs/commands/update-context/))

**Networking and Connectivity Commands:**
* [`minikube service`](#minikube-service) - Returns a URL to connect to a service ([Reference](https://minikube.sigs.k8s.io/docs/commands/service/))
* `minikube tunnel` - Connect to LoadBalancer services ([Reference](https://minikube.sigs.k8s.io/docs/commands/tunnel/))

**Advanced Commands:**
* `minikube mount` - Mounts the specified directory into minikube ([Reference](https://minikube.sigs.k8s.io/docs/commands/mount/))
* `minikube ssh` - Log into the minikube environment (for debugging) ([Reference](https://minikube.sigs.k8s.io/docs/commands/ssh/))
* [`minikube kubectl`](#minikube-kubectl) - Run a kubectl binary matching the cluster version ([Reference](https://minikube.sigs.k8s.io/docs/commands/kubectl/))
* `minikube node` - Add, remove, or list additional nodes ([Reference](https://minikube.sigs.k8s.io/docs/commands/node/))

**Troubleshooting Commands:**
* `minikube ssh-key` - Retrieve the ssh identity key path of the specified cluster ([Reference](https://minikube.sigs.k8s.io/docs/commands/ssh-key/))
* [`minikube ip`](#minikube-ip) - Retrieves the IP address of the running cluster ([Reference](https://minikube.sigs.k8s.io/docs/commands/ip/))
* [`minikube logs`](#minikube-logs) - Returns logs to debug a local Kubernetes cluster ([Reference](https://minikube.sigs.k8s.io/docs/commands/logs/))
* [`minikube update-check`](#minikube-update-check) - Print current and latest version number ([Reference](https://minikube.sigs.k8s.io/docs/commands/update-check/))
* [`minikube version`](#minikube-version) - Print the version of minikube ([Reference](https://minikube.sigs.k8s.io/docs/commands/version/))

**Other Commands:**
* `minikube completion` - Generate command completion for a shell ([Reference](https://minikube.sigs.k8s.io/docs/commands/completion/))
* `minikube help` - Help about any command ([Reference](https://minikube.sigs.k8s.io/docs/commands/help/))
* `minikube options` - Show a list of global command-line options (applies to all commands) ([Reference](https://minikube.sigs.k8s.io/docs/commands/options/))


### Minikube Command Examples


#### minikube addons

```shell
# Lists all available minikube addons as well as their current statuses
$ minikube addons list

# Disables the addon `dashboard` within minikube.
$ minikube addons disable dashboard

# Enables the addon `dashboard` within minikube.
$ minikube addons enable dashboard

# Enables the addon `metrics-server` within minikube.
$ minikube addons enable metrics-server

# Open the dashboard addon in a browser, since it exposes a browser endpoint.
$ minikube addons open dashboard
```

#### minikube cache  
Add, delete, or push a local image into minikube. See the `~/.minikube/cache/images` directory.

```shell
# List all the available images from the local cache.
$ minikube cache list

# Add the latest version of the nginx image to the local cache.
$ minikube cache add nginx:latest

# Reload the latest version of the nginx image to the local cache.
$ minikube cache reload nginx:latest

# Delete the latest vesrion of the nginx image from the local cache.
$ minikube cache delete nginx:latest
```

#### minikube config
```shell
# Set the memory field to 16GB in the minikube config file (~/.minikube/config/config.json)
$ minikube config set memory 16384

# Display values currently set in the minikube config file (~/.minikube/config/config.json)
$ minikube config view

# Unsets the memory field in the minikube config file (~/.minikube/config/config.json)
$ minikube config unset memory
```

#### minikube dashboard
```shell
# Access the Kubernetes dashboard running within the minikube cluster
$ minikube dashboard

# Display dashboard URL instead of opening a browser
$ minikube dashboard --url
```

#### minikube delete  
```shell
# Deletes a local Kubernetes cluster
$ minikube delete

# Deletes a local Kubernetes cluster & delete all profiles
$ minikube delete --all

# Deletes a local Kubernetes cluster & delete the '.minikube' folder from your user directory.
$ minikube delete --purge
```

#### minikube ip
```shell
# Retrieves the IP address of the running cluster, and writes it to STDOUT.
$ minikube ip
```

#### minikube kubectl
Use kubectl inside minikube
```shell
# Retrieve all the pods
$ minikube kubectl -- get pods

# Creating a deployment inside kubernetes cluster
$ minikube kubectl  -- create deployment hello-minikube --image=k8s.gcr.io/echoserver:1.4

# Exposing the deployment with a NodePort service
$ minikube kubectl -- expose deployment hello-minikube --type=NodePort --port=8080

# Display help
$ minikube kubectl -- --help
```

#### minikube logs
```shell
# Gets the logs of the running instance, used for debugging minikube, not user code.
$ minikube logs

# Display the logs of the running instance and continously print new entries
$ minikube logs -f
```

#### minikube pause
```shell
# Pause the Kubernetes cluster
$ minikube pause
```

#### minikube service
```shell
# List the kubernetes URLs for the services in the local cluster. This is the same as `kubectl get svc -A`
$ minikube service list
```

#### minikube start  
```shell
# Starts a local Kubernetes cluster 
$ minikube start

# Starts a local Kubernetes cluster with a profile name allowing multiple instances of minikube independently. (default "minikube")
$ minikube start --profile my-profile-name

# Starts a local kubernetes cluster and enable the metrics-server and dashboard addons at start-up.
$ minikube start --addons metrics-server --addons dashboard

# Starts a local kubernetes cluster with one of the drivers: virtualbox, parallels, vmwarefusion, hyperkit, vmware, docker, podman (experimental) (defaults to auto-detect)
$ minikube start --driver='hyperkit'

# Start a local kubernetes cluster in `debug` mode.
$ minikube start --v=7 --alsologtostderr

# Start a local kubernetes cluster and change the cluster version. (Supports any published Kubeadm build (>=1.8))
$ minikube start --kubernetes-version 1.16.1

# Start a local kubernetes cluster and choose a different container runtime (default:docker, cri-o, rkt)
$ minikube start --container-runtime=rkt

# Start a local kubernetes cluster and add configuration
$ minikube start --extra-config=kubelet.foo.bar=baz
```

#### minikube status
```shell
# Gets the status of a local Kubernetes cluster.
$ minikube status
```

#### minikube stop
```shell
# Stops a local Kubernetes cluster. This command stops the underlying VM or container, but keeps user data intact.
$ minikube stop
```

#### minikube unpause
```shell
# Unpause the Kubernetes cluster
$ minikube unpause
```

#### minikube update-check
```shell
# Print current and latest version number of minikube
$ minikube update-check
```

#### minikube version  
```shell
# Print the version of minikube
$ minikube version

# Print the version of minikube in yaml format
$ minikube version --output='yaml'

# Print the version of minikube in json format
$ minikube version --output='json'
```

## Minikube Tutorials
### Minikube Basic Startup

#### Deploy an application on Minikube and expose it via a NodePort
```shell
$ minikube start
$ minikube status
$ ps -Af | grep hyperkit
$ kubectl get pods --all-namespaces
```

```shell
$ kubectl create deployment my-first-minikube --image=k8s.gcr.io/echoserver:1.4
$ kubectl get deployment 
$ kubectl edit deployment my-first-minikube

$ kubectl expose deployment my-first-minikube --type=NodePort --port=8080
$ kubectl edit svc my-first-minikube
$ kubectl get svc

# The easiest way to access this service is to let minikube launch a web browser for you:
$ minikube service my-first-minikube
# Alternatively, use kubectl to forward the port. Your application is now available at http://localhost:7080/
$ kubectl port-forward service/my-first-minikube 7080:8080

$ minikube dashboard
```

```shell
$ kubectl delete svc my-first-minikube
$ kubectl delete deployment my-first-minikube
$ minikube stop
```

#### Deploy an application on Minikube and expose it via a LoadBalancer

```shell
$ minikube start
$ minikube status
$ ps -Af | grep hyperkit
$ kubectl get pods --all-namespaces
```

```shell
$ kubectl create deployment my-first-minikube --image=k8s.gcr.io/echoserver:1.4
$ kubectl get deployment 
$ kubectl edit deployment my-first-minikube

$ kubectl expose deployment my-first-minikube --type=LoadBalancer --port=8080
$ kubectl edit svc my-first-minikube
$ kubectl get svc

$ minikube dashboard

$ minikube ip
$ curl <ip>:<port>
```

```shell
$ kubectl delete svc my-first-minikube
$ kubectl delete deployment my-first-minikube
$ minikube stop
```

### Minikube Configuration
To Be Defined

### Minikube Local Storage and Volumes
To Be Defined

### Minikube Persistent Storage
To Be Defined

### Minikube Logging & Debugging

```shell
$ minikube start --v=0

$ minikube start --v=7 --alsologtostderr

$ minikube logs
$ minikube logs --problems

$ kubectl get po -A
$ kubectl describe pod <pod name> -n <namespace>
```

## Resources
* [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
* [Minikube GitHub Repository](https://github.com/kubernetes/minikube)
* [Youtube - Minikube Intro](https://www.youtube.com/watch?v=4x0CZmF_U5o)
* [A Cloud Guru - Minikube in the cloud on Ubuntu](https://acloudguru.com/course/minikube-in-the-cloud-on-ubuntu)