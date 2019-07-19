
cmd

@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco upgrade chocolatey


choco install yarn
choco upgrade chocolatey




kubectl get pods -o wide


* all  
  * certificatesigningrequests (aka 'csr')  
  * clusterrolebindings  
  * clusterroles  
  * componentstatuses (aka 'cs')  
  * configmaps (aka 'cm')  
  * controllerrevisions  
  * cronjobs  
  * customresourcedefinition (aka 'crd')  
  * daemonsets (aka 'ds')  
  * deployments (aka 'deploy')  
  * endpoints (aka 'ep')  
  * events (aka 'ev')  
  * horizontalpodautoscalers (aka 'hpa')  
  * ingresses (aka 'ing')  
  * jobs  
  * limitranges (aka 'limits')  
  * namespaces (aka 'ns')  
  * networkpolicies (aka 'netpol')  
  * nodes (aka 'no')  
  * persistentvolumeclaims (aka 'pvc')  
  * persistentvolumes (aka 'pv')  
  * poddisruptionbudgets (aka 'pdb')  
  * podpreset  
  * pods (aka 'po')  
  * podsecuritypolicies (aka 'psp')  
  * podtemplates  
  * replicasets (aka 'rs')  
  * replicationcontrollers (aka 'rc')  
  * resourcequotas (aka 'quota')  
  * rolebindings  
  * roles  
  * secrets  
  * serviceaccounts (aka 'sa')  
  * services (aka 'svc')  
  * statefulsets (aka 'sts')  
  * storageclasses (aka 'sc')

Examples:
  # List all pods in ps output format.
  kubectl get pods
  
  # List all pods in ps output format with more information (such as node name).
  kubectl get pods -o wide
  
  # List a single replication controller with specified NAME in ps output format.
  kubectl get replicationcontroller web
  
  # List a single pod in JSON output format.
  kubectl get -o json pod web-pod-13je7
  
  # List a pod identified by type and name specified in "pod.yaml" in JSON output format.
  kubectl get -f pod.yaml -o json
  
  # Return only the phase value of the specified pod.
  kubectl get -o template pod/web-pod-13je7 --template={{.status.phase}}
  
  # List all replication controllers and services together in ps output format.
  kubectl get rc,services
  
  # List one or more resources by their type and names.
  kubectl get rc/web service/frontend pods/web-pod-13je7
  
  # List all resources with different types.
  kubectl get all


kubectl get deployments  redis-server-redis1 -o yaml 

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: 2019-07-15T02:25:09Z
  generation: 1
  labels:
    name: redis-server-redis1
  name: redis-server-redis1
  namespace: default
  resourceVersion: "8567786"
  selfLink: /apis/extensions/v1beta1/namespaces/default/deployments/redis-server-redis1
  uid: c4624ac2-a6a7-11e9-9b39-001a4a160116
spec:
  minReadySeconds: 5
  replicas: 3
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      name: redis-server-redis1
      podConflictName: redis-server-redis1
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        name: redis-server-redis1
        podConflictName: redis-server-redis1
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                name: redis-server-redis1
                podConflictName: redis-server-redis1
            namespaces:
            - default
            topologyKey: kubernetes.io/hostname
      containers:
      - args:
        - boot.sh
        - REDIS_SERVER
        env:
        - name: REDIS_CONF_DIR
          value: /etc/redis1/conf
        image: cqy-bigdata-node1:5000/transwarp/redis:transwarp-6.0.2-final
        imagePullPolicy: Always
        name: redis-server-redis1
        resources: {}
        securityContext:
          privileged: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/redis1/conf
          name: conf
        - mountPath: /var/log/redis1/
          name: log
        - mountPath: /vdir
          name: mountbind
        - mountPath: /usr/lib/transwarp/plugins
          name: plugin
        - mountPath: /etc/localtime
          name: timezone
        - mountPath: /etc/transwarp/conf
          name: transwarphosts
        - mountPath: /etc/tos/conf
          name: tos
        - mountPath: /etc/license/conf
          name: license
      dnsPolicy: ClusterFirst
      hostNetwork: true
      nodeSelector:
        redis-server-redis1: "true"
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 0
      volumes:
      - hostPath:
          path: /etc/redis1/conf
          type: ""
        name: conf
      - hostPath:
          path: /var/log/redis1/
          type: ""
        name: log
      - hostPath:
          path: /transwarp/mounts/redis1
          type: ""
        name: mountbind
      - hostPath:
          path: /usr/lib/transwarp/plugins
          type: ""
        name: plugin
      - hostPath:
          path: /etc/localtime
          type: ""
        name: timezone
      - hostPath:
          path: /etc/transwarp/conf
          type: ""
        name: transwarphosts
      - hostPath:
          path: /etc/tos/conf
          type: ""
        name: tos
      - hostPath:
          path: /etc/license/conf
          type: ""
        name: license
status:
  availableReplicas: 3
  conditions:
  - lastTransitionTime: 2019-07-15T02:25:16Z
    lastUpdateTime: 2019-07-15T02:25:16Z
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  observedGeneration: 1
  readyReplicas: 3
  replicas: 3
  updatedReplicas: 3
```



#  kubectl get deployments  kafka-manager-milano1  -o yaml 

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: 2019-05-23T00:56:29Z
  generation: 1
  labels:
    name: kafka-manager-milano1
  name: kafka-manager-milano1
  namespace: default
  resourceVersion: "1826017"
  selfLink: /apis/extensions/v1beta1/namespaces/default/deployments/kafka-manager-milano1
  uid: 99a3d047-7cf5-11e9-a268-001a4a160116
spec:
  minReadySeconds: 5
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      name: kafka-manager-milano1
      podConflictName: kafka-manager-milano1
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        name: kafka-manager-milano1
        podConflictName: kafka-manager-milano1
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                name: kafka-manager-milano1
                podConflictName: kafka-manager-milano1
            namespaces:
            - default
            topologyKey: kubernetes.io/hostname
      containers:
      - args:
        - boot.sh
        - MILANO_KAFKA_MANAGER
        env:
        - name: KAFKA_MANAGER_CONF_DIR
          value: /etc/milano1/conf
        image: cqy-bigdata-node1:5000/transwarp/kafka-manager:transwarp-6.0.2-final
        imagePullPolicy: Always
        name: kafka-manager-milano1
        resources:
          limits:
            cpu: "1"
            memory: 2Gi
          requests:
            cpu: 500m
        securityContext:
          privileged: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/milano1/conf
          name: conf
        - mountPath: /var/log/milano1/
          name: log
        - mountPath: /vdir
          name: mountbind
        - mountPath: /usr/lib/transwarp/plugins
          name: plugin
        - mountPath: /etc/localtime
          name: timezone
        - mountPath: /etc/transwarp/conf
          name: transwarphosts
        - mountPath: /etc/tos/conf
          name: tos
        - mountPath: /etc/license/conf
          name: license
        - mountPath: /etc/kafka1/conf
          name: kafka1
        - mountPath: /etc/search1/conf
          name: search1
        - mountPath: /etc/zookeeper1/conf
          name: zookeeper1
      dnsPolicy: ClusterFirst
      hostNetwork: true
      nodeSelector:
        kafka-manager-milano1: "true"
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 0
      volumes:
      - hostPath:
          path: /etc/milano1/conf
          type: ""
        name: conf
      - hostPath:
          path: /var/log/milano1/
          type: ""
        name: log
      - hostPath:
          path: /transwarp/mounts/milano1
          type: ""
        name: mountbind
      - hostPath:
          path: /usr/lib/transwarp/plugins
          type: ""
        name: plugin
      - hostPath:
          path: /etc/localtime
          type: ""
        name: timezone
      - hostPath:
          path: /etc/transwarp/conf
          type: ""
        name: transwarphosts
      - hostPath:
          path: /etc/tos/conf
          type: ""
        name: tos
      - hostPath:
          path: /etc/license/conf
          type: ""
        name: license
      - hostPath:
          path: /etc/kafka1/conf
          type: ""
        name: kafka1
      - hostPath:
          path: /etc/search1/conf
          type: ""
        name: search1
      - hostPath:
          path: /etc/zookeeper1/conf
          type: ""
        name: zookeeper1
status:
  availableReplicas: 1
  conditions:
  - lastTransitionTime: 2019-05-23T00:56:29Z
    lastUpdateTime: 2019-05-23T00:56:29Z
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  observedGeneration: 1
  readyReplicas: 1
  replicas: 1
  updatedReplicas: 1

```


kubectl get deployments  kafka-server-kafka1  -o yaml 

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: 2019-05-23T12:19:15Z
  generation: 1
  labels:
    name: kafka-server-kafka1
  name: kafka-server-kafka1
  namespace: default
  resourceVersion: "1827777"
  selfLink: /apis/extensions/v1beta1/namespaces/default/deployments/kafka-server-kafka1
  uid: fb0b2df5-7d54-11e9-a268-001a4a160116
spec:
  minReadySeconds: 5
  replicas: 4
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      name: kafka-server-kafka1
      podConflictName: kafka-server-kafka1
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        name: kafka-server-kafka1
        podConflictName: kafka-server-kafka1
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                name: kafka-server-kafka1
                podConflictName: kafka-server-kafka1
            namespaces:
            - default
            topologyKey: kubernetes.io/hostname
      containers:
      - args:
        - boot.sh
        - KAFKA_SERVER
        env:
        - name: TRANSWARP_ZOOKEEPER_QUORUM
          value: cqy-bigdata-node1,cqy-bigdata-node2,cqy-bigdata-node3,cqy-bigdata-node4,cqy-bigdata-node5
        - name: KAFKA_CONF_DIR
          value: /etc/kafka1/conf
        image: cqy-bigdata-node1:5000/transwarp/kafka:transwarp-6.0.2-final
        imagePullPolicy: Always
        name: kafka-server-kafka1
        resources: {}
        securityContext:
          privileged: true
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/kafka1/conf
          name: conf
        - mountPath: /var/log/kafka1/
          name: log
        - mountPath: /vdir
          name: mountbind
        - mountPath: /usr/lib/transwarp/plugins
          name: plugin
        - mountPath: /etc/localtime
          name: timezone
        - mountPath: /etc/transwarp/conf
          name: transwarphosts
        - mountPath: /etc/tos/conf
          name: tos
        - mountPath: /etc/license/conf
          name: license
        - mountPath: /etc/zookeeper1/conf
          name: zookeeper1
      dnsPolicy: ClusterFirst
      hostNetwork: true
      nodeSelector:
        kafka-server-kafka1: "true"
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 0
      volumes:
      - hostPath:
          path: /etc/kafka1/conf
          type: ""
        name: conf
      - hostPath:
          path: /var/log/kafka1/
          type: ""
        name: log
      - hostPath:
          path: /transwarp/mounts/kafka1
          type: ""
        name: mountbind
      - hostPath:
          path: /usr/lib/transwarp/plugins
          type: ""
        name: plugin
      - hostPath:
          path: /etc/localtime
          type: ""
        name: timezone
      - hostPath:
          path: /etc/transwarp/conf
          type: ""
        name: transwarphosts
      - hostPath:
          path: /etc/tos/conf
          type: ""
        name: tos
      - hostPath:
          path: /etc/license/conf
          type: ""
        name: license
      - hostPath:
          path: /etc/zookeeper1/conf
          type: ""
        name: zookeeper1
status:
  availableReplicas: 4
  conditions:
  - lastTransitionTime: 2019-05-29T03:28:54Z
    lastUpdateTime: 2019-05-29T03:28:54Z
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  observedGeneration: 1
  readyReplicas: 4
  replicas: 4
  updatedReplicas: 4
```
