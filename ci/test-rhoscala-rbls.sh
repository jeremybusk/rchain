#!/usr/bin/env bash

set -euxo pipefail

rosette_root_dir=${TRAVIS_BUILD_DIR}/rosette
rholang_root_dir=${TRAVIS_BUILD_DIR}/rholang

ulimit -s unlimited # make stack space unlimited
export ESS_SYSDIR=rosette/rbl/rosette
for rbl_file in $(ls ${rholang_root_dir}/tests/*.rbl); do
    #out=$(./rosette/build.out/src/rosette --quiet --boot-dir=rosette/rbl/rosette --boot=boot.rbl ${rbl_file} | grep ^Pass)
    out=$(${rosette_root_dir}/build.out/src/rosette --quiet --boot-dir=${rosette_root_dir}/rbl/rosette --boot=boot.rbl ${rbl_file} | grep ^Pass)
    if [ -z $out ]; then
        echo "[error] - rbl file ${rbl_file} did not return \"Pass\""
        exit 1
    fi
done
