#How to reduce the size of the Docker container log file

Post author By milosz
Post date September 16, 2020

Update the docker-compose configuration file to reduce the container log file size before you run out of disk space.


## Ad hoc solution

Display log file size for every created container.

```shell
$ docker ps -aq | xargs -I'{}' docker inspect --format='{{.LogPath}}' '{}' | xargs ls -lh
-rw-r----- 1 root root  34K 2017-06-08  /var/lib/docker/containers/3uy7mfiybwnaakfgstokw6h5kmsrzbhmeay9lssnm39v8y5ngf6yz7amd3i8kjhj/3uy7mfiybwnaakfgstokw6h5kmsrzbhmeay9lssnm39v8y5ngf6yz7amd3i8kjhj-json.log
-rw-r----- 1 root root 276K 2018-04-16  /var/lib/docker/containers/q51e1h6e3y4uproc0u4qq8bvighswuzhqi1jzw49ucqarsbcftfdcpa26ls02bxo/q51e1h6e3y4uproc0u4qq8bvighswuzhqi1jzw49ucqarsbcftfdcpa26ls02bxo-json.log
-rw-r----- 1 root root 4,2M 2019-03-21  /var/lib/docker/containers/l3m2ioyd1fapcy1a8wro1b4cx877b3f0ikujem8x8xlxon0t4sjs1xkdqh2eona8/l3m2ioyd1fapcy1a8wro1b4cx877b3f0ikujem8x8xlxon0t4sjs1xkdqh2eona8-json.log
-rw-r----- 1 root root 7,2M 2019-03-21  /var/lib/docker/containers/lbq2x85gdwdj2gkmv9qfnk0axdewr790huhdq0ojksiuxxhfsp8y8q4bpj4ri5t4/lbq2x85gdwdj2gkmv9qfnk0axdewr790huhdq0ojksiuxxhfsp8y8q4bpj4ri5t4-json.log
-rw-r----- 1 root root 1,3M 01-10 12:19 /var/lib/docker/containers/mkvqklyhft8nr6gwfzkccayl9nlpnfspxmc0gqd9d1c4mgilj5muzoxluwkf9eav/mkvqklyhft8nr6gwfzkccayl9nlpnfspxmc0gqd9d1c4mgilj5muzoxluwkf9eav-json.log
-rw-r----- 1 root root 131G 01-11 18:19 /var/lib/docker/containers/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg-json.log

```

Backup the current log file.

```shell
$ sudo cat /var/lib/docker/containers/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg-json.log | bzip2 --best --compress --stdout > /mnt/nfs-shared/temp/c12a851-12.01.2019.log.bz2

```

Install miscellaneous system utilities.

```shell
$ sudo apt-get install util-linux
```

Use fallocate to remove the first 130GiB from the log file.

```shell
$ sudo fallocate --collapse-range --offset 0 --length 130GiB --verbose /var/lib/docker/containers/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg-json.log

```
Display the size of the truncated log file.

```shell
$ sudo ls -lh /var/lib/docker/containers/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg-json.log
-rw-r----- 1 root root 0,7G 01-12 07:07 /var/lib/docker/containers/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg/nol87bct8i1pd0ya6pg1m3iva0cpgdde6khm0vym0g0jlob1jd3gcgbwm1scfpyg-json.log

```

## Permanent solution

Define logging parameters for each container inside the docker-compose configuration file to prevent log files from consuming excessive disk space.

$ cat docker-compose.yml

```yml
version: "2"
networks:
  gitea:
    external: false
services:
  server:
    image: gitea/gitea:latest
    environment:
      - USER_UID=1000
      - USER_GID=1000
    restart: always
    networks:
      - gitea
    volumes:
      - ./gitea:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - "8080:3000"
      - "2221:22"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "10"

```

This configuration ensures that logs will rotate automatically.

```shell
$ sudo ls /var/lib/docker/containers/6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e/
6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e-json.log    6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e-json.log.6  hostconfig.json
6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e-json.log.1  6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e-json.log.7  hostname
6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e-json.log.2  6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e-json.log.8  hosts
6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e-json.log.3  6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e-json.log.9  mounts
6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e-json.log.4  checkpoints                                                                  resolv.conf
6e8c754ca7ec5b834b6c3c8a325a77315b729cfc7c4821409c09835834cffc2e-json.log.5  config.v2.json                                                               resolv.conf.hash

```

