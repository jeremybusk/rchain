#!/usr/bin/env sh
set -ou pipefail

sudo curl -sSL https://get.docker.com/ | sh
sudo docker info
