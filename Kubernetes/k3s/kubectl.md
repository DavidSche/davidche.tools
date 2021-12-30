# The Ultimate Kubectl Cheat Sheet

## What is Kubectl
If you are reading this article, you are probably familiar with Kubernetes and want to interact with a Kubernetes cluster. Regardless of the way you have provisioned the cluster, kubectl is the standard command line used to communicate with it. This article assumes that you have a basic knowledge of Kubernetes and the kubectl command.

## kubectl offers three techniques.

- The “Imperative commands” technique directly tells Kubernetes what operation to perform on which objects, for example: kubectl create pod or kubectl delete service.
- The “Imperative Object Configuration” technique is identical to the first one, except that it works on manifest files rather than objects directly, for example kubectl create -f manifest.yaml.
- The “Declarative Object Configuration” technique again takes manifest files as input but uses an “upsert” logic and creates objects if they don’t exist, or it updates existing objects that are different from the specifications in the input manifest files. The command for this is kubectl apply -f manifest.yaml.

> Please note that a true declarative approach does not exist yet because kubectl can’t automatically delete objects. The --prune option for the kubectl apply command allows you to achieve a completely declarative approach, but this option is currently in alpha at the time of this writing and thus not considered suitable for general use. Before diving into the code, it is important to note a few things.

The object notation is usually in the form of object type, followed by a slash, followed by the object name. For example, to address the “mypod” pod, the notation will be “pods/mypod”. Some commands accept different notations (e.g., “kubectl get pod mypod”), so you might see different notations used throughout this article.

### Most Important KubeCtl Commands

This is the TL;DR section of this article—a quick-access section to remind you of the most important commands. No explanations are given, but the commands are explained further down in the article.

To get the current contexts configured in your kubeconfig file:

$ kubectl config get-contexts

### To switch context:

$ kubectl config use-context minikube


### To get the name of the containers of a running pod:

$ kubectl get pod MYPOD -o 'jsonpath={.spec.containers[*].name}'

### To get the value of a secret (if you have the base64 command available):

$ kubectl -n mynamespace get secret MYSECRET \
-o 'jsonpath={.data.DB_PASSWORD}' | base64 -d
SuperSecretPassword
If you don’t have the base64 command available, you can use the go-template:

$ kubectl -n mynamespace get secret MYSECRET \
-o ‘go-template={{.data.DB_PASSWORD | base64decode}}’

An example of a filter in jsonpath:

$ kubectl get pod nginx \
-o 'jsonpath={.spec.containers[?(@.name=="nginx")].image}'
nginx:1.9.1

### To create a secret from your current Docker credentials to pull images from a private registry:

$ kubectl create secret generic SECRETNAME \
--from-file=.dockerconfigjson=$HOME/.docker/config.json \
--type=kubernetes.io/dockerconfigjson
To forward pod port 8080 to your local computer on port 8888:

$ kubectl port-forward MYPOD 8888:8080
To test RBAC rules:

$ kubectl --as=system:serviceaccount:MYNS:MYSA auth can-i get configmap/MYCM
yes
Most Important Kubectl Commands
This is the TL;DR section of this article—a quick-access section to remind you of the most important commands. No explanations are given, but the commands are explained further down in the article.

To get the current contexts configured in your kubeconfig file:

$ kubectl config get-contexts
To switch context:

$ kubectl config use-context minikube
To get the name of the containers of a running pod:

$ kubectl get pod MYPOD -o 'jsonpath={.spec.containers[*].name}'
To get the value of a secret (if you have the base64 command available):

$ kubectl -n mynamespace get secret MYSECRET \
-o 'jsonpath={.data.DB_PASSWORD}' | base64 -d
SuperSecretPassword
If you don’t have the base64 command available, you can use the go-template:

$ kubectl -n mynamespace get secret MYSECRET \
-o ‘go-template={{.data.DB_PASSWORD | base64decode}}’
An example of a filter in jsonpath:

$ kubectl get pod nginx \
-o 'jsonpath={.spec.containers[?(@.name=="nginx")].image}'
nginx:1.9.1
To create a secret from your current Docker credentials to pull images from a private registry:

$ kubectl create secret generic SECRETNAME \
--from-file=.dockerconfigjson=$HOME/.docker/config.json \
--type=kubernetes.io/dockerconfigjson
To forward pod port 8080 to your local computer on port 8888:

$ kubectl port-forward MYPOD 8888:8080
To test RBAC rules:

$ kubectl --as=system:serviceaccount:MYNS:MYSA auth can-i get configmap/MYCM
yes
Kubectl Contexts
Kubectl uses “contexts” to know how to communicate with the cluster. Contexts are stored in a kubeconfig file, which can store multiple contexts. Contexts will usually be provided by some other commands related to the control plane or some other management commands.

Such commands will usually add context to your kubeconfig file. The default kubectl config file is located at $HOME/.kube/config. You can use a different kubectl config file by specifying the --kubeconfig=PATH arguments on the kubectl command line.

To list the contexts available in your kubeconfig file, use “get-contexts”:

$ kubectl config get-contexts
CURRENT   NAME              CLUSTER           AUTHINFO         NAMESPACE
*         arn:aws:eks:...   arn:aws:eks:...   arn:aws:eks:...   
          minikube          minikube          minikube         default
To switch from one context to another, use “use-context”:

$ kubectl config use-context minikube
Switched to context "minikube".
$ kubectl config get-contexts
CURRENT   NAME              CLUSTER           AUTHINFO         NAMESPACE
arn:aws:eks:...   arn:aws:eks:...   arn:aws:eks:...
*         minikube          minikube          minikube         default
If you have only one context (i.e. you are managing a single cluster), then you are not concerned about contexts. If you are working with two or more clusters, you might want to consider using the --context command line option.

The reason is that if you often switch between clusters, you are pretty much guaranteed that one day you will run a kubectl command that you intended for another cluster, and the consequences might very well be dramatic.

With this in mind, you might want to set your default context to something innocuous, like minikube, and force yourself to explicitly provide the --context option on every kubectl command.

Kubectl Get
Kubectl get is probably the command you will use the most, so it deserves its own section. Kubectl get can retrieve information about all Kubernetes objects, as well as nodes in the Kubernetes data plane. The most common Kubernetes objects you are likely to query are pods, services, deployments, stateful sets, and secrets.

Kubectl get offers a range of output formats:

-o wide just adds more information (which is dependent on the type of objects being queried).
-o yaml and -o json output the complete current state of the object (and thus usually includes more information than the original manifest files).
-o jsonpath allows you to select the information you want out of the full JSON of the -o json option using the jsonpath notation.
-o go-template allows you to apply Go templates for more advanced features.
Here are some examples of commonly used commands:

List all pods in the default namespace (in this case, there are no pods in the default namespace):

$ kubectl get pod
No resources found in default namespace.
Get more information about a given pod:

$ kubectl -n mynamespace get po mypod-0 -o wide
NAME      READY   STATUS    RESTARTS   AGE    IP               NODE        NOMINATED NODE   READINESS GATES
mypod-0   2/2     Running   0          4d3h   192.168.181.98   node1.lan   [none]           [none]
The READY column shows how many containers are in the “ready” state in the given pod. The IP column shows the allocated IP address of this pod inside the Kubernetes cluster. The NODE column shows on which node the pod is running (or is scheduled).

Get the full state in YAML of the same pod as above:

$ kubectl -n mynamespace get pods/mypod -o yaml
apiVersion: v1
kind: Pod
metadata:
[ --- snip --- ]
To get the services in the default namespace:

$ kubectl get svc
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes       ClusterIP   10.100.0.1      [none]        443/TCP    24d
mysql            ClusterIP   10.100.78.115   [none]        3306/TCP   22d
mysql-headless   ClusterIP   None            [none]        3306/TCP   22d
The kubernetes service is used to access the Kubernetes API from within the cluster and is usually located in the default namespace.

To get the value of a secret:

$ kubectl -n mynamespace get secrets MYSECRET \
-o 'jsonpath={.data.DB_PASSWORD}' | base64 -d
SuperSecretPassword
Kubernetes stores secrets as base64-encoded values, hence the | base64 -d at the end to show a human-readable value. The base64 command is available on many operating systems, but you might need to change for your OS.

Other Commands to Get Information
There are many other commands to retrieve information besides kubectl get. In no particular order, here is a selection of the most important:

Retrieve the version strings for both the kubectl program and the Kubernetes server:

$ kubectl version --short
Client Version: v1.21.2
Server Version: v1.21.2-eks-0389ca3
To retrieve a lot of information about Kubernetes objects that are not shown by kubectl get, use kubectl describe:

$ kubectl -n mynamespace describe pods/mypod-0
Name:         mypod-0
Namespace:    mynamespace
[ --- snip --- ]
Containers:
myapp:
Container ID:   docker://9958565f45e7ddd27a5a7ca88254d3d27c162bb7612f0bb4c04781f154b33fd9
Image:          myapp:3
Port:           8080/TCP
Host Port:      0/TCP
State:          Running
Started:      Thu, 26 Aug 2021 13:31:13 +0100
Ready:          True
[ --- snip --- ]
Events:                      [none]
This command provides a lot of information and is very useful to understand why a pod is having problems. It shows the detailed status of all the containers, the mounted volumes, and the events associated with the pod.

In most cases, running this command is all you need to understand why your pod is not working the way you want. If the problem is still not apparent, however, you might want to run kubectl describe node, which will provide you with useful information about the Kubernetes nodes, such as the cumulative allocated resources like CPU and memory. Also, make sure to check out the “Conditions” section, which might flag some issues.

$ kubectl describe nodes
Name:               minikube
Roles:              control-plane,master
[ --- snip --- ]
Conditions:
Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
MemoryPressure   False   Mon, 11 Oct 2021 07:36:08 +0545   Sun, 29 Aug 2021 22:00:50 +0545   KubeletHasSufficientMemory   kubelet has sufficient memory available
DiskPressure     False   Mon, 11 Oct 2021 07:36:08 +0545   Sun, 29 Aug 2021 22:00:50 +0545   KubeletHasNoDiskPressure     kubelet has no disk pressure
PIDPressure      False   Mon, 11 Oct 2021 07:36:08 +0545   Sun, 29 Aug 2021 22:00:50 +0545   KubeletHasSufficientPID      kubelet has sufficient PID available
Ready            True    Mon, 11 Oct 2021 07:36:08 +0545   Sun, 29 Aug 2021 22:01:03 +0545   KubeletReady                 kubelet is posting ready status
[ --- snip --- ]
Allocated resources:
(Total limits may be over 100 percent, i.e., overcommitted.)
Resource           Requests    Limits
  --------           --------    ------
cpu                790m (39%)  6 (300%)
memory             390Mi (5%)  3242Mi (41%)
ephemeral-storage  100Mi (0%)  0 (0%)
hugepages-2Mi      0 (0%)      0 (0%)
Events:              
To get the logs from a container:

$ kubectl logs mypod-0 -c myapp
The -c argument is used to specify which container in the pod to query; if the pod has only one container, this argument is optional. Please note that kubectl logs will show the logs from the current log file on the node that is running the pod. Such log files are subject to rotation, so kubectl logs will show only the most recent log entries.

Generally speaking, you would use kubectl logs only for debugging during the development stage. For production environments, you will most likely use a log aggregator and query for the logs from there. Nevertheless, this command is one of your first ports of call to troubleshoot misbehaving pods and connectivity problems.

It should be noted that in many cases, you can get the logs of system pods running in the kube-system namespace, such as the API server, the DNS server, kube-proxy pods, etc. Some clusters have been set up to run those services directly on the control node(s) rather than pods, so in such cases you will need to check the logs directory on the control node(s).

Imperative Commands
These commands directly instruct Kubernetes to perform a specific operation on a given object. This section will show the most common such commands in no particular order. These are useful during the development stages, but you should definitely avoid them in a production environment.
Use kubectl create to create a Kubernetes object, except for pods that are created using the kubectl run command. So to create a pod directly:

$ kubectl run debug --image=busybox -- sleep infinity
pod/debug created
$ kubectl get pod
NAME    READY   STATUS    RESTARTS   AGE
debug   1/1     Running   0          6s
Using the run command is good enough for running simple pods. For more complex pods with multiple containers, persistent volumes, mounted ConfigMaps or Secrets, and a lot of environment variables, this method will very quickly become intractable, and it’s much easier to use a manifest file.
To delete the pod:

$ kubectl delete pod/debug
pod "debug" deleted
You can directly create all other Kubernetes objects using the kubectl create command. Here is a (silly) example for creating a Deployment:

$ kubectl create deployment nginx --image=nginx --replicas=2
deployment.apps/nginx created
$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6799fc88d8-6clhp   1/1     Running   0          9s
nginx-6799fc88d8-cjz56   1/1     Running   0          9s
Again, you can delete the deployment using the delete command:

$ kubectl delete deployment nginx
deployment.apps "nginx" deleted
You can modify the deployment like so (this will kick off your favorite text editor):

$ kubectl edit deployment nginx
If you don’t want kubectl to start a text editor, you can use the replace command. You will need to obtain the object’s state in YAML format first:

$ kubectl get deploy/nginx -o yaml ] tmp.yaml
$ # edit tmp.yaml
$ kubectl replace -f tmp.yaml
Please note that not all elements of a Kubernetes object can be modified after it has been created.

Another method to modify a Kubernetes object is to use the patch command. With the above deployment object, such a command could look like this:

$ kubectl patch deployment/nginx -p '{"spec": {"replicas": 3}}'
deployment.apps/nginx patched
$ kubectl get pod
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6799fc88d8-8jtw9   1/1     Running   0          11m
nginx-6799fc88d8-dgkqr   1/1     Running   0          24s
nginx-6799fc88d8-vqnkj   1/1     Running   0          24s
The -p argument accepts either JSON or YAML, although JSON tends to be a bit easier to type in. In any case, you are probably thinking that this isn’t a user-friendly way of doing things, and you would be right. This is one example where working with manifest files and using the declarative style make things much easier.

You can also use the kubectl set command to easily modify certain objects, but it is limited in scope and not generic. It is mostly used to modify the image of pods or deployments, for example:

$ kubectl set image deploy/nginx nginx=nginx:1.9.1
deployment.apps/nginx image updated
$ kubectl get pod nginx-684c8b4f65-c6ws6 -o \
'jsonpath={.spec.containers[?(@.name=="nginx")].image}'
nginx:1.9.1
BTW, the jsonpath used above contains a filter on the “containers” array to extract only the information we want. Another way to modify objects is to add or change the labels and annotations attached to it, for example:

$ kubectl label deploy/nginx --overwrite app=frontend
deployment.apps/nginx labeled
$ kubectl get deploy nginx -o jsonpath='{.metadata.labels}'
{"app":"frontend"}
$ kubectl annotate deploy/nginx test=yes
deployment.apps/nginx annotated
$ kubectl get deploy/nginx -o 'jsonpath={.metadata.annotations}'
{"deployment.kubernetes.io/revision":"2","test":"yes"}
Declarative Commands
When you want to work in declarative mode, you will have a manifest file (or a set of them), and essentially use only one command:

$ kubectl apply -f X
Here, X is a file or a directory (you can add multiple -f arguments if necessary). If you want to make some changes to your existing Kubernetes objects, just modify the manifest files and run kubectl apply again. This will compute the differences between your desired state and the existing state and make the necessary changes to reconcile them. The only caveat is that it won’t delete objects that you removed from your manifest files.

If you use kustomization files, you should use the -k option instead, and the argument must be a directory:

$ kubectl apply -k DIR
There is a special case where the reconciliation is problematic, which has to do with the Kubernetes authorization system. The reasons for this are quite obscure and are touched on here if you are interested. If you make changes to RBAC resources or roles, you should use the kubectl auth reconcile command. You can find more information on this in the official Kubernetes documentation.

You can delete objects declared in manifests files by using the following command:

$ kubectl delete -f X
Managing Deployments
Here are some useful commands to manage deployments (in a general sense, so that also includes stateful sets and daemon sets).

When you update a deployment (or stateful set or daemon set), you can view the status of the update using kubectl rollout status deploy/myapp. You can cancel a rollout using this command: kubectl rollout undo statefulset/myapp and get a history of changes using kubectl rollout history deployment/myapp. In practice, however, these commands are seldom used because you would manage deployments using Helm or some other similar software.

You can modify the number of pods running for a given deployment using kubectl scale --replicas=N deploy/myapp, where N is the new desired number of replicas. The end result is the same as using kubectl edit deploy/myapp and modifying the number of replicas there.

Again, in practice, you are likely either to use Helm to perform static, manual changes or the pod autoscaler and not perform any manual operation. BTW, you can set up some basic autoscaling using kubectl autoscale, although that works only with one metric: CPU utilization.

If your Docker registry is private, you will need to pass some credentials to Kubernetes. The easiest way to do this is to first login using the Docker command line, for example, on AWS:

$ aws ecr get-login-password | docker login -u AWS \
--password-stdin ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com
Once logged in, you can manually create the secret like so:

$ kubectl create secret generic SECRETNAME \
--from-file=.dockerconfigjson=$HOME/.docker/config.json \
--type=kubernetes.io/dockerconfigjson
You can then use the secret SECRETNAME in the pod specification inside your manifest file like so:

imagePullSecrets: [name: SECRETNAME]
Please note that such secrets are usually valid only for a limited period of time.

It is very common to forget to set imagePullSecrets, in which case your pods will show a “pull image error”. So, if you see that error and you are using a private registry, you might want to check that you did set imagePullSecrets, and that the secret is not expired.

Interacting With Pods
This section will list a bunch of commands that are very useful to interact with your pods.

Nothing beats getting a shell to a running pod! Here’s how to do it (you can skip the -c argument if you have only one container running inside the pod):

$ kubectl -n NS exec -it POD -c CONTAINER -- sh
Please note that the shell will be executed as the default user specified by the container’s image. Kubectl currently doesn’t allow you to run the shell as another user (e.g., root), although there are some plugins that can do that. Also note that you need an executable shell available inside the container image (so you can’t use it on distroless images, for example).

Consequently, you might need to think about how such containers will be troubleshooted. You might want to have two versions of such containers: One for development (with the shell and maybe other programs) and one for production (which would be distroless).

You can quickly create a link between a given port number on a given pod running inside the Kubernetes cluster and your computer (this is called port forwarding). Here is how to do it, assuming your pod exposes port 8080:

$ kubectl port-forward MYPOD 8888:8080
You can then open up port 8888 on your local computer and that will forward the traffic to the pod MYPOD on its port 8080. This is very useful to do a quick check on your pod to verify that it looks OK.

You can copy files and directories using the kubectl cp command. We won’t go into detail here, but it is sometimes better for inspecting large and/or binary files on your computer rather than battling with the shell and a couple of utilities in an exec session.

Finally, you can use kubectl attach to attach to the container terminal, although this is usually of limited use because you get the output from kubectl logs and, in general, apps don’t read stdin.

Miscellaneous commands
It is useful to be able to complete your shell commands, and kubectl has a ready-made solution for that:

$ source kubectl completion bash
Kubectl supports a number of shells, and you will need to consult Kubernetes documentation for more details. Please note you will also need to install the bash-completion package for your Operating System (if not already installed).

Also, the above command will enable autocompletion only for the current session; to make it permanent, add this command to your shell initialization file.

Pro tip: If, like me, you use bash and like to have an alias to abbreviate “kubectl” into “k”, add the following line into your ~/.bashrc file to make autocompletion work when using just “k”:

complete -F __start_kubectl k
You can show the APIs and resource types available on your cluster like so:

$ kubectl api-versions
admissionregistration.k8s.io/v1
admissionregistration.k8s.io/v1beta1
apiextensions.k8s.io/v1
[ --- snip --- ]
$ kubectl api-resources
NAME               SHORTNAMES   APIVERSION  NAMESPACED   KIND
bindings                        v1          true         Binding
componentstatuses  cs           v1          false        ComponentStatus
configmaps         cm           v1          true         ConfigMap
endpoints          ep           v1          true         Endpoints
events             ev           v1          true         Event
[ --- snip --- ]
Finally, a very useful command to test your RBAC rules is kubectl auth can-i. Here is an example to test whether a given service account can read a certain config map:

$ kubectl --as=system:serviceaccount:MYNS:MYSA auth can-i get configmap/MYCM
yes
You will obviously need to replace the capitalized placeholders with the names that make sense for your setup.

Kubernetes Troubleshooting With Komodor
Kubernetes is a complex system, and often, something will go wrong, simply because it can. In situations like this, you’ll likely begin the troubleshooting process by reverting to some of the above kubectl commands to try and determine the root cause. This process, however, can often run out of hand and turn into a stressful, ineffective, and time-consuming task.

This is the reason why we created Komodor, a tool that helps dev and ops teams stop wasting their precious time looking for needles in (hay)stacks every time things go wrong.

Acting as a single source of truth (SSOT) for all of your k8s troubleshooting needs, Komodor offers:

Change intelligence: Every issue is a result of a change. Within seconds we can help you understand exactly who did what and when.
In-depth visibility: A complete activity timeline, showing all code and config changes, deployments, alerts, code diffs, pod logs and etc. All within one pane of glass with easy drill-down options.
Insights into service dependencies: An easy way to understand cross-service changes and visualize their ripple effects across your entire system.
Seamless notifications: Direct integration with your existing communication channels (e.g., Slack) so you’ll have all the information you need, when you need it.
If you are interested in checking out Komodor, use this link to sign up for a Free Trial.