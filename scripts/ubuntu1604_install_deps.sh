#!/usr/bin/env bash
export PATH=$PATH:$(pwd -P)/scripts
source header.sh

# Prep "set" for CI if CI environment variable is set
if [[ "${CI}" = "true" ]]; then
    set -exo pipefail
else
    set -eo pipefail
fi

### Install all dependencies on Ubuntu 16.04 LTS (Xenial Xerus) for RChain dev environment.

## Verify operating system (OS) version is Ubuntu 16.04 LTS (Xenial Xerus)
# Add more OS versions as necessary. 
version=$(cat /etc/*release | grep "^VERSION_ID" | awk -F= '{print $2}' | sed 's/"//g')
if [[ "$version" == "16.04" ]]; then
    echo "Running install on Ubuntu 16.04" 
else
    echo "Error: Not running on Ubuntu 16.04"
    echo "Exiting"
    exit
fi

# Install Docker-CE
apt-get update -yqq
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  apt-key add -
add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu    xenial    stable"
apt-get update -yqq
apt install -y docker-ce sudo

## Resynchronize the package index files from their sources
apt-get update -yqq
## Install g++ multilib for cross-compiling as rosette is currently only 32-bit
apt-get install g++-multilib -yqq
## Install misc tools 
apt-get install cmake curl git -yqq
## Install Java OpenJDK 8
#  apt-get install default-jdk -yqq # alternate jdk install 
apt-get install openjdk-8-jdk -yqq

add-apt-repository ppa:jonathonf/python-3.6
apt-get install python3.6

## Install Haskell Platform for bnfc
# ref: https://www.haskell.org/platform/#linux-ubuntu
# ref: https://www.haskell.org/platform/ # all platforms
apt-get install haskell-platform -yqq

# ## Build Needed Crypto
# # Build secp 
apt-get install autoconf libtool -yqq
# cd ${PROJECT_ROOT_DIR}
# ./scripts/install_secp.sh
# 
# # Build libsodium
# cd ${PROJECT_ROOT_DIR}
# ./scripts/install_sodium.sh
# 
# cd ${PROJECT_ROOT_DIR}
# ## Install BNFC Converter 
# # ref: http://bnfc.digitalgrammars.com/
# ./scripts/install_bnfc.sh

## Install SBT 
cd ${PROJECT_ROOT_DIR}
apt-get install apt-transport-https -yqq
echo "deb https://dl.bintray.com/sbt/debian /" |  tee -a /etc/apt/sources.list.d/sbt.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
apt-get update -yqq
apt-get install sbt -yqq
## Install JFlex 
apt-get install jflex -yqq

## Build RChain via SBT build.sbt 
cd ${PROJECT_ROOT_DIR}
#sbt bnfc:generate node/docker

