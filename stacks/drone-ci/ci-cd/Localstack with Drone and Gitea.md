

.drone.yml

```yaml
---
kind: pipeline
type: docker
name: localstack

platform:
  os: linux
  arch: amd64

steps:
  - name: wait-for-localstack
    image: ruanbekker/curl
    commands:
      - |
      for attempt in $(seq 1 60); 
      do 
        status=$(curl --max-time 1 --fail --silent http://localstack:4568/health | jq -r .services.s3)
        if [[ $status == "running" ]]
          then 
            echo localstack services is in a running state
            exit 0
        fi
      sleep 1
      echo localstack services busy starting
      done

  - name: list-kinesis-streams
    image: ruanbekker/awscli
    environment:
      AWS_ACCESS_KEY_ID: 123
      AWS_SECRET_ACCESS_KEY: xyz
      AWS_DEFAULT_REGION: eu-west-1
    commands:
      - aws --endpoint-url=http://localstack:4568 kinesis list-streams
      
  - name: create-kinesis-streams
    image: ruanbekker/awscli
    environment:
      AWS_ACCESS_KEY_ID: 123
      AWS_SECRET_ACCESS_KEY: xyz
      AWS_DEFAULT_REGION: eu-west-1
    commands:
      - aws --endpoint-url=http://localstack:4568 kinesis create-stream --stream-name mystream --shard-count 1

  - name: describe-kinesis-streams
    image: ruanbekker/awscli
    environment:
      AWS_ACCESS_KEY_ID: 123
      AWS_SECRET_ACCESS_KEY: xyz
      AWS_DEFAULT_REGION: eu-west-1
    commands:
      - aws --endpoint-url=http://localstack:4568 kinesis describe-stream --stream-name mystream

  - name: put-record-into-kinesis
    image: ruanbekker/awscli
    environment:
      AWS_ACCESS_KEY_ID: 123
      AWS_SECRET_ACCESS_KEY: xyz
      AWS_DEFAULT_REGION: eu-west-1
    commands: 
      - for record in $$(seq 1 100); do aws --endpoint-url=http://localstack:4568 kinesis put-record --stream-name mystream --partition-key 123 --data testdata_$$record ; done
        
  - name: get-record-from-kinesis
    image: ruanbekker/awscli
    environment:
      AWS_ACCESS_KEY_ID: 123
      AWS_SECRET_ACCESS_KEY: xyz
      AWS_DEFAULT_REGION: eu-west-1
    commands:
      - SHARD_ITERATOR=$$(aws --endpoint-url=http://localstack:4568 kinesis get-shard-iterator --shard-id shardId-000000000000 --shard-iterator-type TRIM_HORIZON --stream-name mystream --query 'ShardIterator' --output text)
      - for each in $$(aws --endpoint-url=http://localstack:4568 kinesis get-records --shard-iterator $$SHARD_ITERATOR | jq -cr '.Records[].Data'); do echo $each | base64 -d ; echo "" ; done

  - name: delete-kinesis-stream
    image: ruanbekker/awscli
    environment:
      AWS_ACCESS_KEY_ID: 123
      AWS_SECRET_ACCESS_KEY: xyz
      AWS_DEFAULT_REGION: eu-west-1
    commands:
      - aws --endpoint-url=http://localstack:4568 kinesis delete-stream --stream-name mystream

services:
  - name: localstack
    image: localstack/localstack
    privileged: true
    environment:
      DATA_DIR: /tmp/localstack/data
      DOCKER_HOST: unix:///var/run/docker.sock
      EDGE_PORT: "4568"
    volumes:
      - name: docker-socket
        path: /var/run/docker.sock
      - name: localstack-vol
        path: /tmp/localstack
    ports:
      - 8080

volumes:
- name: localstack-vol
  temp: {}
- name: docker-socket
  host:
    path: /var/run/docker.sock  
```

docker-compose.yml

```yml
version: "3.7"

services:
  gitea:
    image: gitea/gitea:latest
    container_name: gitea
    environment:
      - APP_NAME=Gitea
      - USER_UID=1000
      - USER_GID=1000
      # ensure to set gitea and drone to 127.0.0.1 on your hosts entry
      - ROOT_URL=http://gitea:3000
      - SSH_DOMAIN=gitea
      - SSH_PORT=2222
      - HTTP_PORT=3000
      - DB_TYPE=postgres
      - DB_HOST=gitea-db:5432
      - DB_NAME=gitea
      - DB_USER=postgres
      - DB_PASSWD=postgres
    restart: always
    volumes:
      - gitea:/data
    ports:
      - "3000:3000"
      - "2222:22"
    networks:
      - appnet

  gitea-db:
    image: postgres:alpine
    container_name: gitea-db
    restart: always
    volumes:
      - gitea-db:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=gitea
    networks:
      - appnet

  drone-server:
    image: drone/drone:1.2.1
    container_name: drone-server
    ports:
      - 80:80
      - 9000
    volumes:
      - drone:/var/lib/drone/
    restart: always
    depends_on:
      - gitea
    environment:
      - DRONE_OPEN=true
      - DRONE_GITEA=true
      - DRONE_NETWORK=appnet
      - DRONE_DEBUG=true
      - DRONE_ADMIN=rbekker87
      - DRONE_USER_CREATE=username:rbekker87,admin:true
      - DRONE_SERVER_PORT=:80
      - DRONE_DATABASE_DRIVER=postgres
      - DRONE_DATABASE_DATASOURCE=postgres://postgres:postgres@gitea-db:5432/postgres?sslmode=disable
      - DRONE_GIT_ALWAYS_AUTH=false
      - DRONE_GITEA_SERVER=http://gitea:3000
      - DRONE_RPC_SECRET=9c3921e3e748aff725d2e16ef31fbc42
      - DRONE_SERVER_HOST=drone-server:80
      - DRONE_HOST=http://drone-server:80
      - DRONE_SERVER_PROTO=http
      - DRONE_TLS_AUTOCERT=false
      - DRONE_AGENTS_ENABLED=true
    networks:
      - appnet

  drone-agent:
    image: drone/agent:1.2.1
    container_name: drone-agent
    command: agent
    restart: always
    depends_on:
      - drone-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - drone-agent:/data
    environment:
      - DRONE_RPC_SERVER=http://drone-server:80
      - DRONE_RPC_SECRET=9c3921e3e748aff725d2e16ef31fbc42
      - DRONE_RUNNER_CAPACITY=1
      - DRONE_RUNNER_NETWORKS=appnet
    networks:
      - appnet

volumes:
  gitea: {}
  gitea-db: {}
  drone: {}
  drone-agent: {}

networks:
  appnet:
    name: appnet

```

[https://gist.github.com/ruanbekker/84cb9f0c2a21434ca8381a0c74842d84](https://gist.github.com/ruanbekker/84cb9f0c2a21434ca8381a0c74842d84)

-------

drone-multi-pipeline

example1.yml
```yaml
kind: pipeline
name: frontend

steps:
- name: build
  image: alpine
  group: one
  commands:
  - sleep 10
  - echo done
  - date

- name: build2
  image: alpine
  group: one
  commands:
  - sleep 10
  - echo done
  - date

---
kind: pipeline
name: backend

steps:
- name: build
  image: alpine
  commands:
  - sleep 10
  - echo done
  - date

services:
- name: redis
  image: redis
  ports:
  - 6379
  
- name: mongo
  image: mongo:4
  command: [ --smallfiles ]
  ports:
  - 27017

- name: test-mongodb
  image: mongo:4
  commands:
  - sleep 5
  - mongo --host mongo --eval "db.version()"

- name: test-redis
  image: redis
  commands:
  - sleep 5
  - redis-cli -h redis ping
  - redis-cli -h redis set FOO bar
  - redis-cli -h redis get FOO

---
kind: pipeline
name: after

steps:
- name: notify
  image: alpine
  commands:
  - sleep 10
  - echo done
  - date

depends_on:
- frontend
- backend
```