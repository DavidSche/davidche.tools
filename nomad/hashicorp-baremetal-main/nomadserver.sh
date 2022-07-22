#!/bin/bash
NOMAD_VERSION=1.0.4
CONSUL_VERSION=1.9.3
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
if [ -z "${LOCAL_IP}" ]
  then
  echo "Please set LOCAL_IP env variable that will be used for config"
  exit
fi
if [ -z "${CONSUL_SERVER_IP}" ]
  then
  echo "Please set CONSUL_SERVER_IP env variable that will be used for config"
  exit
fi
apt update && apt install curl unzip -y
echo "Installing Nomad..."
cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
unzip nomad.zip
install nomad /usr/bin/nomad
mkdir -p /etc/nomad/config
chmod -R a+w /etc/nomad
echo "Installing Consul..."
curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > /tmp/consul.zip
unzip /tmp/consul.zip
install consul /usr/bin/consul
mkdir -p /etc/consul
chmod a+w /etc/consul
mkdir -p /etc/consul/data
chmod a+w /etc/consul/data
mkdir -p /etc/consul/config
chmod a+w /etc/consul/config
HOSTNAME=`hostname`
cat > /etc/nomad/config/server.hcl <<EOF
bind_addr = "0.0.0.0"
log_level = "DEBUG"
data_dir = "/etc/nomad"
name = "$HOSTNAME"
server {
  enabled = true
  bootstrap_expect = 1
  raft_protocol = 3
}
advertise {
  http = "$LOCAL_IP"
  rpc = "$LOCAL_IP"
  serf = "$LOCAL_IP"
}
consul {
  address = "127.0.0.1:8500"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}
autopilot {
  cleanup_dead_servers      = true
  last_contact_threshold    = "200ms"
  max_trailing_logs         = 2500
  server_stabilization_time = "10s"
  enable_redundancy_zones   = false
  disable_upgrade_migration = false
  enable_custom_upgrades    = false
}
EOF
cat > /etc/systemd/system/nomad.service <<EOF
[Unit]
Description=Nomad
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
StandardOutput=append:/var/log/nomad.log
StandardError=append:/var/log/nomad.err
ExecStart=/usr/bin/nomad agent -config=/etc/nomad/config
ExecReload=/bin/kill -HUP \$MAINPID
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity

[Install]
WantedBy=multi-user.target
EOF
systemctl enable nomad
systemctl start nomad
cat > /etc/consul/config/client.json <<EOF
{
  "server": false,
  "ui": true,
  "data_dir": "/etc/consul/data",
  "advertise_addr": "$LOCAL_IP",
  "client_addr": "0.0.0.0",
  "retry_join": ["$CONSUL_SERVER_IP"]
}
EOF
cat > /etc/consul/config/connect.hcl <<EOF
connect {
  enabled = true
}
ports {
  grpc = 8502
}
EOF
cat > /etc/consul/config/ports.json <<EOF
{
  "ports": {
    "dns": 8600
  }
}
EOF
cat > /etc/systemd/system/consul.service <<EOF
[Unit]
Description=Consul
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
StandardOutput=append:/var/log/consul.log
StandardError=append:/var/log/consul.err
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul/config
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
LimitNOFILE=infinity
LimitNPROC=infinity
RestartSec=30
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable consul
systemctl start consul
