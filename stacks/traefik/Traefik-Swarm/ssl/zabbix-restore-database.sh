#!/bin/bash

ZABBIX_BACKUPS_CONTAINER=$(docker ps -aqf "name=zabbix_backups")

echo "--> All available database backups:"

for entry in $(docker container exec -it $ZABBIX_BACKUPS_CONTAINER sh -c "ls /srv/zabbix-postgres/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore database and press [ENTER]
--> Example: zabbix-postgres-backup-YYYY-MM-DD_hh-mm.gz"
echo -n "--> "

read SELECTED_DATABASE_BACKUP

echo "--> $SELECTED_DATABASE_BACKUP was selected"

echo "--> Scaling service down..."
docker service scale zabbix_zabbix=0

echo "--> Restoring database..."
docker exec -it $ZABBIX_BACKUPS_CONTAINER sh -c 'PGPASSWORD="$(cat $POSTGRES_PASSWORD_FILE)" dropdb -h postgres -p 5432 zabbixdb -U zabbixdbuser \
&& PGPASSWORD="$(cat $POSTGRES_PASSWORD_FILE)" createdb -h postgres -p 5432 zabbixdb -U zabbixdbuser \
&& PGPASSWORD="$(cat $POSTGRES_PASSWORD_FILE)" gunzip -c /srv/zabbix-postgres/backups/'$SELECTED_DATABASE_BACKUP' | PGPASSWORD=$(cat $POSTGRES_PASSWORD_FILE) psql -h postgres -p 5432 zabbixdb -U zabbixdbuser'
echo "--> Database recovery completed..."

echo "--> Scaling service up..."
docker service scale zabbix_zabbix=1