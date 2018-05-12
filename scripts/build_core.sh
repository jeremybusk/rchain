#!/usr/bin/env bash
set -eo pipefail

sbt -Dsbt.log.noformat=true clean rholang/bnfc:generate coverage test coverageReport

for sub in crypto comm rholang roscala storage node
do
    (bash <(curl -s https://codecov.io/bash) -X gcov -s ./$sub -c -F $sub)
done
