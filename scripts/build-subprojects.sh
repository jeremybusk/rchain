#!/usr/bin/env bash
set -e

case "$SUBPROJECT" in "rosette")

    cd rosette
    nix-build

    ./run.sh rbl/rosette/tests/simple_add.rbl
    ;;

"core")

    sbt -Dsbt.log.noformat=true clean rholang/bnfc:generate coverage test coverageReport

    for sub in crypto comm rholang roscala storage node
    do
        (bash <(curl -s https://codecov.io/bash) -X gcov -s ./$sub -c -F $sub)
    done
    ;;

"test_artifact_creation")

    sbt -Dsbt.log.noformat=true clean rholang/bnfc:generate \
        node/rpm:packageBin \
        node/debian:packageBin \
        node/universal:packageZipTarball
    ;;

"rnode-dockerhub-push")

    ./scripts/rnode-dockerhub-push.sh
    ;;

"p2p-test-network")

    #sudo apt-get -yq install python3-minimal python3-pip
	sudo add-apt-repository ppa:jonathonf/python-3.6
	sudo apt-get update
	sudo apt-get install python3.6
    sudo pip3 install argparse pexpect
    ./scripts/p2p-test-network.sh
    ;;

"cloud-p2p-test-network")

    ./scripts/cloud-p2p-test-network.sh
    ;;

"rholang_more_tests")

    # Prep nix 
    nix-env -iA nixpkgs.openjdk8 nixpkgs.sbt
    nix-env -f nix/default.nix -iA rchainPackages

    # Build rosette binary
    cd rosette
    nix-build

    cd ${TRAVIS_BUILD_DIR}

    scripts/rholang-more-tests-main.sh
    ;;

*)

    echo "$SUBPROJECT build instructions are missing"
    exit 1

esac
