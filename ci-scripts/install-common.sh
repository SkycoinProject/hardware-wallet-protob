#!/usr/bin/env bash

set -x

# Upgrade protobuf python
PROTOBUF_VERSION=3.6.0
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    source ./protobuf-version-linux.sh
elif [[ "$OSTYPE" == "darwin"* ]]; then
    source ./protobuf-version-osx.sh
fi
pip3 install --upgrade protobuf
pip3 install "protobuf==${PROTOBUF_VERSION}" ecdsa
pip install --upgrade protobuf 
