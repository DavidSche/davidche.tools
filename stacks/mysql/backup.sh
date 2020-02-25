#!/bin/bash
cd /home/

data_date=`date +%Y%m%d`
docker run  -v mysql_mysql_data:/volume -v /home/backup:/backup --rm bluet/vback backup  ${data_date}
echo "backup docker volume mysql_mysql_data sucess!"
