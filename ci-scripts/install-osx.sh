#!/usr/bin/env bash

set -x

brew update

# Install protobuf
brew install protobuf protobuf-c

# Install gimme
brew install gimme

# Install Python 3.5
brew install pyenv
brew install pyenv-virtualenv
pyenv install 3.5.0

