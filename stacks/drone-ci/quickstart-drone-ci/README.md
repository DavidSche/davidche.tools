# Quickstart Drone CI.
Translation for: **[English](https://github.com/alisonbuss/quickstart-drone-ci/blob/master/README_LANG_EN.md)**.

## Quickstart of a Continuous Delivery service (Drone CI) with Gitea and Traefik(v2. *), using Docker Compose and Swarm.

### 状态：（开发中）.

> **查看有关Docker环境的常规信息**.

docker image ls && docker network ls && docker volume ls && docker container ls;

> **验证并预览合成文件**.

docker-compose --file ./docker-compose.yml config;

> **创建或重建服务并并行构建映像**.

docker-compose --file ./docker-compose.yml build --parallel;

> **# 以分离模式创建或重建服务.**
docker-compose --file ./docker-compose.yml up --detach;

> **列出所有Compose容器**.
docker-compose --file ./docker-compose.yml ps;

# Imprimir a versão do Traefik em atividade.
docker exec <"OBTENHA O ID DO COMANDO ANTERIOR"> traefik version;


> **打印活动的Traefik日志**

```bash
docker exec <"ID container> cat /var/log/traefik/traefik.log;

docker exec <"ID container"> ls /var/log/postgresql

docker exec 823 ls /var/log/postgresql

docker exec gitea_server gitea version
docker exec gitea_server gitea --version

docker exec gitea_server gitea admin auth list

docker exec gitea_server gitea doctor


docker exec <"ID container"> /var/lib/gitea admin auth list 

docker exec 5e gitea auth list    

docker exec -it 5e "bash"

```

> **测试应用程序是否正常运行**.

curl -H Host:whoami.docker.localhost https://127.0.0.1 --insecure;

> **停止并删除容器，网络，映像和卷**.

docker-compose --file ./docker-compose.yml down;
docker-compose --file ./docker-compose.yml rm -f;

> **在环境中清洁：此命令删除所有停止的容器，未使用的网络，挂起的映像和构建缓存..**.

docker system prune -a;

**...**

docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) && docker rmi $(docker images -q);

docker container stop
docker container prune
docker volume prune
docker image prune
docker network prune


e8dff3df-218c-40a2-9022-a1ba67ab3269

https://gitea.docker.localhost/login/oauth/authorize?client_id=e8dff3df-218c-40a2-9022-a1ba67ab3269&redirect_uri=https%3A%2F%2Fdroneserver.docker.localhost%2Flogin&response_type=code&state=4d65822107fcfd52



https://community.containo.us/t/routing-ssh-traffic-with-traefik-v2/717/12


https://developer.okta.com/blog/2017/10/11/developers-guide-to-docker-part-3

https://blog.anoff.io/2019-03-24-self-hosted-gitea-drone/


https://github.com/hamdouni/gitea-drone/blob/master/docker-compose.yml
https://www.reddit.com/r/docker/comments/cv689q/connection_refused_when_cloning_from_gitea_in_the/

https://blog.anoff.io/2019-03-24-self-hosted-gitea-drone/

https://www.optimadata.nl/blogs/3/nlm8ci-how-to-run-postgres-on-docker-part-3

https://www.depesz.com/2011/05/06/understanding-postgresql-conf-log/


https://www.reddit.com/r/Traefik/comments/dk1rsj/trying_to_configure_traefic_as_proxy_to_gitea_but/

https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html#traefik


### References:

* Docker - Official Site, Docker Documentation. ***Docker overview*** <br/>
  Accessed: *December de 2019* <br/>
  Available: *[https://docs.docker.com/engine/docker-overview/](https://docs.docker.com/engine/docker-overview/)*

* Docker Compose - Official Site, Docker Compose Documentation. ***Docker Compose File*** <br/>
  Accessed: *December de 2019* <br/>
  Available: *[https://docs.docker.com/compose/compose-file/](https://docs.docker.com/compose/compose-file/)*

* Traefik - Official Site, Traefik Documentation. ***Configuration Introduction - How the Magic Happens*** <br/>
  Accessed: *December de 2019* <br/>
  Available: *[https://docs.traefik.io/getting-started/configuration-overview/](https://docs.traefik.io/getting-started/configuration-overview/)*


### License

[<img width="190" src="https://raw.githubusercontent.com/alisonbuss/my-licenses/master/files/logo-open-source-550x200px.png">](https://opensource.org/licenses)
[<img width="166" src="https://raw.githubusercontent.com/alisonbuss/my-licenses/master/files/icon-license-mit-500px.png">](https://github.com/alisonbuss/quickstart-drone-ci/blob/master/LICENSE)

