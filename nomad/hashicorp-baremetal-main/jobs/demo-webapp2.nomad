job "demo-webapp2" {
  datacenters = ["dc1"]
  group "demo" {
    count = 3
    network {
      port "demowebapp2" { to = 80 }
    }

    task "server" {
      # template {
      #  data          = file(".env")
      #  destination   = ".env"
      #  env           = true
      # }

      driver = "docker"
      config {
        image = "mendhak/http-https-echo"
        ports = ["demowebapp2"]
      }
    }

    service {
      name = "demo-webapp2"
      port = "demowebapp2"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.demowebapp2-https.tls=true",
        "traefik.http.routers.demowebapp2-https.rule=Host(`demo-webapp2.nomad.habibiefaried.com`)",
        "traefik.http.routers.demowebapp2-https.tls.certresolver=myresolver",
        "traefik.http.routers.demowebapp2-https.tls.domains[0].main=demo-webapp2.nomad.habibiefaried.com",
        "traefik.http.routers.demowebapp2-http.rule=Host(`demo-webapp2.nomad.habibiefaried.com`)",
      ]
      check {
        port     = "demowebapp2"
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }
  }
}