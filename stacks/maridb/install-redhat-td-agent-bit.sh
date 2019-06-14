echo "=============================="
echo " td-agent Installation Script "
echo "=============================="
echo "This script requires superuser access to install rpm packages."
echo "You will be prompted for your password by sudo."

# clear any previous sudo permission
sudo -k

# run inside sudo
sudo sh <<SCRIPT
  # add GPG key
  rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent
  # add treasure data repository to yum
  cat >/etc/yum.repos.d/td-agent-bit.repo <<'EOF';
[td-agent-bit]
name = TD Agent Bit
baseurl = http://packages.fluentbit.io/centos/7
gpgcheck=1
gpgkey=http://packages.fluentbit.io/fluentbit.key
enabled=1
EOF
  # update your sources
  yum check-update
  # install the toolbelt
  yes | yum install -y td-agent-bit
SCRIPT

# message
echo ""
echo "Installation completed. Happy Logging!"
echo ""