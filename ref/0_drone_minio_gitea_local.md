#  Drone, Minio, Gitea, Sqlite on Docker Compose

docker-compose.yml

```
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
      - MINIO_ACCESS_K                                                                                                          EY=${MINIO_ACCESS_KEY}
      - MINIO_SECRET_KEY=${MINIO_SECRET_KEY}
    command: server /data
    networks:
      - cicd_net

  gitea:
    container_name: gitea
    image: gitea/gitea:${GITEA_VERSION:-1.10.2}
    restart: unless-stopped
    environment:
      # https://docs.gitea.io/en-us/install-with-docker/#environments-variables
      - USER_UID=1000
      - USER_GID=1000
      - RUN_MODE=prod
      - ROOT_URL=http://${IP_ADDRESS}:3000
      - SSH_PORT=222
      - SSH_LISTEN_PORT=222
      - SSH_DOMAIN=localhost
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
      - DRONE_RPC_SECRET=super-duper-secret
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
    image: drone/drone-runner-docker:1
    restart: unless-stopped
    depends_on:
      - drone
    environment:
      - DRONE_RPC_PROTO=http
      - DRONE_RPC_HOST=drone
      - DRONE_RPC_SECRET=super-duper-secret
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

```
export DRONE_VERSION=1.6.4
export GITEA_VERSION=1.10.2
export IP_ADDRESS=192.168.0.101
export MINIO_ACCESS_KEY="EXAMPLEKEY"
export MINIO_SECRET_KEY="EXAMPLESECRET"
export DRONE_USER_CREATE="username:rbekker87,admin:true"
export DRONE_GITEA_CLIENT_ID=""
export DRONE_GITEA_CLIENT_SECRET=""
docker-compose up
```

