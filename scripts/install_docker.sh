#!/usr/bin/env bash
export PATH=$PATH:$(pwd -P)/scripts
source header.sh

sudo curl -sSL https://get.docker.com/ | sh
sudo docker info
