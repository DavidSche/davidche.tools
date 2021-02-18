<img
  src="https://kubernetes.io/images/kubernetes-horizontal-color.png"
  width="300"
  align="right"
/>

# Kubernetes Cheatsheet


## Table of Contents
* [Kubernetes Concepts](#kubernetes-concepts)
* [Online Courses](#online-courses)
* [Youtube](#youtube)
* [Resources](#resources)


## Kubernetes Concepts
The following section is an extract from the [Standardized Glossary](https://kubernetes.io/docs/reference/glossary/?all=true) of the Kubernetes documentation.

#### CronJob
Manages a Job that runs on a periodic schedule. Similar to a line in a crontab file, a CronJob object specifies a schedule using the cron format.

* use common cron syntax to schedule tasks
* cronjobs are part of batch API

#### CustomResourceDefinition (CRD)
Custom code that defines a resource to add to your Kubernetes API server without building a complete custom server. Custom Resource Definitions let you extend the Kubernetes API for your environment if the publicly supported API resources can't meet your needs.

* CRD defines new resource type
* Once added,  new instances of that resource may be created


#### DeamonSet
Ensures a copy of a Pod is running across a set of nodes in a cluster. Used to deploy system daemons such as log collectors and monitoring agents that typically must run on every Node.

* provides method for scheduling execution of pods
* backups, reports, automated tests
* used to install or configure software on each host node.

#### Deployments
An API object that manages a replicated application, typically by running Pods with no local state. Each replica is represented by a Pod, and the Pods are distributed among the nodes of a cluster. For workloads that do require local state, consider using a StatefulSet.

* deployments support rolling updates and rollbacks
* rollouts can be paused

#### Ingress
An API object that manages external access to the services in a cluster, typically HTTP. Ingress may provide load balancing, SSL termination and name-based virtual hosting.

* route traffic to and from the cluster
* provide single SSL endpoint

#### Pod
The smallest and simplest Kubernetes object. A Pod represents a set of running containers on your cluster. A Pod is typically set up to run a single primary container. It can also run optional sidecar containers that add supplementary features like logging. Pods are commonly managed by a Deployment.

* runs at least one or more containers and controls the execution of that container.
* provides a way to set environment variables, mount storage, and feed other information into a container.
* when the container exit, the pod dies.

#### Replicasets
A ReplicaSet (aims to) maintain a set of replica Pods running at any given time. Workload objects such as Deployment make use of ReplicaSets to ensure that the configured number of Pods are running in your cluster, based on the spec of that ReplicaSet.

* replicasets are considered a low-level type
* users often opt for higher level abstraction like deployments and DeamonSets.
* ensures that a set of identically configured Pods are running at the desired replica count
* If a Pod drops off, the ReplicaSet brings a new one online as a replacement.

#### Secrets
Secrets stores sensitive information, such as passwords, OAuth tokens, and ssh keys. Allows for more control over how sensitive information is used and reduces the risk of accidental exposure, including encryption at rest. A Pod references the secret as a file in a volume mount or by the kubelet pulling images for a pod. Secrets are great for confidential data and ConfigMaps for non-confidential data.

* secrets are base64 encoded "at rest" and automatically decoded when attached to a Pod
* secrets can be attached as files or environment variables
* use add-on encryption provides for locking your data

#### Service
An abstract way to expose an application running on a set of Pods as a network service. The set of Pods targeted by a Service is (usually) determined by a selector. If more Pods are added or removed, the set of Pods matching the selector will change. The Service makes sure that network traffic can be directed to the current set of Pods for the workload.

## Online Courses

### A Cloud Guru
* [EKS Basics](https://acloudguru.com/course/eks-basics) - Amazon Elastic Kubernetes Service (EKS) is a managed service that makes it easy to run Kubernetes on AWS without needing to install and operate your own Kubernetes control plane or worker nodes.
* [Kubernetes Quick Start](https://acloudguru.com/course/kubernetes-quick-start) - This course serves as an introduction to Kubernetes and covers the basic installation and configuration needed to get a Kubernetes cluster up and running. We also discuss deployments and pod versioning. 
* [Kubernetes Essentials](https://acloudguru.com/course/kubernetes-essentials) - In this course, we will explore Kubernetes from a beginner’s standpoint. We will discuss what Kubernetes is and what it does and work with some of the basic functionality of Kubernetes hands-on. We will build a simple Kubernetes cluster.
* [Kubernetes Deep Dive](https://acloudguru.com/course/kubernetes-deep-dive) - You’ll learn how to build a Kubernetes cluster, and how to deploy and manage applications on it. Along the way, you’ll learn the internals of how Kubernetes works, as well as best-practices such as managing applications declaratively. By the end of the course you’ll have all the tools you need to get started with Kubernetes and take your career to the next level.

## Youtube
* [Microsoft Azure - Kubernetes Basics Playlist](https://www.youtube.com/playlist?list=PLLasX02E8BPCrIhFrc_ZiINhbRkYMKdPT)
* [Complete Kubernetes Tutorial for Beginners](https://www.youtube.com/playlist?list=PLy7NrYWoggjziYQIDorlXjTvvwweTYoNC)

## Resources
* [Microsoft Kubernetes Learning Path - 50 Days from zero to hero with Kubernetes](https://azure.microsoft.com/mediahandler/files/resourcefiles/kubernetes-learning-path/Kubernetes%20Learning%20Path%20version%201.0.pdf)
