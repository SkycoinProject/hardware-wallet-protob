#!/usr/bin/env bash

set -x

brew update

# Install protobuf
brew install protobuf protobuf-c

# Install gimme
brew install gimme

# Install Python
if [ -z "$PYTHON_VERSION"] ; then
  export PYTHON_VERSION=3.5.0
fi
brew install openssl sqlite pyenv
brew link --force openssl
brew link --force sqlite
brew install pyenv-virtualenv
echo "Installing Python=$PYTHON_VERSION"
OPENSSL_PATH="$(brew --prefix openssl)"
CFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix sqlite)/include" \
CPPFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix sqlite)/include" \
LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix sqlite)/lib" \
pyenv install -v $PYTHON_VERSION

