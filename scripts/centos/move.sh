#!/usr/bin/env bash
systemctl restart docker
cp -avx /var/lib/docker/ /home/docker -rf
systemctl daemon-reload && systemctl restart docker