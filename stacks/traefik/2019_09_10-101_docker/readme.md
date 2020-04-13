#Traefik 2.0 & Docker 101

[link](https://containo.us/blog/traefik-2-0-docker-101-fc2893944b9d/)

>Tips & Tricks the Documentation Doesn’t Tell You

Docker friends — Welcome!

Today we decided to dedicate some time to walk you through the 2.0 changes using practical & common scenarios. Hopefully, after having read this article, you’ll understand every concept there is to know, and you’ll keep learning by yourself, discovering tips & tricks to share with the community.

Before we go further, I’ll assume for this article that you already have a docker setup using Traefik 2.0. Since I like to use docker-compose files for basic demonstrations, I’ll use the following base compose file:

``` yml
version: "3.3"

services:
  traefik:
    image: "traefik:v2.0.0"
    command:
      - --entrypoints.web.address=:80
      - --providers.docker=true
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
  
  my-app:
    image: containous/whoami:v1.3.0
```

Full compose file available there.
Nothing fancy, we declare an entrypoint (web for port 80), enable the docker provider, attach our traefik container to the needed ports and make sure we can listen to Docker thought the socket. We also have an application my-app we’ll expose later.

Side Note: You can get the examples from our repository if you want to play with them. (Yes, we know how dangerous it can be to copy/paste some YAML :-))

Now that we’re all set, let’s start!

Let’s Enable the Dashboard!
Because we all enjoy seeing what we’re doing, we’ll first enable Traefik’s Dashboard in development mode, and all we need to do is add one argument to the Traefik command itself.

``` yml
services:
  traefik:
    image: "traefik:v2.0.0"
    command:
      - --entrypoints.web.address=:80
      - --providers.docker
      - --api.insecure # Don't do that in production
#   ...
```

Full compose file available there.
There we are! By adding --api.insecure we’ve enabled the API along with the dashboard. But beware, in this first step, we’ve enabled the insecure development mode — Don’t do that in production!

Of course, we’ll see at the end of the article how to enable a secured dashboard, but for now, you can enjoy and see it on localhost:8080/dashboard/


My Application Handles Requests on "example.com"
If you only need to route requests to my-app based on the host, then attach one label to your container — That’s it!

``` yml
services:
  my-app:
    image: containous/whoami:v1.3.0
    labels:
      - traefik.http.routers.my-app.rule=Host(`example.com`)
```

Full compose file available there.
Quick Explanation
In English, this label means, “Hey Traefik! (traefik.) This HTTP router (http.routers.) I call my-app (my-app.) must catch requests to example.com (rule=Host(`example.com`)).”

More Details (Optional Read)
Traefik 2.0 introduces the notion of Routers. Routers define the routes that connect your services to the requests, and you use rules to define what makes the connection. This is the reason why you see routers in the label, as well as rule.

Traefik 2.0 also introduces TCP support (in addition to the existing HTTP support). Since Traefik supports both protocols, it wants to know what kind of protocol you’re interested in, which explains the http keyword in the label.

My Application Listens on a Specific Port
What happens if your application listens on a different port than the default :80? Let’s say it listens on :8082. We’ll build on the previous example and add (again) one label.

``` yml
services:
  my-service:
    image: containous/whoami:v1.3.0
    command:
      - --port=8082 # Our service listens on 8082
    labels:
      - traefik.http.routers.my-app.rule=Host(`example.com`)
      - traefik.http.services.my-app.loadbalancer.server.port=8082
```

Full compose file available there.
Quick Explanation
In English, this label means, “Hey Traefik! (traefik.) This HTTP service (http.services.) I call my-app (my-app.) will load balance incoming requests between servers (.server) that listen on port 8082 (.port=8082).”

More Details (Optional Read)
Traefik 2.0 introduces the notion of Services. Services are the targets for the routes. They usually define how to reach your programs in your cluster. Services can have different types. The most common one is the LoadBalancer type. The LoadBalancer type is a round robin between all the available instances (called server). By default, Traefik considers that your program is available on the port exposed by the Dockerfile of your program, but you can change that by explicitly defining the port.

Since we specify only one service in the example, there is no need to define the target of the previously defined router explicitly.

Side Note: The—-port=8082 command is specific to our whoami application and has nothing to do with Traefik. It tells whoami to start listening on 8082, so we can simulate our use case.

I Need BasicAuth (Or Any Piece of Middleware)
Once Traefik has found a match for the request, it can process it before forwarding it to the service. In the following example, we’ll add a BasicAuth mechanism for our route. This is done with two additional labels.

``` yml
services:
  my-svc:
    image: containous/whoami:v1.3.0
    labels:
      - traefik.http.routers.my-app.rule=Host(`example.com`)
      - traefik.http.routers.my-app.middlewares=auth
      - traefik.http.middlewares.auth.basicauth.users=test:xxx
```
Full compose file available there.

Quick Explanation
In English, the first label means, “Hey Traefik! (traefik.) My HTTP router I called my-app, remember? (http.routers.my-app.) I’d like to attach to it a piece of middleware named auth (.middlewares=auth).”

Of course, since we haven’t yet declared the auth middleware, we need to be a bit more explicit, so the second label means, “Hey Traefik! (traefik.) Let’s talk about an HTTP middleware (http.middlewares.) I call auth (auth.). It’s a BasicAuth middleware (basicauth.). Since you probably need users to know who can do what, here is the users list (.users=test:xxx).”

More Details (Optional Read)
Traefik 2.0 introduces the notion of Middleware. Middleware is a way to define behaviors and tweak the incoming request before forwarding it to the service. Since they act before the request is forwarded, they are attached to Routers. You can define middleware and reuse them as many times as you like (this is why you need to name them, in the example auth). There are many kinds of middleware, and BasicAuth is one of them. Each middleware has a different set of parameters to define their behaviors (in the example, we define the users list).

I Need HTTPS
With Traefik, enabling automatic certificate generation is a matter of 4 lines of configuration, and enabling HTTPS on your routes is a matter of 2 lines of configuration.

1 — Enabling Automatic Certificate Generation

We’ll introduce a little tip here — Since Traefik is launched as a container, we’ll attach labels to it for common configuration options. (What is specific to other containers will, of course, stay on other containers, we’re not messy people!)

``` yml
services:
  traefik:
    image: "traefik:v2.0.0"
    command:
      - --entrypoints.websecure.address=:443
      # ...
      - --certificatesresolvers.le.acme.email=my@email.com
      - --certificatesresolvers.le.acme.storage=/acme.json
      - --certificatesresolvers.le.acme.tlschallenge=true
      # ...
    ports:
      # ...
      - "443:443"
```

Full compose file available there.
Quick Explanation
We’ve seen already the first command line given to Traefik. In English, it means, “I have an entrypoint (entrypoints.) I call websecure (websecure.) that uses port 443 (.address=:443).” And since Traefik now listens to 443, we need to tell Docker that it should bind external port 443 to our service’s port 443 ("443:443").

Now, the others are a bit trickier, but nothing crazy if you’ve had time to drink your coffee/tea. The first says, “I’d like a mechanism to generate certificates for me (certificatesresolvers.) that I’ll call le (le.). It’s an acme resolver (acme.), my account there is my@email.com (email=my@email.com).” (Disclaimer: not my real email address, don’t try it.)

The second says, “This mechanism named le I told you about, the acme stuff (certificatesresolvers.le.acme.), it will save the certificates in the file /acme.json(storage=/acme.json).”

And the third is our inner geek speaking, “Since this le mechanism I defined before (certificatesresolvers.le.acme.) supports different challenges for certificate generation, I’ll choose … the TLS challenge (tlschallenge=true).”

That was a bit more text than usual, but here we are: we have a fully functional mechanism to generate/renew certificates for us!

More Details (Optional Read)
Traefik 2.0 introduces the notion of CertificatesResolvers. Certificates resolvers are a system that handles certificate generation/renewal/disposal for you. They detect the hosts you’ve defined for your routers and get the matching certificates.

Currently, certificates resolvers leverage Let’s Encrypt to get certificates, and expect you to configure your account (which is basically your email address). In order to prove Let’s Encrypt that you’re the owner of the domains you’ll request certificates for, LE will give Traefik a challenge. There are multiple possible challenges, and we chose in the example the TLSChallenge. In the documentation, you’ll find a description for each other challenges (dnsChallenge and httpChallenge).

Know that advanced users can define multiple CertificatesResolvers using different challenges, and that they can use them to generate wildcards … but that’s a story we’ll talk about later :-)

2 — Enabling Automatic Certificate Generation

Now that we have a mechanism to generate certificates for us, let’s leverage it to enable HTTPS on our route. We’ll only need two labels!

``` yml
my-app:
    image: containous/whoami:v1.3.0
    labels:
      - traefik.http.routers.my-app.rule=Host(`example.com`)
      - traefik.http.routers.my-app.middlewares=auth
      - traefik.http.routers.my-app.tls.certresolver=le
      - traefik.http.routers.my-app.entrypoints=websecure
```

Full compose file available there.
Quick Explanation
In English, the first label means, “Hey Traefik! (traefik.) My HTTP router (http.routers.) I call my-app (my-app.) uses TLS and the CertificateResolver named le (certresolver=le).”

And the second says, “Traefik! (traefik.) this router, you know? (http.routers.my-app) It will only listen to the entrypoint I call websecure (entrypoints=websecure).”

More Details (Optional Read)
Traefik 2.0 allows you to define TLS termination directly on your routers!

Also, by default, routers listen to every known entrypoints. In our example, we wanted Traefik to limit the use of https on port 443, which is the reason why we told the router to listen only to websecure (defined to port 443 with entrypoints.websecure.address=:443)

I Want HTTPS Redirection!
Now that we have HTTPS routes, let’s redirect every non-https requests to their https equivalent. For that, we’ll reuse the previous trick and add just 4 labels to declare a redirect middleware and a catch-all router for unsecured routes.

``` yml
services:
  traefik:
    image: "traefik:v2.0.0"
    # ...
    labels:
      # ...
      
      # middleware redirect
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
      
      # global redirect to https
      - "traefik.http.routers.redirs.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.redirs.entrypoints=web"
      - "traefik.http.routers.redirs.middlewares=redirect-to-https"
```

Full compose file available there.

## Quick Explanation

In English, the first label means, “Hey Traefik! (traefik.) let’s declare an HTTP middleware (http.middlewares.) we’ll call redirect-to-https (redirect-to-https.). It’s a RedirectScheme middleware (redirectscheme.) that will force the scheme to https (scheme=https).”

Then, let’s see the router part, “Hey Traefik! (you know the drill) (traefik.) I have an HTTP router (http.routers.) I’ll call redirs (redirs.) that will match requests on any host (rule=hostregexp(`{host:.+}`)) Yes sir! I’m insane and will catch everything, that’s how greedy I am.”

Then, we add, “Hey Traefik! (traefik.) I was kidding … the redirs HTTP router (http.routers.redirs.) won’t catch everything but just requests on port 80 (entrypoints=web).”

Finally, we’ll add the redirect middleware to the router. “Traefik? (traefik.) On the redirs HTTP router (http.routers.redirs.) we’ll add the redirect-to-https middleware (middlewares=redirect-to-https).”

More Details (Optional Read)
By now, we’ve seen everything there is to know, so no additional details to learn about :-)

Compiling Everything for a Secured Dashboard!
Now that we’ve manipulated every important notion (Entrypoints, Routers, Middleware, Services, CertificatesResolvers & TLS), we can combine them to obtain a secured Dashboard!

``` yml
version: "3.3"

services:
  traefik:
    image: "traefik:v2.0.0"
    command:
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --providers.docker
      - --api
      - --certificatesresolvers.le.acme.email=your@email.com
      - --certificatesresolvers.le.acme.storage=/acme.json
      - --certificatesresolvers.le.acme.tlschallenge=true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./acme.json:/acme.json"
    labels:
      # Dashboard
      - "traefik.http.routers.traefik.rule=Host(`api.example.com`)"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.middlewares=admin"
      - "traefik.http.routers.traefik.tls.certresolver=le"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.middlewares.admin.basicauth.users=admin:xxx"

      # ...
```

[Full compose file available there.](https://github.com/containous/blog-posts/blob/master/2019_09_10-101_docker/docker-compose-09.yml)

## Quick Explanation

First, we remove the insecure api (specifying --api instead of --api.insecure).

Then, we tell Traefik (traefik.) to add an HTTP router called traefik (http.routers.traefik.) catching requests on api.example.com (rule=Host(`api.example.com`)).

This router (traefik.http.routers.traefik.) will forward requests to a service called api@internal (service=api@internal), uses a middleware named admin (middlewares=admin), and uses tls (tls=true) with a certresolver called le (tls.certresolver=le).

Finally, we declare the admin middleware (traefik.http.middlewares.admin.basicauth.users=admin:xxx).

## More Details (Optional Read)

![pic](https://containo.us/content/images/2019/11/image-12.png)

The only subtle thing to know is that when you enable the api (in default mode, it creates an internal service called api@internal (It’s then up to you to properly secure it).

## Questions? Where to Go Next?

Hopefully, we’ve gone through important questions you’ll have when dealing with Traefik 2.0 in a Docker setup, and we hope this article brings many answers.

If you want to keep the conversation going, let us know on the community forum!

In the meantime — Happy Traefik!



