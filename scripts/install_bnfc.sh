#!/bin/sh
set -ex

## Install BNFC Converter
# ref: http://bnfc.digitalgrammars.com/
git clone https://github.com/BNFC/bnfc.git
cd bnfc/source
sudo cabal install --global
# cabal install --global alex happy
# sudo cabal install --global
# cabal install --global mtl
