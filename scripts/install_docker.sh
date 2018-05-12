#!/usr/bin/env bash
set -eo pipefail

apt-get install sudo -yq
sudo curl -sSL https://get.docker.com/ | sh
sudo docker info
