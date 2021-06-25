# Traefik + Docker Swarm

I am looking for more information about the behavior with "Traefik + Docker Swarm".

## Goal

I would like my myrepo/alpha-app to deploy with Zero Downtime (I am using Gitlab to do this for me)
What "zero-downtime means":

 1. A single version of the application container is running
 2. A new update is published to the repo
 3. Gitlab assembles the Docker image
 4. Gitlab tells Docker Swarm to deploy a new version of the application
 5. Docker Swarm brings up the new container and connects it to the existing Docker Service
 6. Traefik should automatically choose the newest container to send requests to
 7. Docker Swarm then kills the old container

All of this above obviously can happen within milliseconds, but I want to make sure I am doing this right. The last 3 steps are the critical part.

## Questions
1. Is this something is configured in Traefik or in Docker Swarm?
   I know Docker Swarm has this deploy configuration for my "docker-compose.yml" file:

```docker-compose.yml
  app:
    image: myrepo/alpha-app
    networks:
      - web-public
    deploy:
      replicas: 1
      update_config:
        parallelism: 1
        delay: 5s
        order: start-first
```


2. Or is this something that I need to use "priority labels" for?
   I saw on the Traefik docs for the "priority" label. I could probably set the labels to "epoch time", but not sure if I even need this.

There is also this example that does a "blue/green" but I don't know if I need that or not: bluegreen-traefik-docker/docker-stack-appli-blue.yml at master · rodolpheche/bluegreen-traefik-docker · GitHub 2

Configurations

docker-compose.yml
```docker-compose.yml
version: '3.7'
services:
  traefik:
    # Use the latest Traefik image
    image: traefik:v2.4
    networks:
        - web-public
    ports:
      # Listen on port 80, default for HTTP, necessary to redirect to HTTPS
      - target: 80
        published: 80
        mode: host
      # Listen on port 443, default for HTTPS
      - target: 443
        published: 443
        mode: host
    deploy:
      mode: global
      update_config:
        parallelism: 1
        delay: 5s
        order: start-first
      placement:
        constraints:
          # Make the traefik service run only on the node with this label
          # as the node with it has the volume for the certificates
          - node.role==manager
    volumes:
      # Add Docker as a mounted volume, so that Traefik can read the labels of other services
      - /var/run/docker.sock:/var/run/docker.sock:ro
      # Mount the volume to store the certificates
      - certificates:/certificates
    configs:
      - source: traefik
        target: /etc/traefik/traefik.yml

  app:
    image: myrepo/alpha-app
    networks:
      - web-public
    deploy:
      replicas: 1
      update_config:
        parallelism: 1
        delay: 5s
        order: start-first
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.alpha.rule=Host(`alpha.dev.test`)"
        - "traefik.http.routers.alpha.entrypoints=websecure"
        - "traefik.http.routers.alpha.tls=true"
        - "traefik.http.routers.alpha.tls.certresolver=letsencryptresolver"
        - "traefik.http.services.alpha.loadbalancer.server.port=443"
        - "traefik.http.services.alpha.loadbalancer.server.scheme=https"

volumes:
  # Create a volume to store the certificates, there is a constraint to make sure
  # Traefik is always deployed to the same Docker node with the same volume containing
  # the HTTPS certificates
  certificates:

configs:
  traefik:
    name: "traefik.yml"
    file: ./traefik.yml

networks:
  # Use the previously created public network "web-public", shared with other
  # services that need to be publicly available via this Traefik
  web-public:
    external: true

```

traefik.yml

```yaml
# Do not panic if using a self-signed cert
serversTransport:
  insecureSkipVerify: true

### Providers
providers:
  docker:
    network: web-public
    exposedbydefault: false
    swarmMode: true
## Entry points (trust from CloudFlare)
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entrypoint:
          to: websecure
          scheme: https
    proxyProtocol:
      trustedIPs:
        - "173.245.48.0/20"
        - "103.21.244.0/22"
        - "103.22.200.0/22"
        - "103.31.4.0/22"
        - "2405:b500::/32"
        - "2405:8100::/32"
        - "2a06:98c0::/29"
        - "2c0f:f248::/32"

  websecure:
    address: ":443"
    proxyProtocol:
      trustedIPs:
        - "173.245.48.0/20"
        - "103.21.244.0/22"
        - "103.22.200.0/22"
        - "103.31.4.0/22"
        - "2405:b500::/32"
        - "2405:8100::/32"
        - "2a06:98c0::/29"
        - "2c0f:f248::/32"

accessLog: {}
log:
  level: ERROR

api:
  dashboard: true
  insecure: true

certificatesResolvers:
  letsencryptresolver:
    # Enable ACME (Let's Encrypt): automatic SSL.
    acme:

      # Email address used for registration.
      #
      # Required
      #
      email: "me@example.test"

      # File or key used for certificates storage.
      #
      # Required
      #
      storage: "/certificates/acme.json"

      # Use a HTTP-01 ACME challenge.
      #
      # Optional
      #
      httpChallenge:

        # EntryPoint to use for the HTTP-01 challenges.
        #
        # Required
        #
        entryPoint: web
```
Any insight would be greatly appreciated!! 