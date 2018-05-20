#!/bin/bash
set -exo pipefail

cd crypto
git clone https://github.com/jedisct1/libsodium --branch stable
cd libsodium
./configure
make && make check
sudo make install
