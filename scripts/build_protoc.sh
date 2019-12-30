#!/bin/bash

##############################################
# Build the latest Protocol Buffer from source
##############################################
# https://github.com/protocolbuffers/protobuf/releases
# https://github.com/protocolbuffers/protobuf/blob/master/src/README.md

git clone https://github.com/google/protobuf.git
cd protobuf
git submodule update --init --recursive
./autogen.sh
./configure
make
make check
make install
sudo ldconfig