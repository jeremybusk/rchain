#!/usr/bin/env bash
apt-get update -y
apt-get install sudo -y
apt-get install openjdk-8-jdk -y
apt-get install apt-transport-https -y
## Install SBT
echo "deb http://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 642AC823
apt-get update -y
apt-get install sbt -y
sbt sbt-version
apt-get install jflex -y
apt-get install haskell-platform -y
apt-get install rpm -y
apt-get install fakeroot -y
# Install scripted deps
./scripts/install_secp.sh
./scripts/install_sodium.sh
./scripts/install_bnfc.sh
