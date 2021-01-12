#!/usr/bin/env bash
echo "setting ntp config file :/etc/ntp.conf"

echo "
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict -6 ::1
server 192.168.9.81
driftfile /var/lib/ntp/drift
keys /etc/ntp/keys" > /etc/ntp.conf

echo "install ntp "

sudo yum install ntp -y
systemctl enable ntpd.service
systemctl start ntpd.service

echo "ntp server is ok ! "

systemctl stop ntpd.service
ntpdate 192.168.9.81
systemctl start ntpd.service