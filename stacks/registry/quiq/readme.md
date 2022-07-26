# Docker Registry UI


## 给私有Docker Registry加个UI

Run UI

```shell

docker run -d -p 8000:8000 -v /local/config.yml:/opt/config.yml:ro \
    --name=registry-ui quiq/docker-registry-ui

```

To run with your own root CA certificate, add to the command:

```shell
-v /local/rootcacerts.crt:/etc/ssl/certs/ca-certificates.crt:ro
```

To preserve sqlite db file with event notifications data, add to the command:

```shell
-v /local/data:/opt/data
```

To run with a custom TZ:

```shell
-e TZ=Asia/Shanghai
```

Configure event listener on Docker Registry
To receive events you need to configure Registry as follow:

```yaml
notifications:
  endpoints:
    - name: docker-registry-ui
      url: http://docker-registry-ui.local:8000/api/events
      headers:
        Authorization: [Bearer abcdefghijklmnopqrstuvwxyz1234567890]
      timeout: 1s
      threshold: 5
      backoff: 10s
      ignoredmediatypes:
        - application/octet-stream
```

Adjust url and token as appropriate. If you are running UI from non-root base path, e.g. /ui, the URL path for above will be /ui/api/events.





docker-compose.yml如下：

```yaml
version: '3.7'
services:
  local-registry-ui:
    restart: always
    image: quiq/docker-registry-ui
    ports:
      - 8000:8000
    environment:
      TZ: Asia/Shanghai
    volumes:
      - /path/to/config.yml:/opt/config.yml:ro  # config for registry ui
      - /path/to/domain.crt:/etc/ssl/certs/ca-certificates.crt:ro  # crt file created for docker registry
      - /path/to/data:/opt/data  # path for sqlite db
```

有两个要注意的地方：

- 之前为私有Registry创建的crt文件可以直接拿过来用
- /path/to/data要设置对应权限， UI container里的user id是65534， 直接chown -r 65534:65534 /path/to/data
- 要记录Registry Event的话，需要在Registry Config里添加如下配置：

```yaml
notifications:
  endpoints:
    - name: docker-registry-ui
      url: http://ip.for.registry.ui:8000/api/events
      headers:
        Authorization: [Bearer abcdefghijklmnopqrstuvwxyz1234567890] # need set save token in registry ui
      timeout: 1s
      threshold: 5
      backoff: 10s
      ignoredmediatypes:
        - application/octet-stream
```

对应Registry UI的配置：

```yaml

# Listen interface.
listen_addr: 0.0.0.0:8000
# Base path of Docker Registry UI.
base_path: /

# Registry URL with schema and port.
registry_url: https://ip.for.registry:5000
# Verify TLS certificate when using https.
verify_tls: true

# Docker registry credentials.
# They need to have a full access to the registry.
# If token authentication service is enabled, it will be auto-discovered and those credentials
# will be used to obtain access tokens.
# When the registry_password_file entry is used, the password can be passed as a docker secret
# and read from file. This overides the registry_password entry.
registry_username: registryuser   # user name and password for registry auth
registry_password: registrypassword
#registry_password_file: /run/secrets/htpasswd

# Event listener token.
# The same one should be configured on Docker registry as Authorization Bearer token.
event_listener_token: abcdefghijklmnopqrstuvwxyz1234567890  # same token as config in registry
# Retention of records to keep.
event_retention_days: 7

# Event listener storage.
event_database_driver: sqlite3
event_database_location: data/registry_events.db
# event_database_driver: mysql
# event_database_location: user:password@tcp(localhost:3306)/docker_events

# You can disable event deletion on some hosts when you are running docker-registry on master-master or
# cluster setup to avoid deadlocks or replication break.
event_deletion_enabled: True

# Cache refresh interval in minutes.
# How long to cache repository list and tag counts.
cache_refresh_interval: 10

# If users can delete tags. If set to False, then only admins listed below.
anyone_can_delete: true
# Users allowed to delete tags.
# This should be sent via X-WEBAUTH-USER header from your proxy.
admins: []

# Debug mode. Affects only templates.
debug: true

# How many days to keep tags but also keep the minimal count provided no matter how old.
purge_tags_keep_days: 90
purge_tags_keep_count: 2
# Enable built-in cron to schedule purging tags in server mode.
# Empty string disables this feature.
``` 