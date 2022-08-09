#!/bin/bash

GITEA_BACKUPS_CONTAINER=$(docker ps -aqf "name=gitea_backups")

echo "--> All available application data backups:"

for entry in $(docker container exec -it $GITEA_BACKUPS_CONTAINER sh -c "ls /srv/gitea-application-data/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore application data and press [ENTER]
--> Example: gitea-application-data-backup-YYYY-MM-DD_hh-mm.tar.gz"
echo -n "--> "

read SELECTED_APPLICATION_BACKUP

echo "--> $SELECTED_APPLICATION_BACKUP was selected"

echo "--> Scaling service down..."
docker service scale gitea_gitea=0

echo "--> Restoring application data..."
docker exec -it $GITEA_BACKUPS_CONTAINER sh -c "rm -rf /etc/gitea/* && tar -zxpf /srv/gitea-application-data/backups/$SELECTED_APPLICATION_BACKUP -C /"
echo "--> Application data recovery completed..."

echo "--> Scaling service up..."
docker service scale gitea_gitea=1