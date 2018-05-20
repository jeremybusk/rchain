#!/bin/sh
set -exo pipefail

## Install BNFC Converter
# ref: http://bnfc.digitalgrammars.com/
git clone https://github.com/BNFC/bnfc.git
cd bnfc/source
if [ $(cat /etc/*release | grep ID=alpine) ]; then 
  cabal install --global alex happy
  sudo cabal install --global
  cabal install --global mtl
else
  sudo cabal install --global
fi
