#!/usr/bin/env bash

set -x

# Upgrade protobuf python
PROTOBUF_VERSION=3.6.0
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    PROTOBUF_VERSION=3.6.0
elif [[ "$OSTYPE" == "darwin"* ]]; then
    PROTOBUF_VERSION=3.4.0
fi
pip3 install --upgrade protobuf
pip3 install "protobuf==${PROTOBUF_VERSION}" ecdsa
pip install --upgrade protobuf 
