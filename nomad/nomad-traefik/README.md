# Traefik Proxy Integrates with Hashicorp Nomad

## 前提条件
   - nomad 版本在 1.3 以上 （当前为1.3.2）
   - Traefik 版本在2.8 以上 （当前为2.8.1）

```
nomad -v

```

### 启动 Nomad 

运行以下命令，启动Nomad,如果主机有多网卡，建议使用network-interface 绑定网卡

```shell
nomad.exe agent -dev -bind 0.0.0.0 -network-interface=eth0 -log-level INFO  

```
访问 http://ip:4646/ 看 Nomad 是否正常

## 部署 Traefik

使用以下部署文件部署Traefik 服务

```nomad
job "traefik" {
  datacenters = ["dc1"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      port  "http"{
         to = 80
         static = 80
      }
      port  "admin"{
         to = 8080   //container port
         static = 8080   //host port 
      }
    }

    service {
      name = "traefik-http"
      provider = "nomad"
      port = "http"
    }

    task "server" {
      driver = "docker"
      config {
        image = "traefik:2.8"
        ports = ["admin", "http"]
        args = [
          "--api.dashboard=true",
          "--api.insecure=true", ### For Test only, please do not use that in production
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://192.168.178.39:4646" ### IP to your nomad server 
        ]
      }
    }
  }
}
```

## 部署应用示例

```Nomad
job "whoami" {
  datacenters = ["dc1"]

  type = "service"

  group "demo" {
    count = 1

    network {
       port "http" {
         to = 80
       }
    }

    service {
      name = "whoami-demo"
      port = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Host(`whoami.nomad.localhost`)",
      ]
    }

    task "server" {
      env {
        WHOAMI_PORT_NUMBER = "${NOMAD_PORT_http}"
      }

      driver = "docker"

      config {
        image = "traefik/whoami"
        ports = ["http"]
      }
    }
  }
}
```

测试一下，看看是否起作用

```shell
curl -v http://whoami.nomad.localhost
*   Trying 10.27.71.49:80...
* Connected to whoami.nomad.localhost (10.27.71.49) port 80 (#0)
> GET / HTTP/1.1
> Host: whoami.nomad.localhost
> User-Agent: curl/7.79.1
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Content-Length: 365
< Content-Type: text/plain; charset=utf-8
< Date: Mon, 06 Jun 2022 11:56:11 GMT
<
Hostname: a65ebc9c1731
IP: 127.0.0.1
IP: 172.17.0.3
RemoteAddr: 172.17.0.1:60030
GET / HTTP/1.1
Host: whoami.nomad.localhost
User-Agent: curl/7.79.1
Accept: */*
Accept-Encoding: gzip
X-Forwarded-For: 172.17.0.1
X-Forwarded-Host: whoami.nomad.localhost
X-Forwarded-Port: 80
X-Forwarded-Proto: http
X-Forwarded-Server: 08f885acac7d
X-Real-Ip: 172.17.0.1
```
