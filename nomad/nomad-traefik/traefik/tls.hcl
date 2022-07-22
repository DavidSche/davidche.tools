template {
  data        = <<EOH
TLS:
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