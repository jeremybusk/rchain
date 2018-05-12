#!/usr/bin/env bash
export PATH=$PATH:$(pwd -P)/scripts
source header.sh

sudo curl -sSL https://get.docker.com/ | sh
ps -eaf | grep docker
journalctl -a
service docker start
systemctl start docker
sleep 10  # wait for docker to start
sudo docker info
