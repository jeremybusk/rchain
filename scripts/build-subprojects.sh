#!/bin/bash

# Set bash output verbose and fail hard
set -euxo pipefail
project_root_dir=${TRAVIS_BUILD_DIR}
rosette_root_dir=${TRAVIS_BUILD_DIR}/rosette
rholang_root_dir=${TRAVIS_BUILD_DIR}/rholang

if [ -d "${SUBPROJECT}" -a -f "${SUBPROJECT}/build.sh" ]; then
    echo "${SUBPROJECT}/build.sh"
    (cd "${SUBPROJECT}"; ./build.sh)
elif [ -f "build.sbt" ]; then
    (cd "${rosette_root_dir}"; ./install.sh)
    echo "${rosette_root_dir}/build.sh"
    (cd "${rosette_root_dir}"; ./build.sh)
    sbt -Dsbt.log.noformat=true clean bnfc:generate coverage test coverageReport rpm:packageBin debian:packageBin
    ${project_root_dir}/ci/rholang-rho2rbl.sh
    ${project_root_dir}/ci/clean-up.sh
    for sub in crypto comm rholang roscala storage node; do
	(bash <(curl -s https://codecov.io/bash) -X gcov -s ./$sub -c -F $sub)
    done
else
    echo "No build/test files found!"
    exit 1
fi
