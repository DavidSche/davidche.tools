# Often used Docker swarm health checks
 


WGET
```yaml
healthcheck:
	test: wget --no-verbose --tries=1 --spider http://localhost || exit 1
	interval: 60s
	retries: 5
	start_period: 20s
	timeout: 10s
```

CURL
```yaml
healthcheck:
	test: curl --fail http://localhost || exit 1
	interval: 60s
	retries: 5
	start_period: 20s
	timeout: 10s
```

What should we do if we don’t have access to CURL/WGET?
If we’re using an image that doesn’t include curl or wget, we’ll need to install them. Add an install command to our Dockerfile to accomplish this.

curl

```shell
RUN apk --update --no-cache add curl
```

wget

```shell
RUN apt-get update && apt-get install -y wget
```

deb http://mirrors.aliyun.com/raspbian/raspbian/ bullseye  main non-free contrib rpi
deb-src http://mirrors.aliyun.com/raspbian/raspbian/ bullseye main non-free contrib rpi


sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9165938D90FDDD2E



