#!/usr/bin/env bash
export PATH=$PATH:$(pwd -P)/scripts
source header.sh

sudo curl -sSL https://get.docker.com/ | sh
sleep 10  # wait for docker to start
ps -eaf | grep docker
sudo docker info
