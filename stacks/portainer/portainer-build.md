# portainer的二次开发

## 一、准备环境

依赖：Docker, Node.js >= 0.8.4 和 npm

```shell
[root@dev_08 ~]# curl --silent --location https://rpm.nodesource.com/setup_7.x | sudo bash -
[root@dev_08 ~]# yum install -y nodejs
[root@dev_08 ~]# npm install -g grunt-cli
```

## 二、构建

### 1、checkout

```shell
[root@dev_08 ~]# cd /opt
先 fork 一个 portainer的分支，然后 clone 到本地， 然后在 branch 上开发，例如：
[root@dev_08 opt]# git clone https://github.com/opera443399/portainer.git
[root@dev_08 opt]# cd portainer
[root@dev_08 portainer]# git checkout -b feat-add-container-console-on-task-details
Switched to a new branch 'feat-add-container-console-on-task-details'
[root@dev_08 portainer]# git branch
develop
* feat-add-container-console-on-task-details

```

### 2、使用 npm 安装依赖包

```shell
[root@dev_08 portainer]# npm install -g bower && npm install
```

### 3、根目录没有这个目录： bower_components 的话则执行

```shell
[root@dev_08 portainer]# bower install --allow-root
```

### 4、针对 centos 执行

```shell
[root@dev_08 portainer]# ln -s /usr/bin/sha1sum /usr/bin/shasum
```

### 5、构建 app

```shell
[root@dev_08 portainer]# grunt build
```

#### 如果遇到这样的错误：

```shell
Building portainer for linux-amd64
/go/src/github.com/portainer/portainer/crypto/crypto.go:4:2: cannot find package "golang.org/x/crypto/bcrypt" in any of:
/usr/local/go/src/golang.org/x/crypto/bcrypt (from $GOROOT)
/go/src/golang.org/x/crypto/bcrypt (from $GOPATH)
/go/src/github.com/portainer/portainer/http/handler/websocket.go:21:2: cannot find package "golang.org/x/net/websocket" in any of:
/usr/local/go/src/golang.org/x/net/websocket (from $GOROOT)
/go/src/golang.org/x/net/websocket (from $GOPATH)
mv: cannot stat ‘api/cmd/portainer/portainer-linux-amd64’: No such file or directory
Warning: Command failed: build/build_in_container.sh linux amd64
mv: cannot stat ‘api/cmd/portainer/portainer-linux-amd64’: No such file or directory
Use --force to continue.

Aborted due to warnings.
```


那是因为网络可达性问题，国内访问 golang.org 异常。

```shell
[root@dev_08 portainer]# host golang.org
golang.org is an alias for golang-consa.l.google.com.
golang-consa.l.google.com has address 216.239.37.1


导致这2个依赖下载失败：
golang.org/x/crypto/bcrypt
golang.org/x/net/websocket
```



#### 解决方法：

```shell
[root@dev_08 portainer]# go get github.com/golang/crypto/tree/master/bcrypt
[root@dev_08 portainer]# go get github.com/golang/net/tree/master/websocket

[root@dev_08 portainer]# cd $GOPATH/src
[root@dev_08 src]# mkdir golang.org/x -p
[root@dev_08 src]# mv github.com/golang/* golang.org/x/
```

然后再切换到源码目录，调整构建脚本：

```shell
[root@dev_08 src]# cd /opt/portainer
[root@dev_08 portainer]# vim build/build_in_container.sh
```

挂载本地的 $GOPATH/src/golang.org 到容器路径：/go/src/golang.org

```shell
docker run --rm -tv $(pwd)/api:/src -e BUILD_GOOS="$1" -e BUILD_GOARCH="$2" portainer/golang-builder:cross-platform /src/cmd/portainer

```

调整为：

```shell
docker run --rm -tv $(pwd)/api:/src -v $GOPATH/src/golang.org:/go/src/golang.org -e BUILD_GOOS="$1" -e BUILD_GOARCH="$2" portainer/golang-builder:cross-platform /src/cmd/portainer
```

最后重新构建一次：

```shell
[root@dev_08 portainer]# grunt build
（略）
Cleaning "dist/js/angular.37dfac18.js"...OK
Cleaning "dist/js/portainer.cab56db9.js"...OK
Cleaning "dist/js/vendor.4edc9b0f.js"...OK
Cleaning "dist/css/portainer.e7f7fdaa.css"...OK

Done, without errors.
```

看到上述输出，表示符合预期。


### 6、运行（可以自动重启）

```shell
[root@dev_08 portainer]# grunt run-dev
```


访问 UI 地址： http://localhost:9000

### 7、不要忘记 lint 代码

```shell
[root@dev_08 portainer]# grunt lint

```

8、release（通常我们使用 linux-amd64 这个平台，具体过程请参考脚本 build.sh）

```shell
[root@dev_08 portainer]# grunt "release:linux:amd64"
(略)
Done, without errors.
[root@dev_08 portainer]# ls dist/
css  fonts  ico  images  index.html  js  portainer-linux-amd64
[root@dev_08 portainer]# mv dist/portainer-linux-amd64 dist/portainer

```

### 9、打包成镜像

```shell
[root@dev_08 portainer]# docker build -t 'opera443399/portainer:dev' -f build/linux/Dockerfile .

```

### 10、测试上述镜像

```shell
[root@dev_08 portainer]# mkdir -p /data/portainer_dev
[root@dev_08 portainer]# docker run -d -p 9001:9000 -v /var/run/docker.sock:/var/run/docker.sock -v /data/portainer_dev:/data --name portainer_dev opera443399/portainer:dev
[root@dev_08 portainer]# docker ps -l
CONTAINER ID        IMAGE                                   COMMAND             CREATED             STATUS              PORTS                    NAMES
cbd986df765b        opera443399/portainer:dev               "/portainer"        8 seconds ago       Up 7 seconds        0.0.0.0:9001->9000/tcp   portainer_dev

```

首次使用时将初始化一个管理员账户（本例使用 httpie 来提交）

```shell
[root@dev_08 portainer]# http POST :9001/api/users/admin/init Username="admin" Password="Develop"
HTTP/1.1 200 OK
Content-Length: 0
Content-Type: text/plain; charset=utf-8
Date: Tue, 10 Oct 2017 08:18:19 GMT
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
```

访问页面：your_dev_ip:9001
验证功能：符合预期

#### 清理：

```shell
[root@dev_08 portainer]# docker rm -f portainer_dev
```



