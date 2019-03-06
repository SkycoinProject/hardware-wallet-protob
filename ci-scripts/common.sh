#!/usr/bin/env bash

set -x

# Upgrade protobuf python
PROTOBUF_VERSION=3.4.0
pip3 install --upgrade protobuf
pip3 install "protobuf==${PROTOBUF_VERSION}" ecdsa
pip install --upgrade protobuf 
