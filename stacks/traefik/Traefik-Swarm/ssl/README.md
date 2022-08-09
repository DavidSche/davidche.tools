# Docker Swarm with Traefik

## Traefik with Let's Encrypt in a Docker Swarm

Install the Docker Engine by following the official guide: [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

Install the Docker Swarm by following the official guide: <https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/>

- Create a network for Traefik before deploying the configuration using the command:

```shell
docker network create -d overlay traefik-network

```

- Deploy Traefik in a Docker Swarm using the command:

```shell
docker stack deploy -c traefik-letsencrypt-docker-swarm.yml traefik
```

## Portainer with Let's Encrypt in a Docker Swarm

Configure Traefik before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-letsencrypt-docker-swarm>

Deploy Portainer in a Docker Swarm using the command:

```shell
docker stack deploy -c portainer-traefik-letsencrypt-docker-swarm.yml portainer
```

## Portainer with SSL Certificate in a Docker Swarm

Configure Traefik before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-ssl-certificate-docker-swarm>

Deploy Portainer in a Docker Swarm using the command:

```shell
docker stack deploy -c portainer-traefik-ssl-certificate-docker-swarm.yml portainer
```

## Gitea with SSL Certificate in a Docker Swarm

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-ssl-certificate-docker-swarm>

Run ***gitea-restore-application-data.sh*** on the Docker Swarm worker node where the container for backups is running to restore application data if needed.

Run ***gitea-restore-database.sh*** on the Docker Swarm node where the container for backups is running to restore database if needed.

Run ***docker stack ps gitea | grep gitea_backups | awk 'NR > 0 {print $4}'*** on the Docker Swarm manager node to find on which node container for backups is running.

Deploy Gitea in a Docker Swarm using the command:

```shell
docker stack deploy -c gitea-traefik-ssl-certificate-docker-swarm.yml gitea
```

## Gitea with Let's Encrypt in a Docker Swarm

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-letsencrypt-docker-swarm>

Run ***gitea-restore-application-data.sh*** on the Docker Swarm worker node where the container for backups is running to restore application data if needed.

Run ***gitea-restore-database.sh*** on the Docker Swarm node where the container for backups is running to restore database if needed.

Run ***docker stack ps gitea | grep gitea_backups | awk 'NR > 0 {print $4}'*** on the Docker Swarm manager node to find on which node container for backups is running.

Deploy Gitea in a Docker Swarm using the command:

```shell
docker stack deploy -c gitea-traefik-letsencrypt-docker-swarm.yml gitea
```

## Confluence with Let's Encrypt in a Docker Swarm

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-letsencrypt-docker-swarm>

Create a secret for storing the password for Confluence database using the command:

```shell
printf "YourPassword" | docker secret create confluence-postgres-password -
```

Clear passwords from bash history using the command:

```shell
history -c && history -w
```

Run ***confluence-restore-application-data.sh*** on the Docker Swarm worker node where the container for backups is running to restore application data if needed.

Run ***confluence-restore-database.sh*** on the Docker Swarm node where the container for backups is running to restore database if needed.

Run ***docker stack ps confluence | grep confluence_backups | awk 'NR > 0 {print $4}'*** on the Docker Swarm manager node to find on which node container for backups is running.

Deploy Confluence in a Docker Swarm using the command:

```shell
docker stack deploy -c confluence-traefik-letsencrypt-docker-swarm.yml confluence
```

## Confluence with SSL Certificate in a Docker Swarm

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-ssl-certificate-docker-swarm>

Create a secret for storing the password for Confluence database using the command:

```shell
printf "YourPassword" | docker secret create confluence-postgres-password -
```

Clear passwords from bash history using the command:

```shell
history -c && history -w
```

Run ***confluence-restore-application-data.sh*** on the Docker Swarm worker node where the container for backups is running to restore application data if needed.

Run ***confluence-restore-database.sh*** on the Docker Swarm node where the container for backups is running to restore database if needed.

Run ***docker stack ps confluence | grep confluence_backups | awk 'NR > 0 {print $4}'*** on the Docker Swarm manager node to find on which node container for backups is running.

Deploy Confluence in a Docker Swarm using the command:

```shell
docker stack deploy -c confluence-traefik-ssl-certificate-docker-swarm.yml confluence
```

## Jira with Let's Encrypt in a Docker Swarm

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-letsencrypt-docker-swarm>

Create a secret for storing the password for Jira database using the command:

```shell
printf "YourPassword" | docker secret create jira-postgres-password -
```

Clear passwords from bash history using the command:

```shell
history -c && history -w
```

Run ***jira-restore-application-data.sh*** on the Docker Swarm worker node where the container for backups is running to restore application data if needed.

Run ***jira-restore-database.sh*** on the Docker Swarm node where the container for backups is running to restore database if needed.

Run ***docker stack ps jira | grep jira_backups | awk 'NR > 0 {print $4}'*** on the Docker Swarm manager node to find on which node container for backups is running.

Deploy Jira in a Docker Swarm using the command:

```shell
docker stack deploy -c jira-traefik-letsencrypt-docker-swarm.yml jira
```

## GitLab with SSL Certificate in a Docker Swarm

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-ssl-certificate-docker-swarm>

Create a secret for storing the password for GitLab administrator using the command:

```shell
printf "YourPassword" | docker secret create gitlab-application-password -
```

Create a secret for storing the token for GitLab Runner using the command:

```shell
printf "YourToken" | docker secret create gitlab-runnner-token -
```

Clear passwords from bash history using the command:

```shell
history -c && history -w
```

Create a secret for storing the GitLab configuration using the command:

```shell
docker secret create gitlab.rb /path/to/gitlab.rb
```

Run ***gitlab-restore-application-data.sh*** on the Docker Swarm worker node where the container for backups is running to restore application data if needed.

Run ***docker stack ps gitlab | grep gitlab_backup | awk 'NR > 0 {print $4}'*** on the Docker Swarm manager node to find on which node container for backups is running.

Deploy GitLab in a Docker Swarm using the command:

```shell
docker stack deploy -c gitlab-traefik-ssl-certificate-docker-swarm.yml gitlab
```

Register the GitLab Runner on the Docker Swarm worker node using the command:

```shell
GITLAB_RUNNER_CONTAINER_1=$(docker ps -aqf "name=gitlab-runner") \
&& docker container exec -it $GITLAB_RUNNER_CONTAINER_1 sh -c 'REGISTRATION_TOKEN="$(cat /run/secrets/gitlab-runnner-token)" \
&& gitlab-runner register \
--non-interactive \
--url "https://gitlab.heyvaldemar.net/" \
--registration-token "$REGISTRATION_TOKEN" \
--executor "docker" \
--docker-image docker:19.03 \
--description "docker-runner-1" \
--tag-list "docker" \
--run-untagged="true" \
--locked="false" \
--docker-privileged \
--docker-cert-path /etc/gitlab-runner \
--tls-ca-file "/etc/docker-runner/certs/gitlab.heyvaldemar.net.crt" \
--docker-volumes "/certs/client" \
--output-limit "50000000" \
--access-level="not_protected"'
```
Run ***docker stack ps gitlab | grep gitlab_gitlab-runner | awk 'NR > 0 {print $4}'*** on the Docker Swarm manager node to find on which node container for GitLab Runner is running.

Login to the Container Registry using GitLab credentials:

```shell
docker login registry.heyvaldemar.net
```

## Keycloak with Amazon RDS and Let's Encrypt in a Docker Swarm

Create Amazon RDS database instance, configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-letsencrypt-docker-swarm>

Create a secret for storing the password for Keycloak database using the command:

```shell
printf "YourPassword" | docker secret create keycloak-postgres-password -
```

Create a secret for storing the password for Keycloak administrator using the command:

```shell
printf "YourPassword" | docker secret create keycloak-application-password -
```

Clear passwords from bash history using the command:

```shell
history -c && history -w
```

Deploy Keycloak in a Docker Swarm using the command:

```shell
docker stack deploy -c keycloak-traefik-letsencrypt-rds-docker-swarm.yml keycloak
```

## Grafana with SSL Certificate in a Docker Swarm

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-ssl-certificate-docker-swarm>

Create a secret for storing the password for Grafana database using the command:

```shell
printf "YourPassword" | docker secret create grafana-postgres-password -
```

Create a secret for storing the password for Grafana administrator using the command:

```shell
printf "YourPassword" | docker secret create grafana-application-password -
```

Create a secret for storing the password for Grafana email account using the command:

```shell
printf "YourPassword" | docker secret create grafana-email-password -
```

Clear passwords from bash history using the command:

```shell
history -c && history -w
```

Create a secret for storing the Grafana configuration using the command:

```shell
docker secret create ldap.toml /path/to/ldap.toml
```

Run ***grafana-restore-application-data.sh*** on the Docker Swarm worker node where the container for backups is running to restore application data if needed.

Run ***docker stack ps grafana | grep grafana_backup | awk 'NR > 0 {print $4}'*** on the Docker Swarm manager node to find on which node container for backups is running.

Deploy Grafana in a Docker Swarm using the command:

```shell
docker stack deploy -c grafana-traefik-ssl-certificate-docker-swarm.yml grafana
```

## Keycloak with SSL Certificate in a Docker Swarm

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-ssl-certificate-docker-swarm>

Create a secret for storing the password for Keycloak database using the command:

```shell
printf "YourPassword" | docker secret create keycloak-postgres-password -
```

Create a secret for storing the password for Keycloak administrator using the command:

```shell
printf "YourPassword" | docker secret create keycloak-application-password -
```

Clear passwords from bash history using the command:

```shell
history -c && history -w
```

Run keycloak-restore-database.sh on the Docker Swarm node where the container for backups is running to restore database if needed.

Run docker stack ps keycloak | grep keycloak_backups | awk 'NR > 0 {print $4}' on the Docker Swarm manager node to find on which node container for backups is running.

Deploy Keycloak in a Docker Swarm using the command:

```shell
docker stack deploy -c keycloak-traefik-ssl-certificate-docker-swarm.yml keycloak
```

## Keycloak with Let's Encrypt in a Docker Swarm

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-letsencrypt-docker-swarm>

Create a secret for storing the password for Keycloak database using the command:

```shell
printf "YourPassword" | docker secret create keycloak-postgres-password -
```

Create a secret for storing the password for Keycloak administrator using the command:

```shell
printf "YourPassword" | docker secret create keycloak-application-password -
```

Clear passwords from bash history using the command:

```shell
history -c && history -w
```

Run ***keycloak-restore-database.sh*** on the Docker Swarm node where the container for backups is running to restore database if needed.

Run ***docker stack ps keycloak | grep keycloak_backups | awk 'NR > 0 {print $4}'*** on the Docker Swarm manager node to find on which node container for backups is running.

Deploy Keycloak in a Docker Swarm using the command:

```shell
docker stack deploy -c keycloak-letsencrypt-docker-swarm.yml keycloak
```

## Zabbix with SSL Certificate in a Docker Swarm

Configure Traefik and create secrets for storing the passwords on the Docker Swarm manager node before applying the configuration.

Traefik configuration: <https://github.com/heyValdemar/traefik-ssl-certificate-docker-swarm>

Create a secret for storing the password for Zabbix database using the command:

```shell
printf "YourPassword" | docker secret create zabbix-postgres-password -
```

Clear passwords from bash history using the command:

```shell
history -c && history -w
```

Run ***zabbix-restore-database.sh*** on the Docker Swarm node where the container for backups is running to restore database if needed.

Run ***docker stack ps zabbix | grep zabbix_backups | awk 'NR > 0 {print $4}'*** on the Docker Swarm manager node to find on which node container for backups is running.

Deploy Zabbix in a Docker Swarm using the command:

```shell
docker stack deploy -c zabbix-traefik-ssl-certificate-docker-swarm.yml zabbix
```
