#!/usr/bin/env bash
git clone https://github.com/bitnami/bitnami-docker-mysql.git
cd bitnami-docker-mysql/VERSION/OPERATING-SYSTEM
docker build -t davidche/mysql-backup:latest .

docker rm 192-backup 
docker run --name 192-backup -e DB_HOST=192.168.6.192 -e DB_PORT=3306 -e DB_PASS=hjroot2020 -v /home/mysql_backups:/backup davidche/mysql-backup:latest
