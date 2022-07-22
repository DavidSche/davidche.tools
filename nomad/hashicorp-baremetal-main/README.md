# hashicorp-baremetal

Hashicorp stack on baremetal deployment

# Spec

* 3 VPS S SSD servers on contabo.com (public IP only)
* Usage:
  *	161.97.158.37, for consul server
  *	161.97.158.38, for nomad server, with consul client
  * 161.97.158.40, for nomad client, with consul client
* For private networking choices, check `tunnelling` folder
* OS: Debian 10

# HashiCorp Commands

* List all members: `consul members`
* List all services (on server): `consul catalog services`
* List all nomad servers: `nomad server members`
* Consul raft: `consul operator raft list-peers`
* Nomad raft: `nomad operator raft list-peers`

# Nomad TLS

* Follow this steps: https://learn.hashicorp.com/tutorials/nomad/security-enable-tls. Certificate example (Do not use it) on `nomadtls` directory. See my `cfssl.json` file to make this cert has 100 year expiration time.

* If you want to use the UI, you need to set `verify_https_client` to `false`. and access the website through https protocol, ignore the security warning.

# Consul TLS

* Reference: https://learn.hashicorp.com/tutorials/consul/tls-encryption-secure

* add `-days` option to set the expiration time. mine is set to `-days=36500` alias 10 years. Example: `consul tls ca create -days=36500`, `consul tls cert create -days=36500 -server`.

# Notes

* Those are *real* my public IP, only temporary. It's being used for testbeds and experiments.
