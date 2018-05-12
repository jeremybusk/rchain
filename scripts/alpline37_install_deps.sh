apk update 
apk add git 
apk add sudo
apk add bash 
apk add cabal 
apk add ghc 
#apk add alpine-sdk
cabal update
export LIBRARY_PATH=/usr/lib:$LIBRARY_PATH 
cabal install --global mtl
cabal install --global alex happy
#- cabal install alex happy mtl --   apk add libc-dev??
apk add g++ cmake make automake autoconf libtool libc-dev
# protobuf
#- apk add glibc 
apk --no-cache add ca-certificates wget
wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub
wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-2.27-r0.apk
apk add glibc-2.27-r0.apk
wget http://jflex.de/release/jflex-1.6.1.tar.gz
tar -C /usr/share -xvzf jflex-1.6.1.tar.gz
ln -s /usr/share/jflex-1.6.1/bin/jflex /usr/bin/jflex
apk add flex 
apk add flex-dev
apk add rpm 
apk add fakeroot 
apk add openjdk8
export JAVA_HOME="/usr/lib/jvm/java-1.8-openjdk"
apk add python3 
apk add sbt --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing 
sudo pip3 install argparse docker pexpect
