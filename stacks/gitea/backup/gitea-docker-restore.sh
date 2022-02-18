#!/bin/sh
# Gitea data restore script (docker)
# Usage: ./restore.sh gitea-dump-1617385736.zip DockerIdOrDockerName

BACKUP_FILE=$1
#CONTAINER_NAME=$2
CONTAINER=git_gitea_server
CONTAINER_NAME=$(docker ps -qf "name=$CONTAINER")

if [ -f "$BACKUP_FILE" ]; then
    if [ ! -z "$CONTAINER_NAME" -a "$CONTAINER_NAME" != " " ]; then
        docker cp $BACKUP_FILE $CONTAINER_NAME:/tmp
        docker exec -it $CONTAINER_NAME unzip /tmp/$BACKUP_FILE -d /tmp/
        docker exec -it $CONTAINER_NAME rm -rf /data/gitea
        docker exec -it $CONTAINER_NAME rm -rf /data/git/repositories
        docker exec -it $CONTAINER_NAME mv /tmp/data /data/gitea
        docker exec -it $CONTAINER_NAME mv /tmp/app.ini /data/gitea/conf/app.ini
        docker exec -it $CONTAINER_NAME mv /tmp/repos /data/git/repositories
        docker exec -it $CONTAINER_NAME chown -R git:git /data/git
        docker exec -it $CONTAINER_NAME chown -R git:git /data/gitea
        docker exec -it $CONTAINER_NAME rm -rf /tmp/*
        docker restart $CONTAINER_NAME
        exit 0;
    else
        echo "Docker container [$CONTAINER_NAME] does not exist.";
        exit 1;
    fi
else
    echo "Backup file [$BACKUP_FILE] does not exist."
    exit 1;
fi