#!/usr/bin/env bash
set -eo pipefail

sudo curl -sSL https://get.docker.com/ | sh
sudo docker info
