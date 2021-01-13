# How to install Docker on Debian Stretch

Post author By milosz

Post date March 30, 2018

## Install docker on Debian Stretch to take advantage of the lightweight virtualization.


Debian version.

```shell
$ lsb_release -a
No LSB modules are available.
Distributor ID:	Debian
Description:	Debian GNU/Linux 9.3 (stretch)
Release:	9.3
Codename:	stretch

```


Kernel version.

```shell
$ uname -a
Linux debian 4.9.0-3-amd64 #1 SMP Debian 4.9.30-2+deb9u5 (2017-09-19) x86_64 GNU/Linux
```

Install apt-transport-https package to enable HTTPS protocol for apt.

```shell
$ sudo apt-get install apt-transport-https
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following NEW packages will be installed:
apt-transport-https
0 upgraded, 1 newly installed, 0 to remove and 1 not upgraded.
Need to get 171 kB of archives.
After this operation, 243 kB of additional disk space will be used.
Get:1 http://ftp.task.gda.pl/debian stretch/main amd64 apt-transport-https amd64 1.4.8 [171 kB]
Fetched 171 kB in 0s (531 kB/s)         
Selecting previously unselected package apt-transport-https.
(Reading database ... 26565 files and directories currently installed.)
Preparing to unpack .../apt-transport-https_1.4.8_amd64.deb ...
Unpacking apt-transport-https (1.4.8) ...
Setting up apt-transport-https (1.4.8) ...
```

Configure Docker repository.

```shell
$ echo "deb https://download.docker.com/linux/debian stretch stable" | sudo tee /etc/apt/sources.list.d/docker.list
deb https://download.docker.com/linux/debian stretch stable
```

Download and import public key used to sign this repository.

```shell
$ wget --quiet --output-document - https://download.docker.com/linux/debian/gpg  | sudo apt-key add -
OK
```

Update package index.

```shell
$ sudo apt-get update
Hit:1 http://security.debian.org/debian-security stretch/updates InRelease
Ign:2 http://ftp.task.gda.pl/debian stretch InRelease                         
Hit:3 http://ftp.task.gda.pl/debian stretch-updates InRelease                 
Hit:4 http://ftp.task.gda.pl/debian stretch Release
Get:5 https://download.docker.com/linux/debian stretch InRelease [39.1 kB]
Get:7 https://download.docker.com/linux/debian stretch/stable amd64 Packages [3,109 B]
Fetched 42.2 kB in 1s (39.2 kB/s)
Reading package lists... Done
```

Install Docker CE.

```shell
$ sudo apt-get install docker-ce
```

```shell
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
aufs-dkms aufs-tools binutils cgroupfs-mount cpp cpp-6 dkms fakeroot gcc gcc-6 git git-man libasan3 libatomic1
libc-dev-bin libc6-dev libcc1-0 libcilkrts5 liberror-perl libfakeroot libgcc-6-dev libgomp1 libisl15 libitm1
liblsan0 libltdl7 libmpc3 libmpfr4 libmpx2 libquadmath0 libtsan0 libubsan0 linux-compiler-gcc-6-x86
linux-headers-4.9.0-5-amd64 linux-headers-4.9.0-5-common linux-headers-amd64 linux-kbuild-4.9 linux-libc-dev
make manpages-dev patch rsync
Suggested packages:
aufs-dev binutils-doc cpp-doc gcc-6-locales python3-apport menu gcc-multilib autoconf automake libtool flex
bison gdb gcc-doc gcc-6-multilib gcc-6-doc libgcc1-dbg libgomp1-dbg libitm1-dbg libatomic1-dbg libasan3-dbg
liblsan0-dbg libtsan0-dbg libubsan0-dbg libcilkrts5-dbg libmpx2-dbg libquadmath0-dbg git-daemon-run
| git-daemon-sysvinit git-doc git-el git-email git-gui gitk gitweb git-arch git-cvs git-mediawiki git-svn
glibc-doc make-doc ed diffutils-doc
The following NEW packages will be installed:
aufs-dkms aufs-tools binutils cgroupfs-mount cpp cpp-6 dkms docker-ce fakeroot gcc gcc-6 git git-man libasan3
libatomic1 libc-dev-bin libc6-dev libcc1-0 libcilkrts5 liberror-perl libfakeroot libgcc-6-dev libgomp1 libisl15
libitm1 liblsan0 libltdl7 libmpc3 libmpfr4 libmpx2 libquadmath0 libtsan0 libubsan0 linux-compiler-gcc-6-x86
linux-headers-4.9.0-5-amd64 linux-headers-4.9.0-5-common linux-headers-amd64 linux-kbuild-4.9 linux-libc-dev
make manpages-dev patch rsync
0 upgraded, 43 newly installed, 0 to remove and 1 not upgraded.
Need to get 74.2 MB of archives.
After this operation, 353 MB of additional disk space will be used.
Do you want to continue? [Y/n]
[...]
```

Add current user to the docker group.

```shell
$ sudo usermod -aG docker $(whoami)
```

Re-login and run hello-world image to verify that application container engine is correctly installed.

```shell
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
ca4f61b1923c: Pull complete
Digest: sha256:66ef312bbac49c39a89aa9bcc3cb4f3c9e7de3788c944158df3ee0176d32b751
Status: Downloaded newer image for hello-world:latest
```


Hello from Docker!

This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:

    1. The Docker client contacted the Docker daemon.
    2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
       (amd64)
    3. The Docker daemon created a new container from that image which runs the
       executable that produces the output you are currently reading.
    4. The Docker daemon streamed that output to the Docker client, which sent it
       to your terminal.

To try something more ambitious, you can run an Ubuntu container with:

```shell
$ docker run -it ubuntu bash
```

Share images, automate workflows, and more with a free Docker ID:
[https://cloud.docker.com/](https://cloud.docker.com/)

For more examples and ideas, [visit:https://docs.docker.com/engine/userguide/](https://docs.docker.com/engine/userguide/)

It works.

[来源](https://blog.sleeplessbeastie.eu/2018/03/30/how-to-install-docker-on-debian-stretch/)