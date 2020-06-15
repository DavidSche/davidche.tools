#!/usr/bin/env bash
git clone https://github.com/bitnami/bitnami-docker-mysql.git
cd bitnami-docker-mysql/VERSION/OPERATING-SYSTEM
docker build -t davidche/mysql-backup:latest .


