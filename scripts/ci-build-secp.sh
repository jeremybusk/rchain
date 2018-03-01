#!/usr/bin/env bash
## Install needed crypto

## Set BASH environment so it will fail properly throwing exit code
set -euxo pipefail

## Detect if running in docker container - setup using sudo accordingly
if [[ $(cat /proc/self/cgroup  | grep docker) = *docker* ]]; then
    echo "Running in docker container!"
    sudo=""
else
    sudo="sudo"
fi

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


${sudo} apt-get install autoconf libtool -yqq
cd crypto
if [ -d "secp256k1" ]; then
    rm -rf secp256k1
fi
git clone https://github.com/bitcoin-core/secp256k1
cd secp256k1
./autogen.sh
./configure --enable-jni --enable-experimental --enable-module-schnorr --enable-module-ecdh --prefix=$PWD/.tmp
make install
cd ${project_root}



# cd crypto
# git clone https://github.com/bitcoin-core/secp256k1
# cd secp256k1
# ./autogen.sh
# ./configure --enable-jni --enable-experimental --enable-module-schnorr --enable-module-ecdh --prefix=$PWD/.tmp
# make install
