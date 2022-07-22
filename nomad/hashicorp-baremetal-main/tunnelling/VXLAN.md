# VXLAN

VXLAN with OpenVSwitch between 3 public hosts

On IP 161.97.158.40

```
ovs-vsctl add-br br-ipsec 
ip addr add 192.168.1.1/24 dev br-ipsec
ip link set br-ipsec up
ovs-vsctl add-port br-ipsec tun1-2
ovs-vsctl set interface tun1-2 type=vxlan options:remote_ip=161.97.158.38 options:key=1337
ovs-vsctl add-port br-ipsec tun1-3
ovs-vsctl set interface tun1-3 type=vxlan options:remote_ip=161.97.158.37 options:key=1337
ovs-vsctl set int br-ipsec mtu_request=1450
```

On IP 161.97.158.38

```
ovs-vsctl add-br br-ipsec 
ip addr add 192.168.1.2/24 dev br-ipsec
ip link set br-ipsec up
ovs-vsctl add-port br-ipsec tun2-1
ovs-vsctl set interface tun2-1 type=vxlan options:remote_ip=161.97.158.40 options:key=1337
ovs-vsctl set int br-ipsec mtu_request=1450
```

On IP 161.97.158.37

```
ovs-vsctl add-br br-ipsec 
ip addr add 192.168.1.3/24 dev br-ipsec
ip link set br-ipsec up
ovs-vsctl add-port br-ipsec tun3-1
ovs-vsctl set interface tun3-1 type=vxlan options:remote_ip=161.97.158.40 options:key=1337
ovs-vsctl set int br-ipsec mtu_request=1450
```

Btw for setting up MTU: http://muzso.hu/2009/05/17/how-to-determine-the-proper-mtu-size-with-icmp-pings