template {
  data = <<EOH
api:
  debug: true
 EOH
  destination = "local/traefik.yml"
  change_mode = "noop"
}