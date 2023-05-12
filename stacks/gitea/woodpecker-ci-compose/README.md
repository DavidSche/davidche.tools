# Docker Compose Woodpecker CI with Gitea integration

The goal is to set up [Woodpecker CI](https://woodpecker-ci.org/) and integrate with a [Gitea](https://gitea.io) instance running at a server in our local home network. Additionally we will also use [Traefik](https://traefik.io/traefik/) as a reverse proxy. Note that even these instructions assume everything will run on your local home network, the setup can easily adapt to run on a cheap public VPS. Everything you need to do is to use proper TLS certificates from Let’s Encrypt instead self-signed ones.

Instead of having everything in one big Docker Compose file, I prefer to keep things separated. Therefore, it is assumed Traefik and Gitea are already installed and running on your server. If this is not already the case, please follow my instructions to set up [Traefik](https://codeberg.org/alexruf/docker-compose-traefik) and [Gitea](https://codeberg.org/alexruf/docker-compose-gitea) first before continuing here.

So let's get started.

## Set up Woodpecker CI via Docker Compose

First, clone the Git repository onto your server:

```shell
git clone https://codeberg.org/alexruf/docker-compose-woodpecker-ci.git
```

Next, prepare the data directory where Woodpecker server will store its data and create the `.env` file where all environment variables are stored to configure the container and store sensitive data.

```shell
cd docker-compose-woodpecker-ci
cp example.env .env & mkdir data
```

Now use the `.env` file to set all required configuration parameters. Most of the environment variables should be self-explanatory. However, there are a few that need our special attention.

`WOODPECKER_AGENT_SECRET` is the shared secret used by server and agents to authenticate communication. This can be any random string value. You can generated a random string by executing the `openssl rand -hex 32` command.

`WOODPECKER_ADMIN` is a comma separated list of user accounts with administrator permissions (e.g. `user1,user2`).

`WOODPECKER_GITEA_CLIENT` & `WOODPECKER_GITEA_SECRET` is the OAuth client & secret used by Woodpecker to authorize access for Gitea. To generate the client & secret, log into Gitea. There are two ways to generate the OAuth client. If you have administrator permissions of the Gitea server, open the Gitea menu and go to **Site Administration > Applications**. As a regular user without administrator permissions, open the Gitea menu and go to **Settings > Applications**. Create a new application with the application name `Woodpecker CI`. Use redirect URI `https://${WOODPECKER_HOST}/authorize` (make sure to replace the variables with the actual value, e.g. `https://ci.example.org/authorize`).
Once the application is created, it will show you the `Client ID` & `Client Secret` - save this into the `.env` file.

Once that is in place, the Woodpecker server and agent containers can be started:

```shell
docker compose up -d
```

Opening the Woodpecker server URL should show the login screen and redirect to Gitea where you will be asked to authorize access for the Woodpecker CI application. After authorizing access, Woodpecker should be ready and usable. Head to the official [Woodpecker CI documentation](https://woodpecker-ci.org/docs/usage/intro) to get started setting up your first pipeline.
