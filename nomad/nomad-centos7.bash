# this is a bag of functions sourced by another script

if [[ $BASH_VERSINFO -lt "4" ]]; then
	echo "!! Your system Bash is out of date: $BASH_VERSION"
	echo "!! Please upgrade to Bash 4 or greater."
	exit 2
fi

if [[ $EUID -ne 0 ]]; then
	echo "!! This script must be run as root"
	exit 2
fi

yum update -y
yum install unzip wget -y

docker-install() {
	tee /etc/yum.repos.d/docker.repo <<-'EOF'
		[dockerrepo]
		name=Docker Repository
		baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
		enabled=1
		gpgcheck=1
		gpgkey=https://yum.dockerproject.org/gpg
	EOF

	yum install docker-engine -y
}

docker-configure() {
	declare ca_file="${1}" registry_domain="${2:-docker-registry.service.consul}"
	# https://github.com/docker/docker/issues/16256
	# https://twitter.com/ibuildthecloud/status/638397128042135552
	# https://github.com/hashicorp/nomad/issues/171
	local docker_opts="--exec-opt native.cgroupdriver=cgroupfs --disable-legacy-registry"

	if [[ -n $ca_file ]]; then
		mkdir -p "/etc/docker/certs.d/${registry_domain}:22222/"
		echo "${ca_file}" | tee "/etc/docker/certs.d/${registry_domain}:22222/ca.crt"
	else
		docker_opts="${docker_opts} --insecure-registry ${registry_domain}:22222"
	fi

	# Enables overlay storage backend which is faster and more stable than
	# DeviceMapper for high density environments. If writing big files
	# use BRTFS or DeviceMapper. But, be aware that DeviceMapper is not stable
	# in CentOS7, udev races pop up once in a while making Docker to fail
	# running containers which use volumes.
	docker_opts="${docker_opts} -s overlay"

	# Enables debugging
	docker_opts="${docker_opts} --debug"
	echo "OPTIONS='${docker_opts}'" > /etc/sysconfig/docker

	# Systemd drop-in unit to overwrite upstream Systemd unit file as
	# documented in https://docs.docker.com/engine/articles/systemd/
	mkdir -p /etc/systemd/system/docker.service.d
	tee /etc/systemd/system/docker.service.d/options.conf <<-"EOF"
		[Service]
		EnvironmentFile=-/etc/sysconfig/docker
		ExecStart=
		ExecStart=/usr/bin/docker daemon -H fd:// $OPTIONS
	EOF

	systemctl daemon-reload

	# Makes sure Docker is initialized on boot.
	systemctl enable docker.service
}

docker-service() {
	systemctl restart docker
}

consul-install() {
	declare version="${1:-0.6.0}"
	declare url="${2:-https://releases.hashicorp.com/consul/${version}/consul_${version}_linux_amd64.zip}"

	if [[ $(consul --version | cut -d " " -f 2 | grep v) == "v$version" ]]; then
		echo "Consul version ${version} is already installed, skipping."
		return 0
	fi

	echo "Fetching Consul..."
	cd /tmp/
	wget "${url}" -O consul.zip
	echo "Installing Consul..."
	unzip consul.zip
	chmod +x consul
	mv consul /usr/bin/consul
}

consul-configure() {
	declare mode="${1:-server}" datacenter="${2:-dc1}" bootstrap_expect="${3:-1}" retry_join="${4:-localhost}"
	declare encryption_key="${5:-tIrI/lgDFMUX6K8KqlUJwg==}" ca_file="${6}" cert_file="${7}" key_file="${8}"
	declare acl_token="${9}" domain="${10:-consul}" advertise="${11:-127.0.0.1}"

	mkdir -p /etc/consul.d/{ssl,services} /var/lib/consul

	if [[ $mode == "server" ]]; then
		tee /etc/consul.d/server.json <<-EOF
		{
			"server": true,
			"bootstrap_expect": ${bootstrap_expect}
		}
		EOF
	fi

	if [[ -n $acl_token ]]; then
		tee /etc/consul.d/acl.json <<-EOF
		{
			"acl_token": "${acl_token}"
		}
		EOF
	fi

	if [[ -n $ca_file ]]; then
		echo "${ca_file}" | tee /etc/consul.d/ssl/ca.cert

		tee /etc/consul.d/tls1.json <<-EOF
		{
			"ca_file": "/etc/consul.d/ssl/ca.cert",
			"verify_outgoing": true,
			"verify_server_hostname": false
		}
		EOF
	fi

	if [[ -n $cert_file && -n $key_file ]]; then
		echo "${cert_file}" | tee /etc/consul.d/ssl/consul.cert
		echo "${key_file}" | tee /etc/consul.d/ssl/consul.key

		tee /etc/consul.d/tls2.json <<-EOF
		{
			"cert_file": "/etc/consul.d/ssl/consul.cert",
			"key_file": "/etc/consul.d/ssl/consul.key",
			"verify_incoming": true
		}
		EOF
	fi

	tee /etc/consul.d/common.json <<-EOF
	{
		"domain": "${domain}",
		"advertise_addr": "${advertise}",
		"data_dir": "/var/lib/consul",
		"log_level": "INFO",
		"enable_syslog": true,
		"datacenter": "${datacenter}",
		"retry_join": ["${retry_join}"],
		"encrypt": "${encryption_key}"
	}
	EOF

	# Consul Service
	tee /usr/lib/systemd/system/consul.service <<-EOF
		[Unit]
		Description=Consul Agent
		Requires=network-online.target
		After=network-online.target
		[Service]
		Restart=on-failure
		ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d -config-dir=/etc/consul.d/services
		ExecReload=/usr/bin/consul reload
		# This is to avoid SystemD re-spawning the process upon `consul leave`
		KillSignal=SIGINT
		[Install]
		WantedBy=multi-user.target
	EOF

	# Makes sure any changes in systemd units are reloaded from disk by SystemD
	systemctl daemon-reload
}

consul-service() {
	systemctl enable consul.service
	if [[ $(systemctl status consul | grep running) ]]; then
		systemctl reload consul
	else
		systemctl start consul
	fi
}

consul-register-local-service() {
	declare id="${1}" name="${2}" port="${3}"

	if [[ -z $id ]]; then
		id="${name}"
	fi

	# We don't specify the address since Consul uses the agent's address
	# by default.
	tee "/etc/consul.d/services/${name}.json" <<-EOF
		{
			"service": {
				"id": "${id}",
				"name": "${name}",
				"port": ${port},
				"check": {
					"tcp": "localhost:${port}",
					"interval": "10s"
				}
			}
		}
	EOF

	# Reload Consul configuration using its own command instead of sending HUP signals
	/usr/bin/consul reload
}

dnsmasq-install() {
	declare domain=${1:-consul}

	yum install dnsmasq -y
	systemctl enable dnsmasq.service

	tee /etc/dnsmasq.d/10-consul <<-EOF
		server=/${domain}/127.0.0.1#8600
		listen-address=127.0.0.1
		bind-interfaces
	EOF
	systemctl restart dnsmasq

	# If for any reason the DHCP lease expires this make sure to prepend
	# dnsmasq as name server in /etc/resolv.conf
	tee /etc/dhcp/dhclient.d/10-consul <<-EOF
		prepend domain-name-servers 127.0.0.1;
	EOF

	# Makes sure to prepend localhost as resolver in case of rebooting the EC2 instance
	# or renewing a DHCP lease. We are doing this instead of prepending the domain on a dhclient.d/
	# configuration because we noticed it to be unreliable.
	tee /usr/lib/systemd/system/consul-resolver.service <<-EOF
		[Unit]
		Description=Consul Resolver
		Requires=network-online.target
		After=network-online.target
		[Service]
		Type=oneshot
		RemainAfterExit=yes
		ExecStart=/bin/bash -c '/usr/bin/grep -q "nameserver 127.0.0.1" /etc/resolv.conf || /usr/bin/sed -i -e "1inameserver 127.0.0.1" /etc/resolv.conf'
		[Install]
		WantedBy=multi-user.target
	EOF

	systemctl enable consul-resolver.service
	systemctl restart consul-resolver
}

nomad-install() {
	declare version="${1:-0.2.3}"
	declare url="${2:-https://releases.hashicorp.com/nomad/${version}/nomad_${version}_linux_amd64.zip}"

	if [[ "$(nomad version | cut -d " " -f 2)" == "v$version" ]]; then
		echo "Nomad version ${version} is already installed, skipping."
		return 0
	fi
	echo "Fetching Nomad..."
	cd /tmp/
	wget "$url" -O nomad.zip
	echo Installing Nomad...
	unzip nomad.zip
	chmod +x nomad
	mv nomad /usr/bin/nomad
}

nomad-configure() {
	declare mode="${1:-dev}" datacenter="${2:-dc1}" bootstrap_expect="${3:-3}"
	declare server="${4}" advertise="${5:-127.0.0.1}" node_class="${6}"
	mkdir -p /etc/nomad.d /var/lib/nomad

	local service
	! read -rd '' service <<-EOF
		[Service]
		Type=simple
		Restart=on-failure
		# This is to avoid SystemD re-spawning the process upon a graceful leave
		KillSignal=SIGINT
		ExecStart=/usr/bin/nomad agent -${mode} -config=/etc/nomad.d
		ExecReload=/bin/kill -HUP \$MAINPID
		LimitNOFILE=1048576
		LimitNPROC=1048576
		LimitCORE=infinity
		[Install]
		WantedBy=multi-user.target
	EOF

	if [[ $mode == "server" ]]; then
		tee /usr/lib/systemd/system/nomad.service <<-EOF
			[Unit]
			Description=Nomad Server
			After=network.target consul.service
			Requires=consul.service
			${service}
		EOF

		tee /etc/nomad.d/server.hcl <<-EOF
			bind_addr = "0.0.0.0"
			server {
				enabled = true
				bootstrap_expect = ${bootstrap_expect}
				retry_join = ["${server}"]
			}
			advertise {
				rpc = "${advertise}:4647"
				serf = "${advertise}:4648"
			}

		EOF
	elif [[ $mode == "client" ]]; then
		tee /usr/lib/systemd/system/nomad.service <<-EOF
			[Unit]
			Description=Nomad Worker
			After=network.target docker.socket consul.service
			Requires=docker.socket consul.service
			${service}
		EOF

		tee /etc/nomad.d/client.hcl <<-EOF
			client {
				node_class = "${node_class}"
				enabled = true
				servers = ["${server}:4647"]
			}
		EOF
	else
		tee /usr/lib/systemd/system/nomad.service <<-EOF
			[Unit]
			Description=Nomad Dev
			After=network.target docker.socket
			Requires=docker.socket
			${service}
		EOF

		tee /etc/nomad.d/dev.hcl <<-EOF
			bind_addr = "0.0.0.0"
			advertise {
				rpc = "127.0.0.1:4647"
				serf = "127.0.0.1:4648"
			}
		EOF
	fi

	tee /etc/nomad.d/common.hcl <<-EOF
		data_dir = "/var/lib/nomad"
		# Exit gracefully
		leave_on_interrupt = true
		log_level = "DEBUG"
		enable_syslog = true
		syslog_facility = "LOCAL0"
		datacenter = "${datacenter}"
	EOF

	# Makes sure any changes in systemd units are reloaded from disk by SystemD
	systemctl daemon-reload
}

nomad-service() {
	systemctl enable nomad.service

	if [[ $(systemctl status nomad | grep running) ]]; then
		systemctl reload nomad
	else
		systemctl start nomad
	fi
}

haproxy-install() {
	yum install haproxy -y
}

haproxy-configure() {
	# By default, HAProxy in CentOS7 is configured with a SELinux policy
	# that only allows outcoming TCP connections on a limited set of ports,
	# breaking any checks we add to the backend servers.
	# The following tells SELinux to allow HAProxy to do TCP checks on the range
	# of ports used by Nomad workers.
	yum install policycoreutils-python -y
	/usr/sbin/semanage port --add --type http_port_t --proto tcp 20000-60000
}

haproxy-service() {
	systemctl enable haproxy.service
	if [[ $(systemctl status haproxy | grep running) ]]; then
		systemctl reload haproxy
	else
		systemctl start haproxy
	fi
}

consul-template-install() {
	declare version="${1:-0.12.0}"
	declare url="${2:-https://releases.hashicorp.com/consul-template/${version}/consul-template_${version}_linux_amd64.zip}"

	# For some strange reason consul-template prints its version through stderr
	# so we are using |& to redirect stderr to stdout. |& is a new operator in Bash 4,
	# synonim for 2>&1 |
	if [[ $(consul-template --version |& cut -d " " -f 2) == "v$version" ]]; then
		echo "Consul Template version ${version} is already installed, skipping."
		return 0
	fi

	echo "Fetching Consul Template..."
	cd /tmp/
	wget "${url}" -O consul-template.zip
	echo "Installing Consul Template..."
	unzip consul-template.zip
	chmod +x consul-template
	mv consul-template /usr/bin/consul-template
}

# There is no need to specify a token if the local Consul agent has it configured.
consul-template-configure() {
	declare acl_token="${1}"
	mkdir -p /etc/consul.d/template/{config,templates}

	tee /etc/consul.d/template/config/common.hcl <<-EOF
		consul = "127.0.0.1:8500"
		retry = "5s"
		log_level = "info"
		syslog {
			enabled = true
		}
	EOF

	if [[ -n $acl_token ]]; then
		tee /etc/consul.d/template/config/acl.hcl <<-EOF
			token = "${acl_token}"
		EOF
	fi

	# Consul Template Service
	tee /usr/lib/systemd/system/consul-template.service <<-EOF
		[Unit]
		Description=Consul Template
		Requires=network-online.target consul.service
		After=network-online.target consul.service
		[Service]
		Restart=on-failure
		ExecReload=/bin/kill -HUP \$MAINPID
		ExecStart=/usr/bin/consul-template -config=/etc/consul.d/template/config
		[Install]
		WantedBy=multi-user.target
	EOF

	# Makes sure any changes in systemd units are reloaded from disk by SystemD
	systemctl daemon-reload
}

consul-template-service() {
	systemctl enable consul-template.service
	if [[ $(systemctl status consul-template | grep running) ]]; then
		systemctl reload consul-template
	else
		systemctl start consul-template
	fi
}

consul-template-add() {
	declare name="${1}" content="${2}" dst_file="${3}" cmd="${4}"

	local source="/etc/consul.d/template/templates/${name}.ctmpl"
	echo "${content}" > "${source}"

	tee "/etc/consul.d/template/config/${name}-ctmpl.hcl" <<-EOF
		template {
			source = "${source}"
			destination = "${dst_file}"
			command = "${cmd}"
			backup = true
		}
	EOF

	consul-template-service
}

kernel-upgrade() {
	local major
	major="$(uname -r | cut -d '.' -f 1)"

	if (( $major == 4 )); then
		echo "Kernel is up to date, skipping upgrade."
		return 0
	fi
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
	yum --enablerepo=elrepo-kernel install kernel-ml -y
	grub2-set-default 0

	# Stops Nomad from receiving jobs while the rebooting job kicks in
	systemctl stop nomad

	#
	# Schedules shutdown in 1 minute within a coprocess to not block
	# this script and Nimbul 3 can have a chance to set the server to "ready"
	coproc shutdown -r +1
}0