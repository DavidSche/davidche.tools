
# Docker Deep Dive: 

## Managing Stopped Container

Tanveer Alam edited this page on 10 Aug 2019 · 2 revisions

**Managing Stopped Container**

Remove one or more containers:

docker container rm <NAME/ID List> 

List the rm flags:
```
docker container rm -h
```
Start one or more stopped containers:

docker container start <NAME>
Remove all stopped containers:

docker container prune
Listing all containers(up, exited etc) id using -q flag

```
$ docker container ls -a -q
b8e48c1415cf
74294fcb554a
41f8b94ff018
```

Listing all exited containers id:

```
$ docker container ls -a -q -f status=exited
74294fcb554a
```

Docker container prune(which will deleted all the stopped containers):

```
$ docker container prune
WARNING! This will remove all stopped containers.
Are you sure you want to continue? [y/N] y
Deleted Containers:
74294fcb554a62fa18489112c381bda9914f106a2ee9c0ebf12ff17f42dd2c2b

Total reclaimed space: 0B
```
https://github.com/tanalam2411/docker/wiki/Docker-Deep-Dive:-Managing-Stopped-Container



