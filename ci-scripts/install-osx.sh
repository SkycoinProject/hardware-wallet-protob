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
brew install pyenv
brew install pyenv-virtualenv
echo "Installing Python=$PYTHON_VERSION"
OPENSSL_PATH="$(brew --prefix openssl)"
LDFLAGS="-L$OPENSSL_PATH/lib" CPPFLAGS="-I$OPENSSL_PATH/include" CFLAGS="-I$OPENSSL_PATH/include" pyenv install $PYTHON_VERSION

