#!/bin/sh 
set -eux
## Install BNFC Converter 
# ref: http://bnfc.digitalgrammars.com/
git clone https://github.com/BNFC/bnfc.git
cd bnfc/source
cabal install --global
