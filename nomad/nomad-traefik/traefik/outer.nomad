job "outer_service" {
  datacenters = ["dc1"]

  group "service" {
    count = 2

    spread {
      attribute = "${node.unique.id}"
    }

    network {
      port "http" {
        to = 4001
      }
    }

    service {
      name     = "outer"
      provider = "nomad"
      port     = "http"
      address  = "10.10.100.51"
#      address  = "${attr.unique.platform.aws.public-ipv4}"
      tags     = [
        "traefik.enable=true",
        "traefik.http.routers.http.rule=Path(`/outer`)",
        # SSL 使用
        "traefik.http.routers.http.tls=true",
        "traefik.http.routers.http.tls.certresolver=myresol",
      ]
    }

    task "curler" {
      driver = "docker"

      config {
        image = "mnomitch/curler"
        ports = ["http"]
      }

      env {
        PORT = 4001
      }

      # This gets a list of the addresses for inner-service and selects the first to query
      template {
        data = <<EOH
{{- range $index, $service := nomadService "inner" }}
{{- if eq $index 0}}
CURL_ADDR="http://{{.Address}}:{{.Port}}"
{{- end }}
{{- end }}
EOH
        destination = "local/file.env"
        env         = true
      }
    }
  }
} 