job "demo-prefix" {
  datacenters = ["dc1"]
  group "demo" {
    count = 3
    network {
      port "demoprefix" { to = 80 }
    }

    task "server" {
      driver = "docker"
      config {
        image = "mendhak/http-https-echo"
        ports = ["demoprefix"]
      }
    }

    service {
      name = "demo-prefix"
      port = "demoprefix"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.demoprefix-http.rule=Host(`demo-prefix.nomad.habibiefaried.com`) && PathPrefix(`/test`)",
        "traefik.http.middlewares.demoprefix-http.stripprefix.prefixes=/test",
        "traefik.http.routers.demoprefix-http.middlewares=demoprefix-http@consulcatalog",
      ]
      check {
        port     = "demoprefix"
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }
  }
}