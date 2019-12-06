# 相关  命令


Windows下启动,关闭Nginx命令

启动
直接点击Nginx目录下的nginx.exe    或者    cmd运行start nginx

关闭

nginx -s stop    或者    nginx -s quit

stop表示立即停止nginx,不保存相关信息

quit表示正常退出nginx,并保存相关信息

重启(因为改变了配置,需要重启)

nginx -s reload
 
Ya I found solution .Its worked for me.

Is it because /test should be put before /, otherwise the situation /test, which is included in the situation /, 
will be redirected according to the first rule? – Yan Yang Dec 2 '15 at 7:18


###

OK figured it out, I thought the "not found" error was coming from nginx, but actually it was coming from my API. This is my solution if anyone is interested:

```

server {
  listen 80;
  server_name localhost;
  server_name 192.168.3.90;
  server_name 127.0.0.1;

  location / {
    root /home/me/src/phoenix/ui;
    index index.html;
  }

  # automatically go to v1 of the (grape) API
  location ^~ /api/mypath/ {
    rewrite ^/api/mypath/(.*)$ /v1/$1 break;
    proxy_pass http://localhost:3936/;
  }

  location ^~ /api {
    rewrite ^/api/(.*)$ /$1 break;
    proxy_pass http://localhost:7379/;
  }
}
```


```

 server {
                location /test {
                  proxy_pass http://localhost:3000;
                }
                location / {
                    proxy_set_header    Host            $host;
                    proxy_set_header    X-Real-IP       $remote_addr;
                    proxy_set_header    X-Forwarded-for $remote_addr;
                    proxy_connect_timeout 300;
                    port_in_redirect off;
                    proxy_pass http://localhost:8080;

                }
         }
```

I am using nginx/1.11.5, and I want /log to be mapped to something like http://127.0.0.1:8181, but

```
    location /blog {
        proxy_pass http://127.0.0.1:8181;
    }
```

the above config will map the request to http://127.0.0.1:8181/blog.

If I want to map /log to http://127.0.0.1:8181, I need to add a slash at the end of the target url.

```
    location /blog {
        proxy_pass http://127.0.0.1:8181/;
    }
```

This comment saved my hours in digging for why my proxy didn't work! It'd be a good idea to include this into the tutorial.

-------


Step 9 (optional) -- Redirecting Based on Host Name
Let say you want to host example1.com, example2.com, and example3.com on your machine, respectively to localhost:8080, localhost:8181, and localhost:8282.

Note: Since you don't have access to a DNS server, you should add domain name entries to your /etc/hosts (you can't do this on CDF machines):

...
127.0.0.1 example1.com example2.com example3.com
...
To proxy eaxmple1.com we can't use the location part of the default server. Instead we need to add another server section with a server_name set to our virtual host (e.g., example1.com, ...), and then a simple location section that tells nginx how to proxy the requests:

```
server {
    listen       80;
    server_name  example1.com;

    location / {
        proxy_pass http://127.0.0.1:8080;
    }
}

server {
    listen       80;
    server_name  example2.com;

    location / {
        proxy_pass http://127.0.0.1:8181;
    }
}

server {
    listen       80;
    server_name  example3.com;

    location / {
        proxy_pass http://127.0.0.1:8282;
    }
}
```


nginx proxy_pass documentation states that when proxy_pass is specified with an URI, then the proxy_pass destination is used and the path in location is not used.

Example:

location /app1 {
    proxy_pass http://proxy.example.com/app1;
}
With this configuration, all requests that begin with http://example.com/app1 will end up to http://proxy.example.com/app1. This includes http://example.com/app1/dir1.

The solution to fix this is to use regular expression capture in the location directive, and use the captured variable in proxy_pass destination, like this:

location ~ ^/app1(.*)$ {
    proxy_pass http://proxy.example.com$1;
}
This will make nginx append the string after app1 to the proxy_pass destination line.

-------

You don't need rewrite for this.

```
server {
  ...

  location ^~ /api/ {
    proxy_pass http://localhost:7379/;
  }
  location ^~ /api/mypath/ {
    proxy_pass http://localhost:3936/v1/;
  }
}
```

According to the nginx documentation

A location can either be defined by a prefix string, or by a regular expression. Regular expressions are specified with the preceding ~* modifier (for case-insensitive matching), or the ~ modifier (for case-sensitive matching). To find location matching a given request, nginx first checks locations defined using the prefix strings (prefix locations). Among them, the location with the longest matching prefix is selected and remembered. Then regular expressions are checked, in the order of their appearance in the configuration file. The search of regular expressions terminates on the first match, and the corresponding configuration is used. If no match with a regular expression is found then the configuration of the prefix location remembered earlier is used.

If the longest matching prefix location has the ^~ modifier then regular expressions are not checked.

Therefore any request that begins with /api/mypath/ will always be served by the second block since that's the longest matching prefix location.

Any request that begins with /api/ not immediately followed by mypath/ will always be served by the first block, since the second block doesn't match, therefore making the first block the longest matching prefix location.

https://serverfault.com/questions/650117/serving-multiple-proxy-endpoints-under-location-in-nginx
------



Simple, ha?!

To redirect /mail and /blog, you simply need to add new entries the location section in the config file:
```
server {
    listen       ...;
    ...
    location / {
        proxy_pass http://127.0.0.1:8080;
    }
    
    location /blog {
        proxy_pass http://127.0.0.1:8181;
    }

    location /mail {
        proxy_pass http://127.0.0.1:8282;
    }
    ...
}

```

-------


完美解决Nginx配置反向代理时出现的13: Permission denied) while connecting to upstream


1.条件不允许的情况下（不能随意重启计算机）执行下列代码：

setsebool -P httpd_can_network_connect 1 
1
2.其他情况下获取root权限

vim /etc/selinux/config
1
找到

SELINUX=enforcing
1
改为

SELINUX=disabled
————————————————
 
