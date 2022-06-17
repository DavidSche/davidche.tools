# 激活 Docker Engine 的 remote API 服务

linux 环境下Docker 服务的配置文件 /lib/system/system/docker.service f

```shell
vi /lib/systemd/system/docker.service
```

找到开头为 ExecStart 的行 并添加  -H=tcp://0.0.0.0:2375 

```shell
ExecStart=/usr/bin/docker daemon -H=fd:// -H=tcp://0.0.0.0:2375
```
 
保存文件并重新加载 docker daemon

```shell
systemctl daemon-reload
```

重启Docker 服务

```shell
sudo service docker restart
```

通过以下命令测试是否生效

```shell
curl http://localhost:2375/images/json
```

如果一切正常，则返回一个json 串

```json

```
