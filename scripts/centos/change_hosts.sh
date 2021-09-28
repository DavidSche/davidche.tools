# !/bin/sh
in_ip=${1}
in_url=${2}
local_ip="127.0.0.1"

#更改host
updateHost()
{
# read
  inner_host=`cat /etc/hosts | grep ${in_url} | awk '{print $1}'`
  if [ ${inner_host} = ${in_ip} ];then
     echo "${inner_host}  ${in_url} ok"
  else
     if [ ${inner_host} != "" ];then
        echo  " change is ok "

      else
         inner_ip_map="${in_ip} ${in_url}"
         echo ${inner_ip_map} >> /etc/hosts
         if [ $? = 0 ]; then
           echo "${inner_ip_map} to hosts success host is `cat /etc/hosts`"
         fi
         echo "shuld appand "
     fi
  fi
}
#  hostName
updateHostName()
{
inner_hostName=`hostname`
inner_local_ip=${local_ip}
inner_host_count=`cat /etc/hosts | grep ${inner_hostName} | awk '{print $1}' |grep -c ${local_ip}`
inner_host=`cat /etc/hosts | grep ${inner_hostName} | awk '{print $1}'`
if [ ${inner_host_count} != 0 ]; then
     return
fi
if [ ${inner_host} = ${inner_local_ip} ];then
   echo "127.0.0.1 ${inner_hostName} already add "
else
   if [ ${inner_host}="" ]; then
     inner_ip_map="${inner_local_ip} ${inner_hostName}"
     echo ${inner_ip_map} >> /etc/hosts
     if [ $?=0 ];then
        echo " ${inner_ip_map} to add hosts success `cat /etc/hosts`"
     fi
   fi
fi
}

main() {    updateHost    updateHostName } main