# k8s vs swarm

[link](https://gist.githubusercontent.com/kemingy/553727e6b664b64fea5d3e464784fe07/raw/05c1269d789143d626abfaac3f636455f4a6f4c2/choose_docker_cluster_orchestration.md)

## [Kubernetes](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)

### Pros

* support GPU
* most famous
* 5k containers
* fault tolerant

### Cons

* too complicated

## [Swarm](https://docs.docker.com/engine/swarm/)

### Pros

* support GPU
* native solution for Docker, compatible API
* docker friendly
* easy to use

### Cons

* not fault tolerant(better to use less nodes with certain scale)

## [Nomad](https://www.nomadproject.io/)

### Pros

* support GPU
* focus on cluster management and schedualing, much simpler
* composing with other tools for service discovery([Consul](https://www.consul.io)) and secret management([Vault](https://www.vaultproject.io))
* natively suppor multi-datacenter and multi-region configurations
* 10k+ containers
* support virtualized, containerized and standalone applications
* natively run batch jobs, parameterized jobs, and Spark workloads

### Cons

* only provide cluster management and scheduling
* too many concepts

## [Mesos](http://mesos.apache.org/)

### Pros

* support GPU
* fault tolerant
* 10k+ containers

### Cons

* depend on ZooKeeper to provide both coordination and storage