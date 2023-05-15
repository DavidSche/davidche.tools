



``` shell
docker run --rm -it \
-v /etc/so/rabbitmq.config:/etc/rabbitmq/rabbitmq.config:ro \
-v /etc/so/definitions.json:/etc/rabbitmq/definitions.json:ro \
rabbitmq:3.6-management
```


```yaml

version: '3.7'
services:
    rabbitmq:
        image: "rabbitmq:3.6-management"
        ports:
            - 5672:5672
            - 15672:15672
        volumes:
            - /etc/so/rabbitmq.config:/etc/rabbitmq/rabbitmq.config:ro
            - /etc/so/definitions.json:/etc/rabbitmq/definitions.json:ro

```
