docker service scale 扩展一个或多个服务 
docker service scale webtier_nginx=5


ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)

bug: 先启动的apache2。要去连数据库。而数据库没有启动完成。

通过重启下/etc/init.d/apache2 restart 容器就可以用 