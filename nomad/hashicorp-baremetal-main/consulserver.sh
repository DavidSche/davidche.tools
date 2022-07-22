#!/bin/bash
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
apt update && apt install curl unzip -y
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
cat > /etc/consul/config/server.json <<EOF
{
  "server": true,
  "ui": true,
  "data_dir": "/opt/consul/data",
  "advertise_addr": "$LOCAL_IP",
  "client_addr": "0.0.0.0",
  "bootstrap_expect": 1,
  "raft_protocol": 3
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
ExecReload=/bin/kill -HUP \$MAINPID
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
