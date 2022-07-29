job "traefik" {
  datacenters = ["dc1"]
  type        = "system"

  group "traefik" {
    network {
      mode = "host"
      port "http" {
        to = 80
        static = 80
      }

      port "https" {
        to = 443
        static = 443
      }

      port "admin" {
        to = 8080   //container port
        static = 8080   //host port
      }
    }

    task "server" {
      driver = "docker"

      env {
        TZ = "Asia/Shanghai"
      }

      config {
        image = "traefik:2.8"
        ports = ["admin", "http", "https"]
        // Replace providers.nomad.endpoint.address with your address!
        args = [
          "--api.dashboard=true",
          "--api.insecure=true", 
          "--log.filePath=/home/traefik/traefik.log",
          "--log.format=json",
          "--log.level=DEBUG",
          "--accesslog=true",
          "--accesslog.filepath=/home/traefik/access.log",
          "--accesslog.bufferingsize=100",
          "--accesslog.format=json",
          "--accesslog.fields.defaultmode=keep",
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--entrypoints.websecure.address=:${NOMAD_PORT_https}",
          # SSL configuration
          "--certificatesresolvers.letsencryptresolver.acme.httpchallenge=true",
          "--certificatesresolvers.letsencryptresolver.acme.httpchallenge.entrypoint=web",
          "--certificatesresolvers.letsencryptresolver.acme.email=user@domaine.com",
          "--certificatesresolvers.letsencryptresolver.acme.storage=/letsencrypt/acme.json",
          # Global HTTP -> HTTPS
          "--entrypoints.web.http.redirections.entryPoint.to=websecure",
          "--entrypoints.web.http.redirections.entryPoint.scheme=https",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://127.0.0.1:4646"  ### IP to your nomad server
        ]
      }
    }
  }
}

#"--providers.nomad=true", 
#"--providers.nomad.endpoint.address=http://192.168.178.39:4646" ### IP to your nomad server
#--tracing.elastic.serverurl="http://apm:8200"
#--tracing.elastic=true
#--tracing=true
