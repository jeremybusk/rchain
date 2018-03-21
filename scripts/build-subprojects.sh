#!/bin/bash

set -e

if [ -d "${SUBPROJECT}" -a -f "${SUBPROJECT}/build.sh" ]; then
    echo "${SUBPROJECT}/build.sh"
    (cd "${SUBPROJECT}"; bash ./build.sh)
elif [ -f "build.sbt" ]; then
    sbt -Dsbt.log.noformat=true clean bnfc:generate coverage test coverageReport rpm:packageBin debian:packageBin
    cd rosette 
    ./install.sh
    ./build.sh
    #ls -laht build.out/src/rosette
    cd ../

    echo "jtest"
	# Run test RBLs using rosette binary
	ulimit -s unlimited
	export ESS_SYSDIR=rosette/rbl/rosette
	for rbl_file in $(ls rholang/tests/*rbl); do
		out=$(./rosette/build.out/src/rosette --quiet --boot-dir=rosette/rbl/rosette --boot=boot.rbl ${rbl_file} | grep ^Pass)
		if [ -z $out ]; then
			echo "[error] - rbl file ${rbl_file} did not return \"Pass\""
			exit 1
		fi
	done
    echo "jtest"

#     for rbl_file in $(ls rholang/tests/*rbl); do
#         #./rosette/build.out/src/rosette --quiet --interactive-repl --boot-dir=rosetteurbl/rosette --boot=boot.rbl ${rbl_file}
#         ulimit -s unlimited && export ESS_SYSDIR=rosette/rbl/rosette && ./rosette/build.out/src/rosette --quiet --boot-dir=rosette/rbl/rosette --boot=boot.rbl rholang/tests/arithmetic_test.rbl
#     done

    for sub in crypto comm rholang roscala storage node; do
	(bash <(curl -s https://codecov.io/bash) -X gcov -s ./$sub -c -F $sub)
    done
else
    echo "No build/test files found!"
    exit 1
fi
