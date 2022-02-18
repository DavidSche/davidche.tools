#!/bin/bash

# This script creates a .zip backup of gitea running inside docker and copies the backup file to the current working directory
CONTAINER=git_gitea_server

echo "Creating gitea backup inside docker containter ..."
docker exec -u git -it -w /tmp $(docker ps -qf "name=$CONTAINER") bash -c '/app/gitea/gitea dump -c /data/gitea/conf/app.ini --file /tmp/gitea-dump.zip'

echo "Copying backup file from the container to the host machine ..."
docker cp $(docker ps -qf "name=$CONTAINER"):/tmp/gitea-dump.zip /tmp

echo "Removing backup file in container ..."
docker exec -u git -it -w /tmp $(docker ps -qf "name=$CONTAINER") bash -c 'rm /tmp/gitea-dump.zip'

echo "Renaming backup file ..."
BACKUPFILE=gitea-dump-$(date +"%Y%m%d%H%M").zip
mv /tmp/gitea-dump.zip $BACKUPFILE

echo "Backup file is available: "$BACKUPFILE

echo "Done."