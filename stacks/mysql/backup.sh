#!/bin/bash
cd /home/

#删除目录下30天以上的文件
find /home/mysql_backups/6-161 -atime +30 -exec rm -rf {} \;

data_date=`date +%Y%m%d`
docker run  -v mysql_mysql_data:/volume -v /home/backup:/backup --rm bluet/vback backup  ${data_date}
echo "backup docker volume mysql_mysql_data sucess!"
