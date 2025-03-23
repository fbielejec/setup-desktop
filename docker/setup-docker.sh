#!/bin/bash

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common docker.io docker-compose-v2

# Add user to docker group. Added user can run docker command without sudo command
sudo groupadd docker
sudo usermod -aG docker $USER
sudo gpasswd -a "${USER}" docker

docker --version
docker-compose --version

# test
docker run hello-world
