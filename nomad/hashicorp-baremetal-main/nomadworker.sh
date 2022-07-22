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
echo "Installing docker..."
apt update
apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io -y
systemctl enable docker
service docker reload
docker run hello-world
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
cat > /etc/nomad/config/worker.hcl <<EOF
bind_addr = "0.0.0.0"
log_level = "DEBUG"
data_dir = "/etc/nomad"
name = "$HOSTNAME"
client {
  enabled = true
  "options" = {
    "docker.auth.config" = "/root/.docker/config.json"
    "driver.raw_exec.enable" = "1"
    "docker.privileged.enabled" = "true"
  }
  reserved {
    reserved_ports = "22,53,68,111,8301,8500,8600,`cat /proc/sys/net/ipv4/ip_local_port_range | cut -f1`-`cat /proc/sys/net/ipv4/ip_local_port_range | cut -f2`"
  }
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
curl -L -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tgz
mkdir -p /opt/cni/bin
tar -C /opt/cni/bin -xzf cni-plugins.tgz