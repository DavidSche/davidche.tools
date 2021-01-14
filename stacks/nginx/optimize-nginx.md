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