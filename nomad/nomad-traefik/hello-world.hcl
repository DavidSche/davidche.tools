job "hello-world" {
  type        = "service"
  datacenters = ["dc1"]


  group "hello-world" {

    network {
      mode = "bridge"

      port "http" {
        to = 80
      }
    }

    service {
      tags = [
        "traefik.http.routers.hello-world.rule=Host(`hello-world.domain.com`)",
        "traefik.http.routers.hello-world.entrypoints=websecure",
        "traefik.http.routers.hello-world.tls=true",
        "traefik.enable=true",
      ]

      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "5s"
      }
    }

    task "hello-world" {
      driver = "docker"

      config {
        image = "caddy"
        ports = ["http"]
      }

      resources {}
    }
  }
}
