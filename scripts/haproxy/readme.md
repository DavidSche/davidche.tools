# HA Proxy 代理使用

安装

```
yum install haproxy

dnf install haproxy

```

配置文件路径地址
/etc/haproxy/haproxy.cfg

重新加载配置文件
```
sudo haproxy -f /etc/haproxy/haproxy.cfg -c

[root@yanpeng-2 ~]# sudo haproxy -f /etc/haproxy/haproxy.cfg -c
[WARNING] 300/172243 (8007) : config : 'option forwardfor' ignored for frontend 'mysql' as it requires HTTP mode.
[WARNING] 300/172243 (8007) : config : 'option forwardfor' ignored for backend 'mysql' as it requires HTTP mode.
Configuration file is valid

```

  ##1、设置安全，如果出现服务启动失败，提示端口绑定错误，执行以下命令
```
##I have solved this issue by following command.
setsebool -P haproxy_connect_any=1

It works for me!
```
或者
修改SELinux 配置

修改文件
/etc/sysconfig/selinux 
中的
SELINUX=permissive

重启机器

reboot

systemctl restart haproxy
systemctl status haproxy


---------

设置IPv4

worked for me

Add net.ipv4.ip_nonlocal_bind=1 on /etc/sysctl.conf

sysctl -p

Restart the haproxy service(service restart haproxy ||  systemctl restart haproxy). it will work.

--------


```mysql.cfg
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2017-12-16 10:56:16 +0000 (Sat, 16 Dec 2017)
#
#  https://github.com/harisekhon/haproxy-configs
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# ============================================================================ #
#                          H A P r o x y  -  M y S Q L
# ============================================================================ #

# Tested and works on MariaDB too

frontend mysql
    description "MySQL"
    bind *:3306
    mode tcp
    option tcplog
    default_backend mysql

backend mysql
    description "MySQL"
    #balance leastconn
    balance first
    mode tcp
    acl internal_networks src 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8 127.0.0.1
    tcp-request content reject if ! internal_networks
    option mysql-check # user root
#    server mysql mysql:3306 check
#    server mariadb mariadb:3306 check
#    server docker docker:3306 check backup
    server 192.168.9.71 192.168.9.71:3306 check backup


```

------

另一个测试过的配置

```mysql.cfg

global
  ulimit-n 400025
  maxconn 99999
  maxpipes 99999
  tune.maxaccept 500
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice

defaults 
    timeout connect 5s
    timeout client 1m
    timeout server 1m  
	
frontend mysql
    description "MySQL"
    bind *:3306
    mode tcp
    option tcplog
    default_backend mysql

backend mysql
    description "MySQL"
    #balance leastconn
    balance first
    mode tcp
    acl internal_networks src 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8 127.0.0.1
    tcp-request content reject if ! internal_networks
    option mysql-check # user root
#    server mysql mysql:3306 check
#    server mariadb mariadb:3306 check
#    server docker docker:3306 check backup
    server 192.168.9.71 192.168.9.71:3306 check backup

```
 
 对应的docker-compose.yml
 
```docker-compose.yml

version: '3.6'

configs:
  mysql_lb.cfg:
    external:
      name: mysql_lb6.cfg

services:
  haproxy:
    image: haproxy:2.2
    ports:
      - target: 3306
        published: 3306
        mode: host
        protocol: tcp  
    configs:
      - source: mysql_lb.cfg
        target: /usr/local/etc/haproxy/haproxy.cfg
    deploy:
      mode: replicated
      replicas: 1
      placement:
        # constraints: [node.labels.pm-
		node == true]  # 部署标签约束
        constraints: [node.labels.nginx == true]  # 部署标签约束

```


相关配置文件

```./etc/haproxy.cfg

global
    daemon
    maxconn 256
    log 127.0.0.1 local0 debug

defaults
    balance roundrobin
    mode    http
    timeout connect 50000
    timeout client  500000
    timeout server  500000
    option  httplog

    log global
    log-format {"type":"haproxy","timestamp":%Ts,"http_status":%ST,"http_request":"%r","remote_addr":"%ci","bytes_read":%B,"upstream_addr":"%si","backend_name":"%b","retries":%rc,"bytes_uploaded":%U,"upstream_response_time":"%Tr","upstream_connect_time":"%Tc","session_duration":"%Tt","termination_state":"%ts"}

frontend localnodes
    bind *:80

    option forwardfor

        capture request header host len 50

        http-request set-header HTTPS ON if { ssl_fc }
    acl is_https_request ssl_fc
        http-request set-header HTTPS ON if is_https_request

    http-request set-header X-ORIGINAL-HTTPS ON

    default_backend default

backend default
      server default nginx:80 check

```

```./etc/rsyslog.conf
# Loads the imudp into rsyslog address space
# and activates it.
# IMUDP provides the ability to receive syslog
# messages via UDP.
$ModLoad imudp

# Address to listen for syslog messages to be
# received.
$UDPServerAddress 0.0.0.0

# Port to listen for the messages
$UDPServerRun 514

# Take the messages of any priority sent to the
# local0 facility (which we reference in the haproxy
# configuration) and send to the haproxy.log
# file.
local0.* -/var/log/haproxy.log

# Discard the rest
& ~

```

镜像构建文件

```Dockerfile
FROM haproxy:1.8

RUN apt update -y && apt install bash ca-certificates rsyslog cron -y
RUN mkdir -p /etc/rsyslog.d/ &&  \
        touch /var/log/haproxy.log &&  \
        ln -sf /dev/stdout /var/log/haproxy.log

ADD ./etc/ /etc/

# Include our custom entrypoint that will the the job of lifting
# rsyslog alongside haproxy.
ADD ./entrypoint.sh /usr/local/bin/entrypoint

EXPOSE 80 443

# Set our custom entrypoint as the image's default entrypoint
ENTRYPOINT [ "entrypoint" ]

# Make haproxy use the default configuration file
CMD [ "-f", "/etc/haproxy.cfg" ]

```

部署文件

```docker-stack.yaml

version: '3.7'
services:
  haproxy:
      image: haproxy-challenge:1.8
      networks:
        - test
      ports:
        - 80:80
        - 443:443
      volumes:
        - ./etc/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
  nginx:
      image: nginx:latest
      networks:
        - test
      volumes:
        - ./index.html:/usr/share/nginx/html/index.html

networks:
  test:
    driver: overlay
    attachable: true

```
MQ 




-------


How to alter task history retention inside Docker Swarm cluster
Post author
By milosz
Post date
December 9, 2020
Alter task history retention inside the Docker Swarm cluster to ensure that there are no stopped containers.


By default, task history retention is set to 5.

$ docker node ps --filter "name=blog_staging" swarm-cerberus
ID                  NAME                 IMAGE                                                NODE                DESIRED STATE       CURRENT STATE             ERROR               PORTS
ormho76nb30u        blog_staging.2       registry.example.com/websites/blog:staging           swarm-cerberus      Running             Running 14 minutes ago                        
ttrmtuh5xpv4         \_ blog_staging.2   registry.example.com/websites/blog:staging           swarm-cerberus      Shutdown            Shutdown 16 minutes ago                       
p2of726hvvbg         \_ blog_staging.2   registry.example.com/websites/blog:staging           swarm-cerberus      Shutdown            Shutdown 15 hours ago                         
nvk4xr78td9m         \_ blog_staging.2   registry.example.com/websites/blog:staging           swarm-cerberus      Shutdown            Shutdown 38 hours ago                         
a0n2lcmhjx6f         \_ blog_staging.2   registry.example.com/websites/blog:staging           swarm-cerberus      Shutdown            Shutdown 38 hours ago       
Task history retention can be changed globally.

$ docker swarm update --help
Usage:	docker swarm update [OPTIONS]
Update the swarm
Options:
      --autolock                        Change manager autolocking setting (true|false)
      --cert-expiry duration            Validity period for node certificates (ns|us|ms|s|m|h) (default 2160h0m0s)
      --dispatcher-heartbeat duration   Dispatcher heartbeat period (ns|us|ms|s|m|h) (default 5s)
      --external-ca external-ca         Specifications of one or more certificate signing endpoints
      --max-snapshots uint              Number of additional Raft snapshots to retain
      --snapshot-interval uint          Number of log entries between Raft snapshots (default 10000)
      --task-history-limit int          Task history retention limit (default 5)
Set task history retention to 0 to disable it.

This change will not be applied immediately. You need to update the service to see the difference.
$ docker swarm update --task-history-limit 0
Swarm updated.
Update service to reapply task history retention.

$ docker service update --with-registry-auth --image registry.example.com/websites/blog:staging blog_staging | grep ^verify:\ Service"
verify: Service converged
There are no stopped containers.

$ docker node ps --filter "name=blog_staging" swarm-cerberus
ID                  NAME                IMAGE                                                NODE                DESIRED STATE       CURRENT STATE              ERROR               PORTS
lqblu9mgjhxl        blog_staging.2      registry.example.com/websites/blog:staging           swarm-cerberus      Running             Preparing 49 seconds ago
Additional information
You can set this option during swarm initialization.

$ docker swarm init --help
Usage:	docker swarm init [OPTIONS]
Initialize a swarm
Options:
      --advertise-addr string                  Advertised address (format: <ip|interface>[:port])
      --autolock                               Enable manager autolocking (requiring an unlock key to start a stopped manager)
      --availability string                    Availability of the node ("active"|"pause"|"drain") (default "active")
      --cert-expiry duration                   Validity period for node certificates (ns|us|ms|s|m|h) (default 2160h0m0s)
      --data-path-addr string                  Address or interface to use for data path traffic (format: <ip|interface>)
      --data-path-port uint32                  Port number to use for data path traffic (1024 - 49151). If no value is set or is set to 0, the default port (4789) is used.
      --default-addr-pool ipNetSlice           default address pool in CIDR format (default [])
      --default-addr-pool-mask-length uint32   default address pool subnet mask length (default 24)
      --dispatcher-heartbeat duration          Dispatcher heartbeat period (ns|us|ms|s|m|h) (default 5s)
      --external-ca external-ca                Specifications of one or more certificate signing endpoints
      --force-new-cluster                      Force create a new cluster from current state
      --listen-addr node-addr                  Listen address (format: <ip|interface>[:port]) (default 0.0.0.0:2377)
      --max-snapshots uint                     Number of additional Raft snapshots to retain
      --snapshot-interval uint                 Number of log entries between Raft snapshots (default 10000)
      --task-history-limit int                 Task history retention limit (default 5)


