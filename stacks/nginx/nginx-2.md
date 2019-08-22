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

设置server.key，这里需要设置两遍密码:

```
openssl genrsa -des3 -out server.key 1024 
```

参数设置，首先这里需要输入之前设置的密码:

```
openssl req -new -key server.key -out server.csr
```

然后需要输入如下的信息，大概填一下就可以了，反正是测试用的
```
Country Name (2 letter code) [AU]: 国家名称
State or Province Name (full name) [Some-State]: 省
Locality Name (eg, city) []: 城市
Organization Name (eg, company) [Internet Widgits Pty Ltd]: 公司名
Organizational Unit Name (eg, section) []: 
Common Name (e.g. server FQDN or YOUR name) []: 网站域名
Email Address []: 邮箱

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []: 这里要求输入密码
An optional company name []:
```

写RSA秘钥（这里也要求输入之前设置的密码）:

```
openssl rsa -in server.key -out server_nopwd.key
```

获取私钥:
```
openssl x509 -req -days 365 -in server.csr -signkey server_nopwd.key -out server.crt
```

完成这一步之后就得到了我们需要的证书文件和私钥了

- server.crt
- server.key

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

 
