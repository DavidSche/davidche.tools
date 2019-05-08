## Create NFS Volumes:

Creating the NFS Volume:

```bash
$ docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.115,uid=1000,gid=1000,rw \
  --opt device=:/mnt/volumes/mysql-test \
  mysql-test-1
```

Creating The Service:

```bash
$ docker service create --name mysql \
  --network docknet \
  --mount "type=volume,source=mysql-test-1,destination=/var/lib/mysql,readonly=false" \
  --env MYSQL_ROOT_PASSWORD=pass \
  --replicas 1  hypriot/rpi-mysql
```

Another Method Container Only:

```
$ mkdir /opt/nfs/volumes/boo
$ docker volume create --opt type=nfs --opt device=:/opt/nfs/volumes/boo --opt o=addr=192.168.1.115  vol_boo
$ docker run -it -v vol_boo:/data rbekker87/armhf-alpine:3.5 sh
$ docker volume inspect vol_boo
[
    {
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/vol_boo/_data",
        "Name": "vol_boo",
        "Options": {
            "device": ":/opt/nfs/volumes/boo",
            "o": "addr=192.168.1.115",
            "type": "nfs"
        },
        "Scope": "local"
    }
]
$ docker run -it -v vol_boo:/data rbekker87/armhf-alpine:3.5 sh
#/ touch /data/test.txt
$ ls /opt/nfs/volumes/boo/
test.txt
```

Another Method with Compose/Stacks:

```
mkdir /opt/nfs/volumes/debug
```

```
version: "3.2"

services:
  a:
    image: rbekker87/armhf-alpine:3.5
    command: ping 127.0.0.1
    networks:
      - docknet
    volumes:
      - type: volume
        source: vol_debug
        target: /data
        volume:
          nocopy: true
    deploy:
      replicas: 1
      placement:
        constraints: [node.role == manager]

networks:
  docknet:
    external: true

volumes:
  vol_debug:
    driver: local
    driver_opts:
      type: "nfs"
      o: addr=192.168.1.115,nolock,soft,rw
      device: ":/opt/nfs/volumes/debug"

```