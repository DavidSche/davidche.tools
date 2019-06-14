wget -qO - https://packages.fluentbit.io/fluentbit.key | sudo apt-key add -
# Add new source
echo "deb https://packages.fluentbit.io/debian/stretch stretch main" | sudo tee -a /etc/apt/sources.list

sudo apt-get update
sudo apt-get install -y td-agent-bit
sudo systemctl start td-agent-bit
