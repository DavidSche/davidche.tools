# woodpecker-example-compose

I have a docker-compose.yml for you for a local setup of gitea and woodpecker. Put this into a new empty directory and follow instructions:

```
# installation:
# first only start the gitea and db: docker-compose up -d gitea gitea-db
# go to http://localhost:3000 and finish the gitea installation (create admin account, everything else can be left unchanged)
# then in gitea admin http://localhost:3000/user/settings/applications create new oauth application (not a token) for woodpecker: https://woodpecker-ci.org/docs/administration/forges/gitea#registration
# add "[webhook]" and "ALLOWED_HOST_LIST=private" into ./gitea-data/gitea/conf/app.ini (was created as a volume during docker-compose up)
# you may also already create a new empty git repository in gitea for testing
# put the oauth client id and secret to the woodpecker env variables in this docker-compose.yml
# stop gitea and start all services: docker-compose down; docker-compose up -d
# go to http://localhost:8000 and login to woodpecker, authorize the gitea access
# during the login woodpecker will redirect you to http://gitea:3000 which doesn't exist - just rewrite that to http://localhost:3000, it's caused by the lack of publicly reachable hostnames in this local setup
# click Add repository in woodpecker, Reload repositories if needed, it should show the new empty repository from gitea, click Enable
# this creates a new webhook in gitea, but we have to modify it again due to lack of publicly reachable urls - go to the repo in gitea, Settings (of the repo, not whole gitea) -> Webhooks, and edit the webook - change "http://localhost:8000/hook" into "http://woodpecker:8000/hook" (keep the access token)
# the webhook edit page also has a "Test delivery" button at the bottom - this can be used to trigger a build in woodpecker
# create a .woodpecker.yml in the test repo, press "Test delivery" in the webhook, and it should create a new job in woodpecker

services:
  gitea:
    image: gitea/gitea:1.16.7
    environment:
      - APP_NAME=Gitea
      - USER_UID=1000
      - USER_GID=1000
      - ROOT_URL=http://localhost:3000
      - SSH_DOMAIN=gitea.localhost
      - SSH_PORT=3022
      - SSH_LISTEN_PORT=3022
      - HTTP_PORT=3000
      - DB_TYPE=postgres
      - DB_HOST=gitea-db:5432
      - DB_NAME=gitea
      - DB_USER=postgres
      - DB_PASSWD=postgres
    restart: unless-stopped
    volumes:
      - ./gitea-data:/data
    ports:
      - 3000:3000
      - 3022:3022

  gitea-db:
    image: postgres:14-alpine
    restart: unless-stopped
    volumes:
      - ./gitea-db:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=gitea

  woodpecker-server:
    image: woodpeckerci/woodpecker-server:next-alpine
    volumes:
      - ./woodpecker-server-data:/var/lib/woodpecker/
    ports:
      - 8000:8000
    environment:
      - WOODPECKER_OPEN=true
      - WOODPECKER_HOST=http://localhost:8000
      - WOODPECKER_AGENT_SECRET=super-secret-agent-secret
      - WOODPECKER_GITEA=true
      - WOODPECKER_GITEA_URL=http://gitea:3000
      # put the oauth client id and secret from gitea here
      - WOODPECKER_GITEA_CLIENT=gitea-oauth-client-id
      - WOODPECKER_GITEA_SECRET=gitea-oauth-secret
      - WOODPECKER_LOG_LEVEL=debug
      - WOODPECKER_DEBUG_PRETTY=true
      - WOODPECKER_DEBUG_NOCOLOR=false

  woodpecker-agent:
    image: woodpeckerci/woodpecker-agent:next-alpine
    command: agent
    restart: always
    depends_on:
      - woodpecker-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - WOODPECKER_SERVER=woodpecker-server:9000
      - WOODPECKER_AGENT_SECRET=super-secret-agent-secret
      - WOODPECKER_LOG_LEVEL=debug
      - WOODPECKER_DEBUG_PRETTY=true
      - WOODPECKER_DEBUG_NOCOLOR=false
      - WOODPECKER_BACKEND=docker
      # this might be needed to reach gitea during git clone, just make sure the network name is correct, as it's generated based on your directory
      #- WOODPECKER_BACKEND_DOCKER_NETWORK=woodpecker_default