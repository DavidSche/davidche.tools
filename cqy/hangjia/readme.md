# 常用命令

``` txt
 spring_profile_active
 SPRING_PROFILES_ACTIVE  hangjia-dev
 /home/cqy/log    /usr/cqy/log


docker save 192.168.9.10:5000/zentao  -o  cqy_zentao.tar


scp root@192.168.9.10:/root/cqy_zentao.tar  /home/temp
  
http://cqy.sdcqjy.com/hjwebsite/

http://192.168.16.137:9999/

        location /hjwebsite/ {
            proxy_pass http://192.168.16.137:9999/;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-real-ip $remote_addr;
            proxy_set_header X-Real-Port $remote_port;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

http://nginx.org/en/docs/http/ngx_http_core_module.html#alias

        location /temp/ {
            alias /home/temp/;
            autoindex on;
            autoindex_exact_size off;
            autoindex_localtime on;
        }
```
