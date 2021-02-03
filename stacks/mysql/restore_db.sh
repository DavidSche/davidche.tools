#!/usr/bin/env bash
echo "restore mysql db begin!"

date_home=/home/mysql_backups/6-161
export_dir=export-20210103-033002

echo "restore mysql db file home:"
echo ${date_home}
echo "restore export dir:"
echo ${export_dir}

#删除mysql 系统数据库文件
rm ${date_home}/${export_dir}/mysql* -f
rm ${date_home}/${export_dir}/sys* -f

docker run --name 161-restore --rm -e MODE=RESTORE -e DB_HOST=192.168.6.162 -e DB_PORT=3306 -e DB_PASS=CQY@mass2019 \
           -e RESTORE_DIR=/backup/${export_dir}/ -v ${date_home}:/backup 192.168.9.10:5000/mysql-backup:latest

echo "restore mysql db sucess!"
