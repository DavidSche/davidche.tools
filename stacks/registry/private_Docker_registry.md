#How to setup private Docker registry

Post author By milosz

Post date April 16, 2018

> Setup a simple Docker registry to use it privately or share images which a team of developers.


Install Docker before performing any operations described here.

## Personal local registry

Create a directory to permanently store images.

```shell
$ sudo mkdir -p /srv/registry/data
```

Start the registry container.

```shell
$ docker run -d \
-p 5000:5000 \
--name registry \
-v /srv/registry/data:/var/lib/registry \
--restart always \
registry:2
b1a641f8d710eee34405ad575050179f5a1262f1c845806cc3c2b435dea1648c
```

Display running containers.

```shell
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
b1a641f8d710        registry:2          "/entrypoint.sh /etc…"   5 minutes ago       Up 5 minutes        0.0.0.0:5000->5000/tcp   registry

```
Pull Debian Stretch image from the official repository.

```shell
$ docker pull debian:stretch
stretch: Pulling from library/debian
723254a2c089: Pull complete
Digest: sha256:0a5fcee6f52d5170f557ee2447d7a10a5bdcf715dd7f0250be0b678c556a501b
Status: Downloaded newer image for debian:stretch
```

Tag local Debian Stretch image with an additional tag – local repository address.

```shell
$ docker tag debian:stretch localhost:5000/debian:stretch
```

Push the image to the local repository.

```shell
$ docker push localhost:5000/debian:stretch
The push refers to repository [localhost:5000/debian]
e27a10675c56: Pushed
stretch: digest: sha256:02741df16aee1b81c4aaff4c48d75cc2c308bade918b22679df570c170feef7c size: 529

```

Remove local images.

```shell
$ docker image remove debian:stretch
Untagged: debian:stretch
Untagged: debian@sha256:0a5fcee6f52d5170f557ee2447d7a10a5bdcf715dd7f0250be0b678c556a501b
$ docker image remove localhost:5000/debian:stretch
Untagged: localhost:5000/debian:stretch
Untagged: localhost:5000/debian@sha256:02741df16aee1b81c4aaff4c48d75cc2c308bade918b22679df570c170feef7c
Deleted: sha256:da653cee0545dfbe3c1864ab3ce782805603356a9cc712acc7b3100d9932fa5e
Deleted: sha256:e27a10675c5656bafb7bfa9e4631e871499af0a5ddfda3cebc0ac401dfe19382
```

Pull the Debian Stretch image from the local repository.

```shell
$ docker pull localhost:5000/debian:stretch
stretch: Pulling from debian
723254a2c089: Pull complete
Digest: sha256:02741df16aee1b81c4aaff4c48d75cc2c308bade918b22679df570c170feef7c
Status: Downloaded newer image for localhost:5000/debian:stretch
```

List stored images.

```shell
$ docker image ls
REPOSITORY              TAG                 IMAGE ID            CREATED             SIZE
registry                2                   d1fd7d86a825        4 weeks ago         33.3MB
localhost:5000/debian   stretch             da653cee0545        2 months ago        100MB
hello-world             latest              f2a91732366c        2 months ago        1.85kB

```

Shared local registry

Create a directory to permanently store images.

```shell
$ sudo mkdir -p /srv/registry/data
```

Create a directory to permanently store certificates and authentication data.

```shell
$ sudo mkdir -p /srv/registry/security
```

Store domain and intermediate certificates using /srv/registry/security/registry.crt file, private key using /srv/registry/security/registry.key file.
Use valid certificates, and do not waste time with self-signed ones. This step is required to use basic authentication.

## Install apache2-utils to use htpasswd utility.

```shell
$ sudo apt-get install apache2-utils
```

Create initial username and password. The only supported password format is bcrypt.

```shell
$ : | sudo tee /srv/registry/security/htpasswd
$ echo "password" | sudo htpasswd -iB /srv/registry/security/htpasswd username
Adding password for user username
$ cat /srv/registry/security/htpasswd
username:$2y$05$KjuSifCdzRiYmir9N.nu.OKHtEbSZxbUPR04zatI25G9Bqyq1cho.
```

Start the registry container.

```shell
$ docker run -d \
-p 443:5000 \
--name registry \
-v /srv/registry/data:/var/lib/registry \
-v /srv/registry/security:/etc/security \
-e REGISTRY_HTTP_TLS_CERTIFICATE=/etc/security/registry.crt \
-e REGISTRY_HTTP_TLS_KEY=/etc/security/registry.key \
-e REGISTRY_AUTH=htpasswd \
-e REGISTRY_AUTH_HTPASSWD_PATH=/etc/security/htpasswd \
-e REGISTRY_AUTH_HTPASSWD_REALM="Registry Realm" \
--restart always \
registry:2
ac9279b49a1c040c5935fa4d5df19c186a9fb0bcc9583afcf3768dd42bc40143
```

Display running containers.

```shell
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                   NAMES
ac9279b49a1c        registry:2          "/entrypoint.sh /etc…"   17 seconds ago      Up 16 seconds       0.0.0.0:443->5000/tcp   registry

```
Pull Debian Stretch image from the official repository.

```shell
$ docker pull debian:stretch
stretch: Pulling from library/debian
723254a2c089: Pull complete
Digest: sha256:0a5fcee6f52d5170f557ee2447d7a10a5bdcf715dd7f0250be0b678c556a501b
Status: Downloaded newer image for debian:stretch

```

Tag local Debian Stretch image with an additional tag – local repository address.

```shell
$ docker tag debian:stretch registry.sleeplessbeastie.eu/debian:stretch
```

Provide login credentials to use the local repository.

```shell
$ docker push registry.sleeplessbeastie.eu/debian:stretch
e27a10675c56: Preparing
no basic auth credentials

$ docker pull registry.sleeplessbeastie.eu/debian:stretch
Error response from daemon: Get https://registry.sleeplessbeastie.eu/v2/debian/manifests/stretch: no basic auth credentials

```

Log in to the local registry.

```shell
$ docker login --username username registry.sleeplessbeastie.eu
Password: ********
Login Succeeded
```

Push the image to the local repository.

```shell
$ docker push registry.sleeplessbeastie.eu/debian:stretch
The push refers to repository [registry.sleeplessbeastie.eu/debian]
e27a10675c56: Pushed
stretch: digest: sha256:02741df16aee1b81c4aaff4c48d75cc2c308bade918b22679df570c170feef7c size: 529

```
Remove local images.

```shell
$ docker image remove debian:stretch

Untagged: debian:stretch
Untagged: debian@sha256:0a5fcee6f52d5170f557ee2447d7a10a5bdcf715dd7f0250be0b678c556a501b

$ docker image remove registry.sleeplessbeastie.eu/debian:stretch

Untagged: registry.sleeplessbeastie.eu/debian:stretch
Untagged: registry.sleeplessbeastie.eu/debian@sha256:02741df16aee1b81c4aaff4c48d75cc2c308bade918b22679df570c170feef7c
Deleted: sha256:da653cee0545dfbe3c1864ab3ce782805603356a9cc712acc7b3100d9932fa5e
Deleted: sha256:e27a10675c5656bafb7bfa9e4631e871499af0a5ddfda3cebc0ac401dfe19382
```

Pull the Debian Stretch image from the local repository.

```shell
$ docker pull registry.sleeplessbeastie.eu/debian:stretch
stretch: Pulling from debian
723254a2c089: Pull complete
Digest: sha256:02741df16aee1b81c4aaff4c48d75cc2c308bade918b22679df570c170feef7c
Status: Downloaded newer image for registry.sleeplessbeastie.eu/debian:stretch
```

List stored images.

```shell
$ docker image ls
REPOSITORY                           TAG                 IMAGE ID            CREATED             SIZE
registry                             2                   d1fd7d86a825        4 weeks ago         33.3MB
registry.sleeplessbeastie.eu/debian   stretch             da653cee0545        2 months ago        100MB
hello-world                          latest              f2a91732366c        2 months ago        1.85kB

```
Additional information

[Configuring a registry](https://docs.docker.com/registry/configuration/)
[Deploy a registry server](https://docs.docker.com/registry/deploying/)

Tags
