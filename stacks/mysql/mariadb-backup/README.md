# mariadb-backup

```bash
docker run --name 161-backup -e DB_HOST=192.168.9.21 -e DB_PORT=3306 -e DB_PASS=CQY@mass2019 -v /home/mysql_backups/9-161:/backup ixdotai/mariadb-backup:latest

docker run --name 161-mysqlbackup -e DB_HOST=192.168.6.161 -e DB_PORT=3306 -e DB_PASS=CQY@mass2019 -v /home/mysql_backups/161:/backup 192.168.9.10:5000/mysql-backup:latest
```

[![Pipeline Status](https://gitlab.com/ix.ai/mariadb-backup/badges/master/pipeline.svg)](https://gitlab.com/ix.ai/mariadb-backup/)
[![Docker Stars](https://img.shields.io/docker/stars/ixdotai/mariadb-backup.svg)](https://hub.docker.com/r/ixdotai/mariadb-backup/)
[![Docker Pulls](https://img.shields.io/docker/pulls/ixdotai/mariadb-backup.svg)](https://hub.docker.com/r/ixdotai/mariadb-backup/)
[![Gitlab Project](https://img.shields.io/badge/GitLab-Project-554488.svg)](https://gitlab.com/ix.ai/mariadb-backup/)

The mariadb-backup Docker image will provide you a container to backup and restore a [MySQL](https://hub.docker.com/_/mysql/) or [MariaDB](https://hub.docker.com/_/mariadb/) database container.

The backup is made with [mydumper](http://centminmod.com/mydumper.html), a fast MySQL backup utility.

## Usage

To backup a [MySQL](https://hub.docker.com/_/mysql/) or [MariaDB](https://hub.docker.com/_/mariadb/) database, you simply specify the credentials and the host. You can optionally specify the database as well.

## Environment variables
| **Variable**  | **Default** | **Mandatory** | **Description**                                      |
|:--------------|:-----------:|:-------------:|:-----------------------------------------------------|
| `DB_HOST`     | -           | *yes*         | The host to connect to                               |
| `DB_PASS`     | -           | *yes*         | The password for the SQL server                      |
| `DB_NAME`     | -           | *no*          | If specified, only this database will be backed up   |
| `DB_PORT`     | `3306`      | *no*          | The port of the SQL server                           |
| `DB_USER`     | `root`      | *no*          | The user to connect to the SQL server                |
| `MODE`        | `BACKUP`    | *no*          | One of `BACKUP` or `RESTORE`                         |
| `BASE_DIR`    | `/backup`   | *no*          | Path of the base directory (aka working directory)   |
| `RESTORE_DIR` | -           | *no*          | Name of a backup directory to restore                |
| `BACKUP_UID`  | `666`       | *no*          | UID of the backup                                    |
| `BACKUP_GID`  | `666`       | *no*          | GID of the backup                                    |
| `UMASK`       | `0022`      | *no*          | Umask which should be used to write the backup files |
| `OPTIONS`     | `-c` / `-o` | *no*          | Options passed to `mydumper` / `myloader`            |

Please note the backup will be written to `/backup` by default, so you might want to mount that directory from your host.

## Example Docker CLI client

To __create a backup__ from a MySQL container via `docker` CLI client:

```bash
docker run --name my-backup -e DB_HOST=mariadb -e DB_PASS=amazing_pass -v /var/mysql_backups:/backup ixdotai/mariadb-backup:latest
```

The container will stop automatically as soon as the backup has finished.
To create more backups in the future simply start your container again:

```bash
docker start my-backup
```

To __restore a backup__ into a MySQL container via `docker` CLI client:

```bash
docker run --name my-restore -e DB_HOST=mariadb -e DB_PASS=amazing_pass -v /var/mysql_backups:/backup ixdotai/mariadb-backup:latest
```

## Script example
The following example uses the image []() for MariaDB.
To back up multiple databases, all running in docker, all labeled with `mariadb-backup`:
```bash
#!/usr/bin/env bash
/bin/mkdir -p /mariadb-backup

/usr/bin/docker pull ixdotai/mariadb-backup:latest

for CONTAINER in $(/usr/bin/docker ps -f label=mariadb-backup --format='{{.Names}}'); do
  DB_PASS=$(/usr/bin/docker inspect ${CONTAINER}|/usr/bin/jq -r '.[0]|.Config.Env[]|select(test("^MARIADB_ROOT_PASSWORD.*"))'|/bin/sed -n 's/^MARIADB_ROOT_PASSWORD=\(.*\)/\1/p')
  DB_NAME=$(/usr/bin/docker inspect ${CONTAINER}|/usr/bin/jq -r '.[0]|.Config.Env[]|select(test("^MARIADB_DATABASE.*"))'|/bin/sed -n 's/^MARIADB_DATABASE=\(.*\)/\1/p')
  DB_NET=$(/usr/bin/docker inspect ${CONTAINER}|/usr/bin/jq -r '.[0]|.NetworkSettings.Networks|to_entries[]|.key')
  if [[ -n "${DB_PASS}" ]]; then
    /usr/bin/docker run --rm --name ${CONTAINER}-backup -e DB_PASS=${DB_PASS} -e DB_HOST=${CONTAINER} -e DB_NAME=${DB_NAME} --network ${DB_NET} -v /mariadb-backup:/backup ixdotai/mariadb-backup:latest
  fi
done

```

## Configuration


### Mode

By default the container backups the database.
However, you can change the mode of the container by setting the following environment variable:

* `MODE`: Sets the mode of the backup container while [`BACKUP`|`RESTORE`]

### Base directory

By default the base directory `/backup` is used.
However, you can overwrite that by setting the following environment variable:

* `BASE_DIR`: Path of the base directory (aka working directory)

### Restore directory

By default the container will automatically restore the latest backup found in `BASE_DIR`.
However, you can manually set the name of a backup directory underneath `BASE_DIR`:

* `RESTORE_DIR`: Name of a backup directory to restore

_This option is only required when the container runs in in `RESTORE` mode._

### UID and GID

By default the backup will be written with UID and GID `666`.
However, you can overwrite that by setting the following environment variables:

* `BACKUP_UID`: UID of the backup
* `BACKUP_GID`: GID of the backup

### umask

By default a `umask` of `0022` will be used.
However, you can overwrite that by setting the following environment variable:

* `UMASK`: Umask which should be used to write the backup files

### mydumper / myloader CLI options

By default `mydumper` is invoked with the `-c` (compress backup) and `myloader` with the `-o` (overwrite tables) CLI option.
However, you can modify the CLI options by setting the following environment variable:

* `OPTIONS`: Options passed to `mydumper` (when `MODE` is `BACKUP`) or `myloader` (when `MODE` is `RESTORE`)

## Tags and Arch

Starting with version v0.0.3, the images are multi-arch, with builds for amd64, arm64, armv7 and armv6.
* `vN.N.N` - for example v0.0.2
* `latest` - always pointing to the latest version
* `dev-master` - the last build on the master branch

## Resources:
* GitLab: https://gitlab.com/ix.ai/mariadb-backup
* GitHub: https://github.com/ix-ai/mariadb-backup
* Docker Hub: https://hub.docker.com/r/ixdotai/mariadb-backup

## Credits

Special thanks to [confirm/docker-mysql-backup](https://github.com/confirm/docker-mysql-backup), which this project uses heavily.
