# Jenkins常见REST API

## Jenkins常见REST API（便于将Jenkins集成到其他系统）

### 1、运行job

***a、无参任务***

```
curl -XPOST http://IP:8080/jenkins/job/plugin%20demo/build --user admin:admin
```

***b、含参任务***

b-1、不设置参数/使用默认参数

```shell
curl -XPOST http://IP:8080/jenkins/job/commandTest/buildWithParameters --user admin:admin
```

b-2、设置参数方法1

```shell
curl -XPOST http://IP:8080/jenkins/job/commandTest/buildWithParameters -d port=80
```

b-3、设置参数方法2

```shell
curl -XPOST http://IP:8080/jenkins/job/commandTest/buildWithParameters -d port=80 --data-urlencode json='"{"parameter": [{"name": "port", "value": "80"}]}"'
```

b-4、多参数

curl -XPOST http://IP:8080/jenkins/job/commandTest/buildWithParameters -d param1=value1&param2=value


### 2、创建job

***a、需创建目录***

1).创建job目录
～/.jenkins/jobs/jobfromcmd
2).创建config.xml文件（可从其他工程中复制）
3).运行命令

```shell
curl -XPOST http://IP:8080/jenkins/createItem?name=jobfromcmd --user admin:admin --data-binary "@config.xml" -H "Content-Type: text/xml"
```

b、不需创建目录

1).创建config.xml文件（可从其他工程中复制）
2).运行命令（在config.xml同一目录下）

```shell
curl -XPOST http://IP:8080/jenkins/createItem?name=jobfromcmd --user admin:admin --data-binary "@config.xml" -H "Content-Type: text/xml"
```

### 3、删除job

```shell
curl -XPOST http://IP:8080/jenkins/job/jobfromcmd/doDelete
```

### 4、查询job的状态

```shell
curl -XGET http://IP:8080/job/JOB_NAME/lastBuild/api/json
```

### 5、关闭job

```shell
curl -XPOST --data disable http://IP:8080/job/JOBNAME/disable
```

### 6、获取job的build number

```shell
curl -XGET http://IP:8080/job/JOB_NAME/lastBuild/buildNumber
```

### 7获取最近成功的build的num

```shell
curl -XGET http://IP:8080/job/JOB_NAME/lastStableBuild/buildNumber
```

------
