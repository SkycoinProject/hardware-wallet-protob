#!/usr/bin/env bash

set -x

# Install protobuf
curl -LO "https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip"
mkdir protoc
yes | unzip "protoc-${PROTOBUF_VERSION}-linux-x86_64.zip" -d $HOME
find $HOME/bin -name protoc

# Install gimme
curl -sL -o "$HOME/bin/gimme" https://raw.githubusercontent.com/travis-ci/gimme/master/gimme
chmod +x "$HOME/bin/gimme"

