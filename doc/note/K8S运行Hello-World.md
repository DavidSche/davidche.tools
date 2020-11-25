# K8S环境搭建

# 运行

1. server.js

```javascript
var http = require('http');

var handleRequest = function(request, response) {
  console.log('Received request for URL: ' + request.url);
  response.writeHead(200);
  response.end('Hello World!');
};
var www = http.createServer(handleRequest);
www.listen(8080);
```

2. Dockerfile

```docker
FROM node:6.14.2
EXPOSE 8080
COPY server.js .
CMD node server.js
```

3. 构建

```
docker build -t cuishiying/hello-node .
```

4. 本地测试

```
docker run -p 8080:8080 cuishiying/hello-node
```

5. 推送仓库

```
docker login
docker push cuishiying/hello-node
```

6. k8s

```
kubectl create deployment hello-node --image=cuishiying/hello-node
```


# 参考

- https://zhuanlan.zhihu.com/p/112755080
- https://kubernetes.io/zh/docs/tutorials/hello-minikube/