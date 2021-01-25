#!/bin/bash
#!/usr/bin/env bash

spinner() {
    local i sp n
    sp='/-\|'
    n=${#sp}
    printf ' '
    while sleep 0.1; do
        printf "%s\b" "${sp:i++%n:1}"
    done
}
printf 'Installing Redis. Please wait... It will take up to 1 minute'
spinner &
sleep 1

#######################################################################
###                                                                 ###
###             Created by Davidsche                                ###
###             Creation data 25.01.2021                            ###
###             Script version: V1                                  ###
###             Website: https://davidsche.github.io                ###
###                                                                 ###
###     Web hosting, Shared Hosting, Digital office,                ###
###     Domain registration with more than 700 DNS zones,           ###
###     VPS hosting, Virtual Private Server hosting, VDS hosting,   ###
###     Virtual Dedicated servers, SSL certificates,                ###
###     and other hosting solutions                                 ###
###                                                                 ###
#######################################################################


# Set UTF-8 support
localectl set-locale LC_CTYPE=zh_CN.UTF-8 1> /dev/null 2>> temp ;

#Install redise libary in centos

sudo yum -y install epel-release yum-utils 1> /dev/null 2>> temp ;
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm  1> /dev/null 2>> temp ;
sudo yum-config-manager --enable remi 1> /dev/null 2>> temp ;

#Install redis
sudo yum -y install redis nano 1> /dev/null 2>> temp ;

#Start Redis and Enable it for startup
sudo systemctl start redis 1> /dev/null 2>> temp ;
sudo systemctl enable redis 1> /dev/null 2>> temp ;

kill "$!" 1> /dev/null 2>> temp ;  # kill the spinner
printf '\n' 1> /dev/null 2>> temp ;
rm -rf temp 1> /dev/null ;

echo "
#######################################################################
###                                                                 ###
###             Created by Davidsche                                ###
###             Creation data 25.01.2021                            ###
###             Script version: V1                                  ###
###             Website: https://davidsche.github.io                ###
###                                                                 ###
###     Web hosting, Shared Hosting, Digital office,                ###
###     Domain registration with more than 700 DNS zones,           ###
###     VPS hosting, Virtual Private Server hosting, VDS hosting,   ###
###     Virtual Dedicated servers, SSL certificates,                ###
###     and other hosting solutions                                 ###
###                                                                 ###
#######################################################################
The setup is completed.
This script was written by Davidsche
Hosting Page https://davidsche.github.io
"