#!/usr/bin/env bash
systemctl stop docker
mkdir -p -m 750 /home/docker/
cp -avx /var/lib/docker/ /home/docker -rf
systemctl daemon-reload && systemctl restart docker