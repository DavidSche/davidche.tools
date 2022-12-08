# portainer dev kit with dependencies in it  

based on the OpenVSCode image provided by portainer devkit: https://github.com/portainer/dev-toolkit

based on the OpenVSCode image provided by Gitpod: https://github.com/gitpod-io/openvscode-server

## build devkit docker images 

```shell
docker build -t cheshuai/portainer-devkit:2022.12 .
```

## run

```shell
docker run -it --init \
    -p 3000:3000 -p 9000:9000 -p 9443:9443 -p 8000:8000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --name portainer-devkit \
    portainer/dev-toolkit:2022.12
```

## Building Portainer inside the toolkit

Clone the portainer project directly in the container and execute the following commands to start a development build.

Install the dependencies and build the client+server first:

```shell
yarn
yarn build
```

Run the client in dev mode if you wish to do changes on the client:

```shell
yarn start:client
```

Run the backend as a process directly:

```shell
./dist/portainer --data /tmp/portainer
```






