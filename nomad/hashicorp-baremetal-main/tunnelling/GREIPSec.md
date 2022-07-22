# GREIPSec

IPSec use GRE encapsulation with OpenVSwitch

On IP 161.97.158.40

```
ovs-vsctl add-br br-ipsec 
ip addr add 192.168.1.1/24 dev br-ipsec
ip link set br-ipsec up
ovs-vsctl add-port br-ipsec tun1-2
ovs-vsctl set interface tun1-2 type=gre options:remote_ip=161.97.158.38 options:psk=swordF1sh
ovs-vsctl add-port br-ipsec tun1-3
ovs-vsctl set interface tun1-3 type=gre options:remote_ip=161.97.158.37 options:psk=swordF1sh
ovs-vsctl set int br-ipsec mtu_request=1420
```

On IP 161.97.158.38

```
ovs-vsctl add-br br-ipsec 
ip addr add 192.168.1.2/24 dev br-ipsec
ip link set br-ipsec up
ovs-vsctl add-port br-ipsec tun2-1
ovs-vsctl set interface tun2-1 type=gre options:remote_ip=161.97.158.40 options:psk=swordF1sh
ovs-vsctl set int br-ipsec mtu_request=1420
```

On IP 161.97.158.37

```
ovs-vsctl add-br br-ipsec 
ip addr add 192.168.1.3/24 dev br-ipsec
ip link set br-ipsec up
ovs-vsctl add-port br-ipsec tun3-1
ovs-vsctl set interface tun3-1 type=gre options:remote_ip=161.97.158.40 options:psk=swordF1sh
ovs-vsctl set int br-ipsec mtu_request=1420
```

Adjust MTU => http://muzso.hu/2009/05/17/how-to-determine-the-proper-mtu-size-with-icmp-pings. See on `Linux` section below on that page