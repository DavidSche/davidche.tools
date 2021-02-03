#!/bin/bash
echo "create config !"
docker config create prometheus_config ./prometheus/prometheus.yml
echo "create network !"
docker network create --driver overlay --attachable monitoring


