# k3s install on alpine 

```
$ apk add --no-cache curl
$ echo "cgroup /sys/fs/cgroup cgroup defaults 0 0" >> /etc/fstab

$ cat > /etc/cgconfig.conf <<EOF
mount {
  cpuacct = /cgroup/cpuacct;
  memory = /cgroup/memory;
  devices = /cgroup/devices;
  freezer = /cgroup/freezer;
  net_cls = /cgroup/net_cls;
  blkio = /cgroup/blkio;
  cpuset = /cgroup/cpuset;
  cpu = /cgroup/cpu;
}
EOF

$ sed -i 's/default_kernel_opts="pax_nouderef quiet rootfstype=ext4"/default_kernel_opts="pax_nouderef quiet rootfstype=ext4 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"/g' /etc/update-extlinux.conf

$ update-extlinux
$ reboot
$ apk add --no-cache cni-plugins --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
$ export PATH=$PATH:/usr/share/cni-plugins/bin
$ echo -e '#!/bin/sh\nexport PATH=$PATH:/usr/share/cni-plugins/bin' > /etc/profile.d/cni.sh
$ apk add iptables
$ wget https://github.com/rancher/k3s/releases/download/v1.17.4%2Bk3s1/k3s
$ mv k3s /usr/bin/
$ chmod +x /usr/bin/k3s

or

$ curl -sfL https://get.k3s.io | sh -
$ kubectl get nodes
NAME     STATUS   ROLES    AGE     VERSION
server   Ready    master   3m40s   v1.17.4+k3s1

# token: /var/lib/rancher/k3s/server/node-token
```