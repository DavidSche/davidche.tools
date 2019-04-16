#!/usr/bin/env bash

TARGET_DIR=~/logs/docker_logs
mkdir -p "$TARGET_DIR"
for name in `sudo docker ps --format '{{.Names}}'`;
do
    path=$(sudo docker inspect --format='{{.LogPath}}' $name)
    sudo cp -rf "$path" "$TARGET_DIR"/$name.log
done