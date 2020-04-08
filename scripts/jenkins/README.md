# JENKINS NOTES

### ADITIONAL AUTOMATION
- Setup Git repository polling
- Deployment to our tomcat servers
- We will setup a couple of tasks to run in parallel
- And we will briefly explain how to setup tomcat on EC2 in Amazon Web Service

### MASTER SLAVE CONFIGURATION IN JENKINS
##### Different ways to start slave agent
- The master can start the slave agents via SSH.
- Start the slave agent manually using Java Web Start
- Install the slave agent as a Windows Service.
- Start the slave agent directly from the command line on the slave machine.

In Linux environment the most convenient way to start a Jenkis slave is undoubtedly to use SSH

##### Required commands
###### Connect to our dropplet via SSH.
```bash
ssh root@ip
change the password
```

###### Install jenkins throught the terminal
```bash
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
 
echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list
 
apt-get update
 
apt-get install jenkins

less <link provided in the initial of jenkins>
01393e4ea0504e639f4710c32c9565e1
```

###### Start the slave agent
* Master node will start the slave agent on the slave machine via SSH
* Automatic SSH login without password from master node to the slave is needed.
* Master node will be running as a specific user called JENKINS to start the slave agent.

###### In master node
```bash
sudo -iu jenkins
ssh-keygen -t rsa
ssh root@slave-ip mkdir -p .ssh
Type the root password of the slave machine to proceed

cat .ssh/id_rsa.pub | ssh root@slave-ip 'cat >> .ssh/authorized_keys'
Enter a root password of the slave node.

From now, we can login to the slave from the master node, without password.
ssh root@slave-ip

ssh root@slave-ip mkdir -p .ssh
```


###### In slave node
```bash

mkdir bin
cd bin/
pwd
wget http://<master-node-ip>:8080/jnlpJars/slave.jar
wget http://142.93.66.109:8080/jnlpJars/agent.jar
ls
install java to slave node
sudo apt-get install default-jre

wget http://142.93.66.109:8080/jnlpJars/agent.jar
```

###### In jenkins terminal (Master Node)
- Manage jenkins
- Manage nodes
- New node
- add a name
- enter required information

###### Executor
* A jenkins executor is one of the basic building blocks which allow a build to run on a node.
* Think of an executor as a single "Process ID", or as the basic unit of resource that jenkins executes on your machine to run a build.
* This number executors basically specifies the maximun number of concurrent builds that jenkins may perform on this agent.
* A good value for the number of executors to start with would be the number of CPU cores on the machine.
* Setting a higher value would cause each build to take longer, but could increase the overall throughput.
* For example, one build might be CPU-bound, while a second build running at the same time
might be I/O-bound. So the second build could take advantage of the spare I/O capacity at that moment.

#of executors: 2
- Remote directory: ```/var/jenkins```
- Launch command: ```ssh root@ip-slave java -jar /root/bin/slave.jar```
- SAVE




Launch agent via execution of command on the master

- sudo java -jar jenkins-cli.jar -s http://142.93.66.109:8080/ version
- wget http://142.93.66.109:8080/jnlpJars/jenkins-cli.jar


























