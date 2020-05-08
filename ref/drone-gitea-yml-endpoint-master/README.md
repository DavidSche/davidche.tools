## Usage example

.drone.yml:

```
kind: pipeline
name: drone-test

steps:

### ansible ###

- name: ansible-host1
  image: ansible/ansible-runner
  commands:
  - echo "ansible deploy here"
  - ansible --version
  when:
    message_contains:
    - ansible/host1

### docker ###

- name: step-without-custom-condition1
  image: alpine:latest
  commands:
  - echo "step_without_custom_condition1"

- name: build-app1
  image: osshelpteam/drone-docker-tcp
  settings:
    docker_host: 172.17.0.1
    registry: 172.17.0.1:5000
    repo: project/app1
    tags: [ latest, 1, 1.1.2 ]
    context: docker/app1
  when:
    message_contains:
    - docker/all
    - docker/app1

- name: test-app1
  image: alpine:latest
  commands:
  - echo "test-app1 step"
  when:
    message_contains:
    - docker/all
    - docker/app1

- name: deploy-app1
  image: alpine:latest
  commands:
  - echo "deploy-app1 step"
  when:
    message_contains:
    - docker/app1

- name: step-without-custom-condition2
  image: alpine:latest
  commands:
  - echo "step_without_custom_condition2"

- name: build-app2
  image: osshelpteam/drone-docker-tcp
  settings:
    docker_host: 172.17.0.1
    registry: 172.17.0.1:5000
    repo: project/app2
    tags: [ latest, 1, 1.1.2 ]
    context: docker/app2
  when:
    message_contains:
    - docker/all
    - docker/app2

- name: test-app2
  image: alpine:latest
  commands:
  - echo "test-app2 step"
  when:
    message_contains:
    - docker/all
    - docker/app2

- name: deploy-app2
  image: alpine:latest
  commands:
  - echo "deploy-app2 step"
  when:
    message_contains:
    - docker/app2

- name: step-without-custom-condition3
  image: alpine:latest
  commands:
  - echo "step_without_custom_condition3"

- name: deploy-all-apps-if-deploy-params-changed-or-redeploy-is-needed
  image: alpine:latest
  commands:
  - echo "deploy-all-apps-if-deploy-params-changed"
  when:
    message_contains:
    - docker/all
    - docker/stack-or-compose-name

### notifications

#- name: slack
#  image: plugins/slack
#  settings:
#    webhook:
#      from_secret: slack-webhook
#  when:
#    status: [ success, failure ]

```

## Deploy example

```
version: '3'
services:
  drone:
    container_name: drone
    image: drone/drone:1
    restart: always
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /mnt/data/drone:/data
    depends_on:
      - drone-yml-endpoint
    environment:
      DRONE_GITEA_SERVER: "http://gitea"
      DRONE_GIT_ALWAYS_AUTH: "true"
      DRONE_SERVER_HOST: "drone-ci"
      DRONE_SERVER_PROTO: "http"
      DRONE_TLS_AUTOCERT: "false"
      DRONE_LOGS_DEBUG: "true"
      DRONE_YAML_ENDPOINT: "http://drone-yml-endpoint:8080"
    networks:
      - net

  drone-yml-endpoint:
    container_name: drone-yml-endpoint
    image: osshelpteam/drone-gitea-yml-endpoint:latest
    restart: always
    environment:
      GITEA_HOST: "http://gitea"
      GITEA_TOKEN: "token"
    networks:
      - net

networks:
  net:

```