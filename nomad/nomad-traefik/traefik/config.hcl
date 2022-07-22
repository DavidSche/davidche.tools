config {
       network_mode = "host"
       command      = "traefik"
       args         = ["--configFile", "/local/Traefik.yml"]
       image        = "traefik:latest"
       ports        = ["http", "api", "metrics"]
     }