# PPTP

PPTP between 2 hosts

## Server

Install PPTP

```
apt install pptpd -y
```

Make sure file `/etc/pptpd.conf` have this content

```
option /etc/ppp/pptpd-options
logwtmp
localip 192.168.0.1
remoteip 192.168.0.101-245
```

Make sure that, the subnet 192.168.0.1/24 is not being used anywhere on system
Add DNS on this file `/etc/ppp/pptpd-options`

```
ms-dns 8.8.8.8
ms-dns 4.2.2.2
```

Add the user entry on file `/etc/ppp/chap-secrets`

```
user1 pptpd password1 192.168.1.105
```

Edit file `/etc/sysctl.conf` and add this entry

```
net.ipv4.ip_forward = 1
```

then issue this command to see the changes

```
# sysctl -p /etc/sysctl.conf
net.ipv4.ip_forward = 1
```

Add this IP table rule. Assumed that, the gateway is coming from `eth0`

```
iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE
iptables -I INPUT -s 192.168.0.0/24 -i ppp0 -j ACCEPT
iptables --append FORWARD --in-interface eth0 -j ACCEPT
```

Enable and restart the server

```
systemctl enable pptpd
service pptpd restart
```

## Client

Install

```
apt-get -y install pptp-linux -y
```

Then open file `/etc/ppp/chap-secrets`. Add this entry

```
user1 pptpd password1 *
```

Open file `/etc/ppp/peers/161.97.158.40` and add this entry 

```
pty "pptp 161.97.158.40 --nolaunchpppd"
name user1
remotename 161.97.158.40
require-mppe-128
file /etc/ppp/options.pptp
ipparam 161.97.158.40
```

Open file `/etc/ppp/ip-up.d/99vpnroute` and add this script

```
#!/bin/bash
if [ "$PPP_IPPARAM" == "161.97.158.40" ]; then
        route add -net 192.168.0.0/24 dev $PPP_IFACE
fi
```

and the make that file executable

## Ga jalan