# Setup Traefik v2 step by step

Published at2020-01-28Updated at2020-01-28

This tutorial was written for Traefik v2. Please go to Setup Traefik step by step for Traefik v1.

Traefik is a open source reverse proxy / load balancer which is raising in popularity because of its ease to setup, integration with Docker and Let’s encrypt and much more features.

This guide will help you to go through how to setup Traefik step by step.

Traefik v2 introduces a number of breaking changes which require users to update their configuration. You can read the migration guide from the official document but I found it is no sufficient for me to migrate. So, I wrote this tutorial for who also finds it is difficult to migrate.

Note that I will use YAML configuration instead of TOML because I am more familiar with YAML and it looks cleaner to me.

raefik是一个开源反向代理/负载平衡器，由于易于设置、与Docker集成以及让我们加密和更多功能而日益流行。

本指南将帮助您逐步了解如何设置Traefik。

Traefik v2引入了许多重大更改，这些更改要求用户更新其配置。您可以阅读官方文档中的迁移指南，但我发现这不足以迁移。因此，我为谁也很难迁移的人编写了本教程。

请注意，我将使用YAML配置而不是TOML，因为我对YAML更加熟悉，并且对我来说看起来更干净。

先决条件



在Traefik v1中，它使用前端和后端来处理请求的处理方式。但是，设计存在一个问题，即您无法配置各个前端和后端。大多数配置都全局应用。

Traefik v2引入了路由器，中间件和服务。

路由器：定义要接受的请求。最常见的一种是按域接受。
中间件：将更改应用于请求，例如添加和删除标头。
服务：定义将请求发送到的位置，包括负载平衡

## 准备

- 基本的Docker知识 您应该知道如何使用docker-compose运行docker镜像.
- Docker环境。我们将与Docker一起部署Traefik。您需要一个工作的Docker环境。

路由器，中间件和服务 Routers, Middlewares, and Services

In Traefik v1, it uses frontends and backends to handle how the requests is handle. However, the design has a problem that you cannot configure individual frontend and backend. Most of the configuration apply globally.

Traefik v2 introduces routers                                                                      , middlewares, services.

Routers: Defines what requests to accept. The most common one is accept by domain.
Middlewares: Applies changes to requests, like adding and removing headers.
Services: Defines where the requests are sent to, including load-balancing.
Entry Points
First, you need to create a configuration file for Traefik. You can use environment or command line arguments.

# /etc/traefik/traefik.yml
```

entryPoints:
  http:
    address: :80
  https:
    address: :443
```
It defines two entry points http and https which accept requests on port 80 and 443. You can name the entry points differently if you want.

Let’s Encrypt
Traefik can request and renew a certificate from Let’s Encrypt.

# /etc/traefik/traefik.yml

```
entryPoints:
  http:
    address: :80
  https:
    address: :443

certificatesResolvers:
  letsEncrypt:
    acme:
      email: you@example.com
      storage: /etc/traefik/acme/acme.json
      dnsChallenge:
        provider: cloudflare
        delayBeforeCheck: 0
```

It defines a certificates resolver named letsEncrypt. You can have multiple certificates resolvers.

email defines notification Email address when you request certificate from Let’s Encrypt.
storage defines where the certificate is stored.
In this example, it uses DNS challenge but you can also use TLS or HTTP challenge. DNS challenge is recommended because it can request wildcard certificates and bypass CDN problems but it requires the your DNS providers are supported. Here is a list of providers that are supported. You are required to define additional environment variable(s) depends on your provider.

Cloudflare DNS Provider
If you are using Cloudflare as DNS provider, you need to define CF_API_EMAIL, CF_DNS_API_TOKEN, CF_ZONE_API_TOKEN in environment variables. Latest Cloudflare API allows you to create token with different privileges. You should not use CF_API_KEY any more.

You need to create a token with Zone > Zone > Read and Zone > DNS > Edit and it should include domains in zone resources. They can be the same token.

Docker
First, you need to define Docker provider in the configuration.

# /etc/traefik/traefik.yml

```
entryPoints:
  http:
    address: :80
  https:
    address: :443

certificatesResolvers:
  letsEncrypt:
    acme:
      email: you@example.com
      storage: /etc/traefik/acme/acme.json
      dnsChallenge:
        provider: cloudflare
        delayBeforeCheck: 0

providers:
  docker:
    endpoint: unix:///var/run/docker.sock
    exposedByDefault: false
```

It is not recommended to expose container by default. Let's create a whoami container.

```yml

version: "3"

services:
  whoami:
    image: containous/whoami
    labels:
      - traefik.enable=true
      - traefik.http.routers.whoami.rule=Host(`whoami.example.com`)
      - traefik.http.routers.whoami.tls=true
      - traefik.http.routers.whoami.tls.certresolver=letsEncrypt
      - traefik.http.routers.whoami.service=whoami
      - traefik.http.services.whoami.loadbalancer.server.port=80
```

whoami in traefik.http.routers.whoami and traefik.http.services.whoami are just the name. You can use what you want.

traefik.enable: This is needed if you set exposedByDefault to false
traefik.http.routers.whoami.rule: This defines it accept requests for whoami.example.com.
traefik.http.routers.whoami.tls: Setting it to true will try to generate a certificate with rule.
traefik.http.routers.whoami.tls.certresolver: It defines how it should request certificate.
traefik.http.routers.whoami.service: It defines the name of this service.
traefik.http.services.whoami.loadbalancer.server.port: It defines the port of the container.
You should able to visit whoami.example.com after starting the container.

File
File provider is now needed to put in a directory.

# /etc/traefik/traefik.yml

```yml

entryPoints:
  http:
    address: :80
  https:
    address: :443

certificatesResolvers:
  letsEncrypt:
    acme:
      email: you@example.com
      storage: /etc/traefik/acme/acme.json
      dnsChallenge:
        provider: cloudflare
        delayBeforeCheck: 0

providers:
  docker:
    endpoint: unix:///var/run/docker.sock
    exposedByDefault: false
  file:
    directory: /etc/traefik/dynamic/
```

# /etc/traefik/dynamic/custom.yml

```yml

http:
  routers:
    custom:
      rule: Host(`custom.example.com`)
      service: custom
      tls:
        certresolver: letsEncrypt

  services:
    custom:
      loadBalancer:
        servers:
          - url: http://192.168.1.1:8080

```

This defines a service from a internal address.

Dashboard
Last but not least, Traefik provide a dashboard to monitor the traffic.

# /etc/traefik/traefik.yml

```yml

entryPoints:
  http:
    address: :80
  https:
    address: :443

certificatesResolvers:
  letsEncrypt:
    acme:
      email: you@example.com
      storage: /etc/traefik/acme/acme.json
      dnsChallenge:
        provider: cloudflare
        delayBeforeCheck: 0

providers:
  docker:
    endpoint: unix:///var/run/docker.sock
    exposedByDefault: false
  file:
    directory: /etc/traefik/dynamic/

api:
  dashboard: true
```

``` yml
# /etc/traefik/dynamic/dashboard.yml

http:
  routers:
    dashboard:
      rule: Host(`traefik.example.com`)
      service: api@internal # This is the defined name for api. You cannot change it.
      tls:
        certresolver: letsEncrypt
```

It routes traefik.example.com to API dashboard.

Redirect HTTP to HTTPS
You can limit routers to listen only https. You can add entryPoints like

```yml

# /etc/traefik/dynamic/dashboard.yml

http:
  routers:
    dashboard:
      entryPoints:
        - https
      rule: Host(`traefik.example.com`)
      service: api@internal # This is the defined name for api. You cannot change it.
      tls:
        certresolver: letsEncrypt
```

or add traefik.http.routers.whoami.entrypoints=https to labels.

Then, you can a router to handle all HTTP requests.

```yml
# /etc/traefik/dynamic/redirect.yml
http:
  routers:
    http:
      entryPoints:
        - http
      middlewares:
        - https_redirect
      rule: HostRegexp(`{any:.+}`)
      service: noop

  services:
    # noop service, the URL will be never called
    noop:
      loadBalancer:
        servers:
          - url: http://192.168.0.1

  middlewares:
    https_redirect:
      redirectScheme:
        scheme: https
        permanent: true
```

This routers use a middleware which redirects HTTP request to HTTPS.

Client Authentication
This part is not necessary, you can skip it. Client authentication limits who can access it. For example, if you uses a CDN, you want others go through CDN instead of directly accessing.

Cloudflare provides a certificate authority when they request your server.

You just need to add a dynamic configuration.

```
# /etc/traefik/dynamic/clientAuthentication.yml

tls:
  options:
    default:
      clientAuth:
        caFiles:
          - /etc/traefik/cloudflare.pem
        clientAuthType: RequireAndVerifyClientCert
```

The default value for tls.options is default. This will apply to all routers. If the request does not go through Cloudflare, Traefik will reject it.

## 结论

Traefik v2 允许进行更精细的配置，并接受YAML，这对我来说是一个加分项。但是，这也使配置更加冗长。

如果您想了解有关Traefik的更多信息，请查阅其文档。