# How to reset admin password in Grafana container

Post author By milosz

Post date December 11, 2019

## Reset admin password in Grafana Docker container.

![Grafana](grafana.png)

Grafana

List Docker containers.

```shell
$ docker ps
CONTAINER ID        IMAGE                   COMMAND             CREATED             STATUS              PORTS                    NAMES
c16ae5b49cd4        grafana/grafana:5.3.4   "/run.sh"           10 months ago       Up 28 minutes       0.0.0.0:3000->3000/tcp   grafana

```

Use grafana-cli to reset admin password.

```shell
$ docker exec -it c16ae5b49cd4 grafana-cli admin reset-admin-password newpassword
INFO[09-23|08:36:14] Connecting to DB                       logger=sqlstore dbtype=sqlite3
INFO[09-23|08:36:14] Starting DB migration                  logger=migrator

```
Admin password changed successfully ✔

Simple as that.



