# nginx HTTPS

## 下载最新的nginx的docker image
```
$ docker pull nginx:latest
```
## 启动nginx容器

运行如下命令来启动nginx container

```
docker run --detach \
        --name wx-nginx \
        -p 443:443\
        -p 80:80 \
        -v /home/evan/workspace/wxserver/nginx/data:/usr/share/nginx/html:rw\
        -v /home/evan/workspace/wxserver/nginx/config/nginx.conf:/etc/nginx/nginx.conf/:rw\
        -v /home/evan/workspace/wxserver/nginx/config/conf.d/default.conf:/etc/nginx/conf.d/default.conf:rw\
        -v /home/evan/workspace/wxserver/nginx/logs:/var/log/nginx/:rw\
        -v /home/evan/workspace/wxserver/nginx/ssl:/ssl/:rw\
        -d nginx
```

- 映射端口443，用于https请求
- 映射端口80，用于http请求；
- nginx的默认首页html的存放目录映射到host盘的目录， /home/evan/workspace/wxserver/nginx/data
- nginx的配置文件映射到host盘的文件，/home/evan/workspace/wxserver/nginx/config/nginx.conf

这里需要准备如下几个文件，

### nginx的配置文件

首先是nginx.conf文件，默认的配置文件如下 

```
#运行nginx的用户
user  nginx;
#启动进程设置成和CPU数量相等
worker_processes  1;

#全局错误日志及PID文件的位置
error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

#工作模式及连接数上限
events {
        #单个后台work进程最大并发数设置为1024
    worker_connections  1024;
}


http {
        #设定mime类型
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

        #设定日志格式
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

        #设置连接超时的事件
    keepalive_timeout  65;

        #开启GZIP压缩
    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```

可以看到最后一行还要包含另一个配置文件conf.d/default.conf，用来配置server字段

```
server {
    listen    80;       #侦听80端口，如果强制所有的访问都必须是HTTPs的，这行需要注销掉
    server_name  www.buagengen.com;             #域名

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

        # 定义首页索引目录和名称
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #定义错误提示页面
    #error_page  404              /404.html;

    #重定向错误页面到 /50x.html
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```

### nginx的默认首页的html文件
这个html可以自己定义一个，任意的都可以。
这个时候直接通过IP地址就可以访问nginx定义的这个html文件了。但是这个时候的访问只是http的，https的访问还是不行的，需要添加证书到nginx服务器。

### 3. 通过openssl生成证书


```
# access_log  /var/log/nginx/access.log


```

-----------

二、生成证书

第一步：使用OpenSSL创建证书

设置server.key，这里需要设置两遍密码:

建立服务器私钥（过程需要输入密码，请记住这个密码）生成RSA密钥
```
openssl genrsa -des3 -out server.key 1024
```
生成一个证书请求
```
openssl req -new -key server.key -out server.csr
```
需要依次输入国家，地区，组织，email。最重要的是有一个common name，可以写你的名字或者域名。如果为了https申请，这个必须和域名吻合，否则会引发浏览器警报。生成的csr文件交给CA签名后形成服务端自己的证书
Enter pass phrase for server.key: #之前输入的密码
Country Name (2 letter code) [XX]: #国家
State or Province Name (full name) []: #区域或是省份
Locality Name (eg, city) [Default City]: #地区局部名字
Organization Name (eg, company) [Default Company Ltd]: #机构名称：填写公司名
Organizational Unit Name (eg, section) []: #组织单位名称:部门名称
Common Name (eg, your name or your server's hostname) []: #网站域名
Email Address []: #邮箱地址
A challenge password []: #输入一个密码，可直接回车
An optional company name []: #一个可选的公司名称，可直接回车

输入完这些内容，就会在当前目录生成server.csr文件
```
cp server.key server.key.org
openssl rsa -in server.key.org -out server.key
```
使用上面的密钥和CSR对证书进行签名
以下命令生成v1版证书
```
openssl x509 -req -days 365 -sha256 -in server.csr -signkey server.key -out servernew.crt
```
以下命令生成v3版证书（v1即可满足，小编未用到v3版本）
```
openssl x509 -req -days 365 -sha256 -extfile openssl.cnf -extensions v3_req -in server.csr -signkey server.key -out servernew.crt
```

      #  ssl_certificate      ./ssl/servernew.crt;
      #  ssl_certificate_key  ./ssl/server.key;
	  
	  
-------

### 配置nginx服务器，支持https访问

把前面一步生成的文件拷贝到host上的ssl目录，/home/evan/workspace/wxserver/nginx/ssl。
然后修改配置文件default.conf，添加ssl支持，
```
server {
    listen    80;       #侦听80端口，如果强制所有的访问都必须是HTTPs的，这行需要注销掉
    listen    443 ssl;
    server_name  www.buagengen.com;             #域名

    # 增加ssl
    #ssl on;        #如果强制HTTPs访问，这行要打开
    ssl_certificate /ssl/server.crt;
    ssl_certificate_key /ssl/server.key;

    ssl_session_cache    shared:SSL:1m;
    ssl_session_timeout  5m;

     # 指定密码为openssl支持的格式
    ssl_protocols  SSLv2 SSLv3 TLSv1.2;

    ssl_ciphers  HIGH:!aNULL:!MD5;  # 密码加密方式
    ssl_prefer_server_ciphers  on;   # 依赖SSLv3和TLSv1协议的服务器密码将优先于客户端密码

     # 定义首页索引目录和名称
     location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
     }

    #重定向错误页面到 /50x.html
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```
重启nginx容器，现在就可以通过https来访问nginx的服务器了

```
location / {
            proxy_pass http://192.168.9.20:8888/;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection $http_connection;
			proxy_set_header Origin '';
        }
location /personal/ {
            proxy_pass http://192.168.9.20/
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection $http_connection;
			proxy_set_header Origin '';
        }
location /manager/ {
            proxy_pass http://192.168.9.20:8080/;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection $http_connection;
			proxy_set_header Origin '';
        }
location /server/ {
            proxy_pass http://192.168.9.20:8700/;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection $http_connection;
			proxy_set_header Origin '';
			
			proxy_set_header X-Real-IP $remote_addr;
			proxy_set_header X-Real-Port $remote_port;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
			
        }
```

```
nginx -s relaod 
``` 

------

解决nginx转发请求异常的解决办法 failed (13: Permission denied) while connecting to upstream
一 .如何查看报错信息？
操作系统：Centos7
nginx 默认报错日志输出位置/var/log/nginx/error.log warn;
二 .处理思路

1 . 不是什么配置的问题，直接一句命令搞
Linux命令行输入：# setsebool -P httpd_can_network_connect 1，执行成功后就对了，如果不对参考第二个方法
2 .默认文件/etc/nginx/nginx.conf：修改nginx.conf，将第一行修改为 user root



