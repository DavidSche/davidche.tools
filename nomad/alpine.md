#  alpine  Dockerfile 

更新Alpine的软件源，切换为阿里云

```shell
#.更新Alpine的软件源，切换为阿里云 
RUN echo http://mirrors.aliyun.com/alpine/v3.10/main/ > /etc/apk/repositories && \
    echo http://mirrors.aliyun.com/alpine/v3.10/community/ >> /etc/apk/repositories
RUN apk update && apk upgrade


```


https://www.hashicorp.com/blog/hashitalks-2021-highlights-nomad-and-consul

Code to create and deploy to Nomad clusters. Deployment leverages a simple .gitlab-ci.yml using GitLab runners & CI/CD; then switches to custom [deploy] to deploy docker containers into nomad. Also contains demo "hi world" webapp.

[Noma 资料](https://gitlab.com/internetarchive/nomad)
 
[traefik-proxy-fully-integrates-with-hashicorp-nomad](https://traefik.io/blog/traefik-proxy-fully-integrates-with-hashicorp-nomad)

[nomad ppt](https://discuss.hashicorp.com/t/hashitalks-2022-speaker-slides/35153)

[Nomad+traefik](https://github.com/mikenomitch/nomad-traefik)
[Traefik in Nomad using Consul and TLS](https://storiesfromtheherd.com/traefik-in-nomad-using-consul-and-tls-5be0007794ee)

[Example for HashiCorp Vault and Consul Integration with Spring Cloud](https://github.com/krisiye/springcloud_vault_consul)
[spring-cloud-vault](https://www.baeldung.com/spring-cloud-vault)
[spring-cloud-vault-demo](https://www.techgeeknext.com/spring-boot/spring-cloud-vault)

[Secure your traefik dashboard with HTTPS and Basic Auth](https://dev.to/tahsinature/secure-your-traefik-dashboard-with-https-and-basic-auth-nkh)
