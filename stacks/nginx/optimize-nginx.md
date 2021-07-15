# How to Optimize NGINX to Handle 100+K Requests per Minute

Written by Rahul, Updated on February 2, 2015

Few days back I got an assignment to configure Ngnix web server which can handle 100k requests per minute. To complete this task I take a Ubuntu system with 4 CPU and 8 GB of memory and start configuration like below.

## 1. Install Nginx Web server
   This is optional steps if you don’t have installed Nginx on your system.

Install on Ubuntu/Debian/ Linuxmint

```shell
$ sudo apt-get install nginx
```

Install on CentOS / RHEL / Fedora

```shell
# yum install nginx
```

## 2. Tune Nginx Configuration File
   Now edit Nginx configuration /etc/nginx/nginx.conf and make change in following values. In below configuration only changed parameters are showing.

```nginx.conf
worker_processes 8;  # no of cpu * 2
worker_rlimit_nofile 50000;

events {
        worker_connections 20000;
}
http {
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_requests 100;
        #keepalive_timeout 65;
        open_file_cache max=100;
        gzip   off;
        access_log off;
       types_hash_max_size 2048;
}
```

## 3. Restart Nginx and Test Load
   After making all above changes just restart Nginx service using following command.

```shell
# service nginx restart
```

Now use Apache Benchmark tool for testing load. I have uploaded a file on server of 50Kb and hits it by 100k times.

```shell
# ab -n 100000 -c 500 http://11.22.33.44/mypage.html
```

```shell
This is ApacheBench, Version 2.3 <$Revision: 1528965 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 11.22.33.44 (be patient)
Completed 10000 requests
Completed 20000 requests
Completed 30000 requests
Completed 40000 requests
Completed 50000 requests
Completed 60000 requests
Completed 70000 requests
Completed 80000 requests
Completed 90000 requests
Completed 100000 requests
Finished 100000 requests


Server Software:        nginx/1.4.6
Server Hostname:        11.22.33.44
Server Port:            80

Document Path:          /mypage.html
Document Length:        53339 bytes

Concurrency Level:      500
Time taken for tests:   43.570 seconds
Complete requests:      100000
Failed requests:        0
Total transferred:      5358300000 bytes
HTML transferred:       5333900000 bytes
Requests per second:    2295.18 [#/sec] (mean)
Time per request:       217.848 [ms] (mean)
Time per request:       0.436 [ms] (mean, across all concurrent requests)
Transfer rate:          120100.12 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        4   84 275.9     18    7027
Processing:    39  132 124.1     90    3738
Waiting:        7   21  22.5     18    1598
Total:         50  216 308.0    109    7208

Percentage of the requests served within a certain time (ms)
  50%    109
  66%    127
  75%    158
  80%    180
  90%    373
  95%   1088
  98%   1140
  99%   1333
 100%   7208 (longest request)

```

As per above output you can see that for 100K requests were served in 43.570 seconds by Nginx.


[来源](https://tecadmin.net/optimize-nginx-to-handle-100k-requests-per-minute/)

------

## nginx error log

日志格式

```nginx.conf
access_log log_file log_format;
```

```
http {
      ...
      ...
      access_log  /var/log/nginx/access.log;
      ...
      ...
}
```
```
http {
      ...
      ...
      access_log  /var/log/nginx/access.log;
    
         server {
                  listen 80; 
                  server_name domain1.com
                  access_log  /var/log/nginx/domain1.access.log;
                  ...
                  ...
                }
}
```

```nginx.conf
http {
            log_format custom '$remote_addr - $remote_user [$time_local] '
                           '"$request" $status $body_bytes_sent '
                           '"$http_referer" "$http_user_agent" "$gzip_ratio"';

            server {
                    gzip on;
                    ...
                    access_log /var/log/nginx/domain1.access.log custom;
                    ...
            }
}
```

```nginx.conf
http {
       	  ...
	  error_log  /var/log/nginx/error_log  crit;
	  ...
}
```

每个server 配置日志

```nginx.conf
http {
       ...
       ...
       error_log  /var/log/nginx/error_log;
       server {
	        	listen 80;
		        server_name domain1.com;
       		        error_log  /var/log/nginx/domain1.error_log  warn;
                        ...
	   }
       server {
	        	listen 80;
		        server_name domain2.com;
      		        error_log  /var/log/nginx/domain2.error_log  debug;
                        ...
	   }
}
```

```nginx.conf
http {
       ...
       ...
       error_log  /var/log/nginx/error_log;
       server {
	        	listen 80;
		        server_name domain1.com;
                if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})") {
                    set $year $1;
                    set $month $2;
                    set $day $3;
                }
                access_log logs/domain1.access.log.$year$month$day main;
                error_log  logs/domain1.error.log.$year$month$day; #not support 
	   }
}
```
## Nginx Error Log Severity Levels

There are many types of log levels that are associated with a log event and with a different priority. All the log levels are listed below. In the following log levels, debug has top priority and includes the rest of the levels too. For example, if you specify error as a log level, then it will also capture log events those are labeled as crit, alert and emergency.

emerg: Emergency messages when your system may be unstable.
alert: Alert messages of serious issues.
crit: Critical issues that need to be taken care of immediately.
error: An error has occured. Something went wrong while processing a page.
warn: A warning messages that you should look into it.
notice: A simple log notice that you can ignore.
info: Just an information messages that you might want to know.
debug: Debugging information used to pinpoint the location of error.

[来源](https://www.journaldev.com/26756/nginx-access-logs-error-logs)
[see nginx bug](https://trac.nginx.org/nginx/ticket/562)\
[split-nginx-error-log-by-date](https://stackoverflow.com/questions/55095204/how-do-i-can-split-nginx-error-log-by-date)

------

As many others have pointed out here, increasing the timeout settings for NGINX can solve your issue.

However, increasing your timeout settings might not be as straightforward as many of these answers suggest. I myself faced this issue and tried to change my timeout settings in the /etc/nginx/nginx.conf file, as almost everyone in these threads suggest. This did not help me a single bit; there was no apparent change in NGINX' timeout settings. Now, many hours later, I finally managed to fix this problem.

The solution lies in this forum thread, and what it says is that you should put your timeout settings in /etc/nginx/conf.d/timeout.conf (and if this file doesn't exist, you should create it). I used the same settings as suggested in the thread:

```timeout.conf
proxy_connect_timeout 600;
proxy_send_timeout 600;
proxy_read_timeout 600;
send_timeout 600;

```


```.config

location / 
{        
  # time out settings
  proxy_connect_timeout 159s;
  proxy_send_timeout   600;
  proxy_read_timeout   600;
  proxy_buffer_size    64k;
  proxy_buffers     16 32k;
  proxy_busy_buffers_size 64k;
  proxy_temp_file_write_size 64k;
  proxy_pass_header Set-Cookie;
  proxy_redirect     off;
  proxy_hide_header  Vary;
  proxy_set_header   Accept-Encoding '';
  proxy_ignore_headers Cache-Control Expires;
  proxy_set_header   Referer $http_referer;
  proxy_set_header   Host   $host;
  proxy_set_header   Cookie $http_cookie;
  proxy_set_header   X-Real-IP  $remote_addr;
  proxy_set_header X-Forwarded-Host $host;
  proxy_set_header X-Forwarded-Server $host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}

```

## Nginx 常见错误处理

### Error 1: “no live upstreams while connecting to……”

#### Solution

```nginx.config
upstream sm_url {
  server LOAD_BALANCER_DOMAIN_NAME: max_fails=0;
}
# fail_timeout is the time interval during which if health-check fails for #max_fails times then the upstream server is considered as unhealthy. Default : 10sec, 1 respectively.
```

max_fails=0 设置将会禁用健康检查，总是将路由转发到设置的 upstream servers ，否则会出现默认的10秒无法连接 

备注 : 修改 Nginx 配置文件，在生效之前不要忘记测试一下变化内容是否合法:

```
sudo nginx -t

```

## Error 2: “upstream timed out (110: Connection timed out) while connecting to upstream,…..”
1) 首先第一步是记录连接失败的 upstream ip 地址 .
   变化 : set $upstream_addr in confs/ngnix_log.conf
   日志配置实例/log config
   Corresponding error log:

```nginx_log.conf
log_format                      le_json  '{'
                                    '"created_at": "$time_iso8601", '
                                    '"remote_addr": "$remote_addr", '
                                    '"remote_user": "$remote_user", '
                                    '"request": "$request", '
                                    '"request_method": "$request_method", '
                                    #'"postdata" : "$request_body", '
                                    '"request_response_time": "$request_time", '
                                    '"upstream_response_time": "$upstream_response_time", '
                                    '"upstream_addr": "$upstream_addr", '
                                    '"body_bytes_sent": $body_bytes_sent, '
                                    '"msec": "$msec", '
                                    '"status": "$status", '
                                    '"http_referrer": "$http_referer", '
                                    '"platform": "$upstream_http_x_platform", '
                                    '"chcount": "$upstream_http_x_chcount", '
                                    '"device": "$upstream_http_x_device", '
                                    '"http_user_agent": "$http_user_agent"' '}';

access_log                      /var/log/nginx/access_upstream.log le_json;
error_log                       /var/log/nginx/error.log;
rewrite_log  
```

对应的错误日志实例 Corresponding error log:

``` error.log
Corresponding error log:
“2018/03/17 07:59:34 [error] 17028#17028: *77553273 upstream timed out (110: Connection timed out) while connecting to upstream, client: 42.107.148.218, server: www.urbanclap.com, request: “POST /api/v1/providers/cd/notify HTTP/1.1”, upstream: “http://x.x.x.x:80/api/v1/providers/cd/notify", host: “www.urbanclap.com"
```

2) 需要检查应该接收并处理请求的负载均衡IP地址： load balancer’s ip address which should receive above traffic.

```.shell
root@app6.nginx[Prod] nslookup LOAD_BALANCER_DOMAIN_NAME
Server: 172.31.0.2
Address: 172.31.0.2#53
Non-authoritative answer:
Name: LOAD_BALANCER_DOMAIN_NAME
Address: 52.74.x.x
Name: LOAD_BALANCER_DOMAIN_NAME
Address: 54.255.x.x

````

```.conf
upstream files_1 {
    least_conn;
    check interval=5000 rise=3 fall=3 timeout=120 type=ssl_hello max_fails=0;
    server mymachine:6006 ;
}

```

## recv() failed (104: Connection reset by peer) while reading response header from upstream”

可能的原因：

 - 负载平衡器在尝试建立连接时从目标接收 TCP RST。
 - 目标关闭了与 TCP RST 或 TCP FIN 的连接，而负载平衡器对目标有未完成的请求。
 - 目标响应错误或包含无效的 HTTP 标头。
 - 使用了一个新的目标组，但尚未通过初步健康检查的目标。目标必须通过一次健康检查才能被视为健康

Nginx configuration used is : -

```.conf
user www-data;
worker_processes auto;
worker_rlimit_nofile 10000;
pid /run/nginx.pid;

events {
    worker_connections 2000;
    multi_accept on;
    use epoll;
}

http {
    open_file_cache max=200000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    reset_timedout_connection on;
    client_body_timeout 200s; # Use 5s for high-traffic sites
    client_header_timeout 200s;

    ##
    # Basic Settings
    ##
    sendfile on;

    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 900;
    keepalive_requests 10000;
    types_hash_max_size 2048;
    #proxy_buffering off;
    proxy_connect_timeout 1600;
    proxy_send_timeout 1600;
    proxy_read_timeout 1600;
    send_timeout 1600;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/stream.access.log;
    error_log /var/log/nginx/stream.error.log;

    gzip on;
    gzip_disable "msie6";

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

测试代码
当启用 HTTP 保持活力时，在关闭服务器端的连接时，此问题是一个通用问题，因此您可以通过从[https://github.com/weixu365/test-connection-reset](https://github.com/weixu365/test-connection-reset) 中克隆示例代码 （Node .js） 轻松重现
[Github code](https://github.com/weixu365/test-connection-reset)



上游节点.js Web 服务器

```node.js
const express = require('express');
  
const app = express();
  
app.get('/', (req, res) => res.send('OK'));
  
const port = process.env.PORT || 8000;
app.listen(port, () => {
  console.log(`Listening on http://localhost:${port}`)
})
  .keepAliveTimeout = 500;
  
```

```shell
npm install
npm start
 
# In a separate terminal
npm run client
```

