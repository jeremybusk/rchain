#!/bin/bash
# do rholang tests
# Set bash output verbose and fail hard
set -euxo pipefail

project_root_dir=${TRAVIS_BUILD_DIR}
rosette_root_dir=${TRAVIS_BUILD_DIR}/rosette
rholang_root_dir=${TRAVIS_BUILD_DIR}/rholang

(cd "${rosette_root_dir}"; ./install.sh)
(cd "${rosette_root_dir}"; ./build.sh)
#sbt -Dsbt.log.noformat=true clean bnfc:generate coverage test coverageReport rpm:packageBin debian:packageBin
${project_root_dir}/ci/rholang-rho2rbl.sh
${project_root_dir}/ci/test-rhoscala-rbls.sh
${project_root_dir}/ci/clean-up.sh

