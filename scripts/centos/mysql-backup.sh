#!/bin/bash
#mysql_backup.sh

TIMESTAMP=$(date +"%F")

#provide your destination_folder to store backup,

BACKUP_DIR="destination_folder"

#provide your respective user name and password for login.

MYSQL_USER="user"
MYSQL_PASSWORD="password"

#provide your databse name need to backup.

MYSQL_DATABASES="database_name"

cd $BACKUP_DIR

mysqldump --user=$MYSQL_USER --password=$MYSQL_PASSWORD $MYSQL_DATABASES | gzip >$MYSQL_DATABASES$TIMESTAMP.sql.gz

#mysql_backup.sh
#Add crontab to mysql-backup script to regular automate backup.
#
#Script for mysql database backup, linux ubuntu.
#
#Download the script.
#
#Run the script with sudo.
#
#sudo ./mysql-backup.sh
#
#change the file permission with 777
#
#sudo chmod 777 mysql-backup.sh
#
#Add crontab to mysql-backup script to automate regular backup.
# -------
#!/bin/bash
## 监控mysql 是否运行的脚本
#if [ ! -f /var/run/mysqld/mysqld.sock.lock  ]; then
#
#        systemctl restart mysql
#fi
