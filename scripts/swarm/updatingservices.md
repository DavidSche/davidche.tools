# 更新服务

- We want to make changes to the web UI

- 需要以下步骤:

  - 编写代码

  - 构建新镜像

  - 交付新镜像

  - 运行新镜像

---

## 使用`service update`更新一个服务

- 要更新一个服务, 我们需要做以下步骤:

  ```bash
  export REGISTRY=127.0.0.1:5000
  export TAG=v0.2
  IMAGE=$REGISTRY/dockercoins_webui:$TAG
  docker build -t $IMAGE webui/
  docker push $IMAGE
  docker service update dockercoins_webui --image $IMAGE
  ```

- 确认使用 tag 标记镜像:每一个迭代后都更新`TAG`标签

  (当你检查正在运行的镜像时, 你需要唯一标签它)

---

## 使用 `stack deploy` 更新服务

- 对于符合服务应用, 我们不得不执行以下步骤:

  ```bash
  export TAG=v0.2
  docker-compose -f composefile.yml build
  docker-compose -f composefile.yml push
  docker stack deploy -c composefile.yml nameofstack
  ```

--

- 和我们前面部署应用时的使用一样

- 我们不需要学习新命令!

- 更新时需要变化的只有服务

---

## 改变代码

- Let's make the numbers on the Y axis bigger!

.练习[

- 更新 webui应用的文本的长度:

  ```bash
  sed -i "s/15px/50px/" dockercoins/webui/files/index.html
  ```

]

---

## 构建, 交付, 运行我们的修改

- 四步:

  1. 设置 (and export!) `TAG` 环境变量
  2. `docker-compose build`
  3. `docker-compose push`
  4. `docker stack deploy`

.练习[

- 构建, 交付, 运行:

  ```bash
  export TAG=v0.2
  docker-compose -f dockercoins.yml build
  docker-compose -f dockercoins.yml push
  docker stack deploy -c dockercoins.yml dockercoins
  ```

]

- 因为我们已经标签demo 例子中所有镜像为 v0.2, 部署将更新所有应用, FYI

---

## 查看我们的修改

- 至少等待 10 秒 (部署新版本时间)

- 重新加载 web UI

- Or just mash "reload" frantically

- ... Eventually the legend on the left will be bigger!