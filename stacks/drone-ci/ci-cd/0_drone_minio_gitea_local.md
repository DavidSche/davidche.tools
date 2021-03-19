# Drone, Minio, Gitea, Sqlite on Docker Compose
0_drone_minio_gitea_local.md

docker-compose.yml

```yml
version: '3.6'

services:
  minio:
    image: minio/minio:RELEASE.2020-01-03T19-12-21Z
    container_name: minio
    volumes:
      - ./minio:/data
    ports:
      - "9000:9000"
    environment:
      - MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
      - MINIO_SECRET_KEY=${MINIO_SECRET_KEY}
    entrypoint: sh
    command: -c 'mkdir -p /data/drone && /usr/bin/minio server /data'
    networks:
      - cicd_net

  gitea:
    container_name: gitea
    image: gitea/gitea:${GITEA_VERSION:-1.13.3}
    restart: unless-stopped
    environment:
      # https://docs.gitea.io/en-us/install-with-docker/#environments-variables
      - USER_UID=1000
      - USER_GID=1000
      - RUN_MODE=prod
      - ROOT_URL=http://${IP_ADDRESS}:3000
      - SSH_PORT=222
      - SSH_LISTEN_PORT=222
      - SSH_DOMAIN=${IP_ADDRESS}
      - HTTP_PORT=3000
      - DB_TYPE=sqlite3
    ports:
      - "3000:3000"
      - "222:22"
    networks:
      - cicd_net
    volumes:
      - ./gitea:/data

  drone:
    container_name: drone
    image: drone/drone:${DRONE_VERSION:-1.6.4}
    restart: unless-stopped
    depends_on:
      - gitea
    environment:
      - DRONE_DATABASE_DRIVER=sqlite3
      - DRONE_DATABASE_DATASOURCE=/data/database.sqlite
      - DRONE_GITEA_SERVER=http://${IP_ADDRESS}:3000/
      - DRONE_GIT_ALWAYS_AUTH=false
      - DRONE_RPC_SECRET=${DRONE_RPC_SECRET}
      - DRONE_RUNNER_CAPACITY=2
      - DRONE_SERVER_PROTO=http
      - DRONE_SERVER_HOST=${IP_ADDRESS}:3001
      - DRONE_TLS_AUTOCERT=false
      - DRONE_NETWORK=cicd_net
      - DRONE_RUNNER_NETWORKS=cicd_net
      - DRONE_LOGS_DEBUG=true
      - DRONE_LOGS_TEXT=true
      - DRONE_LOGS_PRETTY=true
      - DRONE_LOGS_COLOR=true
      - DRONE_USER_CREATE=${DRONE_USER_CREATE}
      - DRONE_S3_ENDPOINT=http://minio:9000
      - DRONE_S3_BUCKET=drone
      - DRONE_S3_SKIP_VERIFY=true
      - DRONE_S3_PATH_STYLE=true
      - AWS_ACCESS_KEY_ID=${MINIO_ACCESS_KEY}
      - AWS_SECRET_ACCESS_KEY=${MINIO_SECRET_KEY}
      - AWS_DEFAULT_REGION=us-east-1
      - AWS_REGION=us-east-1
      - DRONE_GITEA_CLIENT_ID=${DRONE_GITEA_CLIENT_ID}
      - DRONE_GITEA_CLIENT_SECRET=${DRONE_GITEA_CLIENT_SECRET}
    ports:
      - "3001:80"
      - "9001:9000"
    networks:
      - cicd_net
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./drone:/data

  drone-agent:
    container_name: runner
    image: drone/drone-runner-docker:${DRONE_RUNNER_VERSION:-1}
    restart: unless-stopped
    depends_on:
      - drone
    environment:
      - DRONE_RPC_PROTO=http
      - DRONE_RPC_HOST=drone
      - DRONE_RPC_SECRET=${DRONE_RPC_SECRET}
      - DRONE_RUNNER_NAME=${HOSTNAME}
      - DRONE_RUNNER_CAPACITY=2
      - DRONE_NETWORK=cicd_net
      - DRONE_RUNNER_NETWORKS=cicd_net
      - DRONE_LOGS_DEBUG=true
      - DRONE_LOGS_TEXT=true
      - DRONE_LOGS_PRETTY=true
      - DRONE_LOGS_COLOR=true
      - DRONE_LOGS_TRACE=true
    ports:
      - "3002:3000"
    networks:
      - cicd_net
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

networks:
  cicd_net:
    name: cicd_net

```

 deploy.sh

```shell
export HOSTNAME=$(hostname)
export DRONE_VERSION=1.10.1
export DRONE_RUNNER_VERSION=1.6.3
export GITEA_VERSION=1.13
export IP_ADDRESS=
export MINIO_ACCESS_KEY="EXAMPLEKEY"
export MINIO_SECRET_KEY="EXAMPLESECRET"
export DRONE_RPC_SECRET="43a21afa1cbe04127d1b57387c17ab9a"
export DRONE_USER_CREATE="username:rbekker87,machine:false,admin:true,token:${DRONE_RPC_SECRET}"
export DRONE_GITEA_CLIENT_ID=""
export DRONE_GITEA_CLIENT_SECRET=""
docker-compose up -d
```


Steps:

 1. create a DRONE_RPC_SECRET with ***openssl rand -hex 16*** and update start.sh, get the ip address and replace ***start.sh***
 2. run ***bash start.sh***, finish registration, restart gitea (for twice trigger issue
 3. Head over to http://${IP_ADDRESS}:3000/user/settings/applications create the application for drone and redirect uri will be http://${IP_ADDRESS}:3001/login
 4. capture the client id and client secret and replace into ***start.sh***

 5.run ***bash start.sh*** again

Once your repo has been configured create a .drone.yml:

```yml
kind: pipeline
name: hello-world
type: docker
steps:
  - name: say-hello
    image: busybox
    commands:
      - echo hello-world
```

  > Known issues: triggers twice (no issue on: GITEA_VERSION=1.10.6, to fix, restart gitea)

[https://gist.github.com/ruanbekker/3847bbf1b961efc568b93ccbf5c6f9f6](https://gist.github.com/ruanbekker/3847bbf1b961efc568b93ccbf5c6f9f6)


