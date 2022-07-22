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

      port "admin" {
        to = 8080   //container port
        static = 8080   //host port
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "traefik:2.8"
        ports = ["admin", "http"]
        // Replace providers.nomad.endpoint.address with your address!
        args = [
          "--api.dashboard=true",
          "--api.insecure=true",
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://127.0.0.1:4646"  ### IP to your nomad server
        ]
      }
    }
  }
}

#"--providers.nomad=true",
#"--providers.nomad.endpoint.address=http://192.168.178.39:4646" ### IP to your nomad server