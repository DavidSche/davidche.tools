# Docker搭建私有云

## 背景

大部分网盘关闭，百度网盘限速。需要一个私有云存储。这里我们选型owncloud.

## 代码

```docker-compose
version: "3"
services:
  mysql:
    image: mysql:5.7 # 使用 mysql5.7 版本的鏡像
    container_name: mysql # 容器名稱
    restart: always # 自動重啓策略
    ports:
      - 31006:3306 # 映射到宿主機的端口
    volumes:
      - ./conf.d:/etc/mysql/conf.d # 配置文件掛載的宿主機目錄
      - ./data:/var/lib/mysql # 數據文件掛載的宿主機目錄
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: owncloud
      MYSQL_USERNAME: root
      MYSQL_PASSWORD: root
    command: mysqld --lower_case_table_names=1 --skip-ssl --character_set_server=utf8mb4 --explicit_defaults_for_timestamp

  app:
    image: owncloud
    container_name: owncloud
    restart: always
    ports:
      - 9000:80
    volumes:
      - ./data:/var/www/html
    extra_hosts:
      - "dockerhost:192.168.124.3" # 宿主機的內網IP，便於容器內訪問宿主機網絡。
```



启动命令

```
docker-compose -f owncloud/docker-compose-owncloud.yml up
```



启动后，访问  http://localhost:9000 即可。

```text
owncloud帐号密码: any
数据库host配置: dockerhost:31006
```

