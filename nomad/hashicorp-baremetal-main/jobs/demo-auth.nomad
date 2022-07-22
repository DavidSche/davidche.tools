job "demo-auth" {
  datacenters = ["dc1"]
  group "demo" {
    count = 3
    network {
      port "demoauth" { to = 80 }
    }

    task "server" {
      driver = "docker"
      config {
        image = "mendhak/http-https-echo"
        ports = ["demoauth"]
      }
    }

    service {
      name = "demo-auth"
      port = "demoauth"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.demoauth-http.rule=Host(`demo-auth.nomad.habibiefaried.com`)",
        "traefik.http.middlewares.demoauth-http.basicauth.users=admin:$apr1$ilatsgyn$bkm6zIYXeRnizLOBJ44R31",
        "traefik.http.routers.demoauth-http.middlewares=demoauth-http@consulcatalog",
      ]
      check {
        port     = "demoauth"
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }
  }
}