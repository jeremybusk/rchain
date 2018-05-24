#!/usr/bin/env bash 
set -ex # x is for cmd debug
PROJECT_ROOT_DIR=$(pwd -P)
export PATH=$PATH:$(pwd -P)/scripts
#source header.sh

tmp_dir=$(mktemp -d /tmp/rchain-tmp.XXXXXXXX)
apk update 
apk add git 
apk add sudo
apk add bash 

# Docker
# set +e
# docker info
# set -e
apk add docker # add docker to connect to outside
# if [ $? -ne 0 ]; then
# apk add openrc
# apk add docker 
# rc-update add docker boot
# service docker start
# fi

#/etc/init.d/docker start
sleep 10
docker info
#docker ps
# if [[ ! $(docker info) ]]; then
#   apk add openrc
#   apk add docker 
#   rc-update add docker boot
#   service docker start
# fi
apk add python3 
#apk add py-pip
#pip install docker-compose
pip3 install docker-compose
apk add openjdk8
export JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk"
apk add cabal 
apk add ghc 
#apk add alpine-sdk
cabal update
export LIBRARY_PATH=/usr/lib:$LIBRARY_PATH 
#cabal install --global alex happy
#cabal install --global mtl
#- cabal install alex happy mtl --   apk add libc-dev??
apk add g++ cmake make automake autoconf libtool libc-dev
# protobuf
#- apk add glibc 
# -o /usr/local/bin/docker-compose
apk --no-cache add ca-certificates wget
wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub
wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-2.27-r0.apk
apk add glibc-2.27-r0.apk
wget -q http://jflex.de/release/jflex-1.6.1.tar.gz
tar -C /usr/share -xvzf jflex-1.6.1.tar.gz
ln -s /usr/share/jflex-1.6.1/bin/jflex /usr/bin/jflex
apk add flex 
apk add flex-dev
apk add rpm 
apk add fakeroot 
apk add sbt --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing 
sudo pip3 install argparse docker pexpect
#apk add docker
#service docker start
