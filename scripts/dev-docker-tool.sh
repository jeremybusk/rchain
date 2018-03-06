#!/usr/bin/env bash
# Allows easy interface for developers to use docker in development 
# Keep your host clean by using this handy tool - docker-dev.
# Helping the developer to use docker to make development easier and contained.

## set variables
container_name=rchain-docker-dev
base_dir=$(basename $(pwd)) # base directory of working directory

## Create argument help function
help_text="Missing argument to perform on rchain-docker-dev container.
Options are:
build     # builds subprojects in docker container 
create    # this creates, runs and installs dependencies on Ubuntu 16.04 docker container
install-docker-ce    # this installs Docker Community Edition on your host 
remove    # stops and removes container
stop      # stops container"

if [ "$#" -ne 1 ]; then
    echo "${help_text}"
    exit
elif [ $1 = "help" ]; then
    echo "${help_text}"
    exit
fi

if [ ${base_dir} != "rchain" ]; then
	echo "Script must be ran from project root directory"
    exit
fi


## Process argument 
if [ $1 = "create" ]; then
    docker run -d \
        -it \
        --name ${container_name} \
        -v "$(pwd):/src/rchain" \
        ubuntu:16.04
    
        #-v "$(pwd)"../rchain:/src/rchain \
	# while [ $(docker inspect -f {{.State.Running}} rchain-docker-dev) == false ]
	# do
    # 	echo "Waiting for docker container to start."
   	# 	sleep 1
	# done
    # sleep 1

    docker exec ${container_name} sh -c "cd /src/rchain; /src/rchain/scripts/ci-install-deps.sh"
elif [ $1 = "remove" ]; then
    docker container rm -f ${container_name} 
elif [ $1 = "stop" ]; then
    docker container stop ${container_name}
elif [ $1 = "install-docker-ce" ]; then
    # get and install docker
    curl -sSL https://get.docker.com/ | sh 
elif [ $1 = "build" ]; then
    #docker exec devtest /src/rchain/scripts/ci-build-subprojects.sh
    docker exec -ti ${container_name}  sh -c "cd /src/rchain; /src/rchain/scripts/ci-build-subprojects.sh"
else
    echo "Invalid argument supplied" 
fi
