#  dragonflydb



## Docker compose 

```yaml
version: '3.8'
services:
  dragonfly:
    image: 'docker.dragonflydb.io/dragonflydb/dragonfly'
    ulimits:
      memlock: -1
    ports:
      - "6379:6379"
    # For better performance, consider `host` mode instead `port` to avoid docker NAT.
    # `host` mode is NOT currently supported in Swarm Mode.
    # https://docs.docker.com/compose/compose-file/compose-file-v3/#network_mode
    # network_mode: "host"
    volumes:
      - dragonflydata:/data
volumes:
  dragonflydata:
  
 ```


```yaml
version: '3.9'

services:
  pdragonflydb:
    container_name: pdragonflydb
    image: docker.dragonflydb.io/dragonflydb/dragonfly
    restart: unless-stopped
    ports:
      - "127.0.0.1:6378:6379"  # Use 6378 port to avoid conflicts with redis
    command:
      [
        "dragonfly",
        "--logtostderr",
        "--maxmemory=25769803776", # 307 MB
        "--requirepass",
        "${PDRAGONFLYDB_PASSWORD}",
      ]
    ulimits:
      memlock: -1
    volumes:
      - "dragonflydb-data:/data"

volumes:
  dragonflydb-data:

```

```shell
docker pull docker.dragonflydb.io/dragonflydb/dragonfly && \
docker tag docker.dragonflydb.io/dragonflydb/dragonfly dragonfly

docker run --network=host --ulimit memlock=-1 --rm dragonfly

redis-cli PING  # redis-cli can be installed with "apt install -y redis-tools"


docker run --network=host --ulimit memlock=-1 docker.dragonflydb.io/dragonflydb/dragonfly

```

–ulimit memlock=-1 is needed since some Linux distros configure the default memlock limit for containers as 64m. Naturally, as an in-memory datastore, Dragonfly requires more.

## Additional configuration
Dragonfly supports redis run-time arguments where applicable. For example, you can run: docker run --network=host --ulimit memlock=-1 --rm dragonfly --requirepass=foo --bind localhost.

Dragonfly currently supports the following Redis arguments:

* port
* bind
* requirepass
* maxmemory
* dir - by default, dragonfly docker uses /data folder for snapshotting. You can use -v docker option to map it to your host folder.
dbfilename

### In addition, it has Dragonfly specific arguments options:

* memcache_port - to enable memcached compatible API on this port. Disabled by default.
* keys_output_limit - maximum number of returned keys in keys command. Default is 8192. keys is a dangerous command. we truncate its result to avoid blowup in memory when fetching too many keys.
* dbnum - maximum number of supported databases for select.
* cache_mode - see Cache section below.



