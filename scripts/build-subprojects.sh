#!/bin/bash

set -e

if [ -d "${SUBPROJECT}" -a -f "${SUBPROJECT}/build.sh" ]; then
    echo "${SUBPROJECT}/build.sh"
    (cd "${SUBPROJECT}"; bash ./build.sh)
elif [ -f "build.sbt" ]; then
    cd rosette 
    ./build.sh
    echo "jtest"
    ls -laht build.out/src/rosette
    echo "jtest"
    cd ../
    sbt -Dsbt.log.noformat=true clean bnfc:generate coverage test coverageReport rpm:packageBin debian:packageBin
    for sub in crypto comm rholang roscala storage node; do
	(bash <(curl -s https://codecov.io/bash) -X gcov -s ./$sub -c -F $sub)
    done
else
    echo "No build/test files found!"
    exit 1
fi
