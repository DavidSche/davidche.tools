# Expose Traefik dashboard in secure mode with https and basic auth

ssh into docker swarm master node first

## Step 1, create traefik-public network

``` shell
$ docker network create --driver=overlay traefik-public
```

## Step 2, Create Http Basic Auth User

```shell
$ sudo apt install apache2-utils
$ export USERNAME="your_username"
$ export PASSWORD="your_password"
$ echo $(htpasswd -nb $USERNAME $PASSWORD) | sed -e s/\\$/\\$\\$/g
your_username:$$apr1$$MjQrynku$$iSdz67CS8wZvCaqm7qYBC/
```

>**Note**
when used in docker-compose.yml all dollar signs in the hash need to be doubled for escaping.
To create user:password pair, it's possible to use this command:
echo $(htpasswd -nB user) | sed -e s/\$/\$\$/g
Also note that dollar signs should NOT be doubled when they not evaluated (e.g. Ansible docker_container module).

Update the user info in traefik-secure-mode-auth-https.yml file with yours

## Step 3, deploy traefik stack with traefik-secure-mode-auth-https.yml

```
$ docker stack deploy -c traefik-secure-mode-auth-https.yml traefik
```

## Step 4, Check access

Use browser to access below link

<http://traefik.example.com/api/dashboard/>
<https://traefik.example.com/api/dashboard/>
you will get an SSL error, if you display the certificate and see it was emitted by Fake LE Intermediate X1 then it means all is good.

>**Note:** The trailing slash / in /dashboard/ is mandatory

## Step 5

Comment below line in traefik-bare-secure-mode.yml file when deploy to production

```shell
   - "--certificatesresolvers.letsencryptresolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
```

More reffer

<https://doc.traefik.io/traefik/operations/dashboard/#secure-mode>
