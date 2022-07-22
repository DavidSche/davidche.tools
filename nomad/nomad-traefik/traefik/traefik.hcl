job "Traefik" {
  type        = "system"
  datacenters = ["dc1"]

  group "svc" {
    update {
      auto_revert = true
    }
    network {
      mode = "host"

      port "http" {
        to     = 80
        static = 80
      }

      port "https" {
        to     = 443
        static = 443
      }

      port "api" {
        to     = 8080
        static = 8080
      }

      port "metrics" {
        to     = 8082
        static = 8082
      }
    }

    service {
      tags = [
        "traefik",
        "traefik.enable=true",
        "traefik.http.routers.dashboard.rule=Host(`traefik.dns.domain`)",
        "traefik.http.routers.dashboard.service=api@internal",
        "traefik.http.routers.dashboard.entrypoints=web,websecure",
      ]

      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "5s"
      }
    }

    service {
      tags = ["lb", "exporter"]
      port = "metrics"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "5s"
      }
    }

    service {
      tags = ["lb", "api"]
      port = "api"

      check {
        type     = "http"
        path     = "/ping"
        interval = "10s"
        timeout  = "5s"
      }
    }

    task "loadbalancer" {
      driver = "docker"

      config {
        network_mode = "host"
        command      = "traefik"
        args         = ["--configFile", "/local/Traefik.yml"]
        image        = "traefik:latest"
        ports        = ["http", "api", "metrics"]
      }
      template {
        data        = <<EOH
tls:
 certificates:
   - certFile: /local/lb.crt
     keyFile: /local/lb.key
 stores:
   default:
     defaultCertificate:
       certFile: /local/lb.crt
       keyFile: /local/lb.key
EOH
        destination = "/local/dynamic.yml"
        change_mode = "restart"
        splay       = "1m"
      }


      template {
        data        = <<EOH
<< certificate information>>>
EOH
        destination = "/local/lb.key"
        change_mode = "restart"
        splay       = "1m"
      }
      template {
        data        = <<EOH
<< certificate information>>>
 EOH
        destination = "/local/lb.crt"
        change_mode = "restart"
        splay       = "1m"
      }


      template {
        data = <<EOH
CONSUL_HTTP_TOKEN=<<CONSUL TOKEN>>
EOH

        env         = true
        destination = "secrets/traefik.env"
        change_mode = "noop"
      }

      template {
        data = <<EOH
serversTransport:
 insecureSkipVerify: true
entryPoints:
 web:
   address: ":80"
 websecure:
   address: ":443"
 metrics:
   address: ":8082"
api:
 dashboard: true
 insecure: true
 debug: true
ping: {}
accessLog: {}
log:
 level: DEBUG
metrics:
 prometheus:
   entryPoint: metrics
providers:
 providersThrottleDuration: 15s
 file:
   watch: true
   filename: "/local/dynamic.yml"
 consulCatalog:
   endpoint:
     scheme: http
     address: http://localhost:8500
     token: <<TOKEN>>
   cache: true
   prefix: traefik
   exposedByDefault: false
 EOH

        destination = "local/traefik.yml"
        change_mode = "noop"
      }

      resources {
        memory = 128
      }
    }
  }
}
#}