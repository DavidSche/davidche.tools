#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
echo "Installing dependencies..."
apt update
apt install dkms unzip strongswan build-essential fakeroot iproute2 -y 
apt install graphviz autoconf automake1.10 bzip2 debhelper dh-autoreconf libssl-dev libtool openssl procps python3-all python3-sphinx python3-twisted python3-zope.interface libunbound-dev libunwind-dev -y
echo "Downloading source..."
wget https://codeload.github.com/openvswitch/ovs/zip/master -O master.zip && unzip master.zip && cd ovs-master
echo "Check and compiling..."
dpkg-checkbuilddeps
automake --add-missing
DEB_BUILD_OPTIONS='parallel=8 nocheck' fakeroot debian/rules binary
cd ..
echo "Installing..."
dpkg -i *.deb || true
apt install -f -y
systemctl enable strongswan
systemctl enable openvswitch-switch
systemctl enable openvswitch-ipsec
systemctl restart openvswitch-switch
systemctl restart openvswitch-ipsec
systemctl restart strongswan