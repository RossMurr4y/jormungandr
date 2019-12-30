#!/bin/bash

##############################################
# Build the latest Protocol Buffer from source
##############################################

# determine which version is the latest released.
download_url="https://github.com/protocolbuffers/protobuf/releases/download"
releases_url="https://api.github.com/repos/protocolbuffers/protobuf/releases/latest"
latest_version="$(curl --silent $releases_url | jq -r .tag_name[1:])"

# download latest version tarball
curl -O "${download_url}/v${latest_version}/protoc-${latest_version}-linux-x86_64.zip"

# extract archive, make & tidy up
unzip protoc-${latest_version}-linux-x86_64.zip
rm -f ./protoc-${latest_version}-linux-x86_64.zip
./configure
make
make check
make install
ldconfig