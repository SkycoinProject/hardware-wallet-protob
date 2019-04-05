# Hardware wallet protobuffer

[![Build Status](https://travis-ci.com/skycoin/hardware-wallet-protob.svg?branch=master)](https://travis-ci.com/skycoin/hardware-wallet-protob)

[Protocol Buffer](https://developers.google.com/protocol-buffers/) schemas for Skycoin hardware wallet communication and scripts for supporting multiple programming languages.

## Table of Contents

<!-- MarkdownTOC levels="1,2,3,4,5" autolink="true" bracket="round" -->
- [Installation](#installation)
- [Using the scripts](#using-the-scripts)
  - [Make rules](#make-rules)
  - [Environment variables](#environment-variables)
- [Development setup](#development-setup)
  - [Running tests](#running-tests)
  - [Releases](#releases)
    - [Update the version](#update-the-version)
    - [Pre-release testing](#pre-release-testing)
    - [Creating release builds](#creating-release-builds)
<!-- /MarkdownTOC -->

## Installation

All tools needed , including `protoc`, language-specific generators and dependencies, will be installed after executing the following commands.

```sh
git clone https://github.com/skycoin/hardware-wallet-protob
cd hardware-wallet-protob
make install
```

## Using the scripts

It is highly recommended to invoke code generation scripts by executing the suitable make targets. This repository is meant to be included as a submodule in (at least) the following projects:

- [Skycoin hardware wallet](https://github.com/skycoin/hardware-wallet) : Implements bootloader and firmware for the hardware wallet
- [Skycoin hardware wallet library for go language](https://github.com/skycoin/hardware-wallet-go) :
- [Skycoin hardware wallet library for Javascript](https://github.com/skycoin/hardware-wallet-js) :

The following projects also use it either directly or indirectly:

- [Skycoin desktop wallet ](https://github.com/skycoin/skycoin/tree/master/src/electron) :

### Make rules

The following make targets are defined

```sh
$ make help
all                            Generate protobuf classes for all languages
install                        Install protocol buffer tools
clean                          Delete temporary and output files
install-deps-go                Install tools to generate protobuf classes for go lang
build-go                       Generate protobuf classes for go lang
install-deps-js                Install tools to generate protobuf classes for javascript
build-js                       Generate protobuf classes for javascript
install-deps-nanopb            Install tools to generate protobuf classes for C and Python with nanopb
build-c                        Generate protobuf classes for C with nanopb
build-py                       Generate protobuf classes for Python with nanopb
```

### Environment variables

Code generation commands (i.e. `build-*` targets) can generate source code at any location should the following variables be properly set:

- `OUT_C` env var allows to output protobuf C code onto a custom directory
- `OUT_GO` env var allows to output protobuf go code onto a custom directory
- `OUT_JS` env var allows to output protobuf js code onto a custom directory
- `OUT_PY` env var allows to output protobuf Python code onto a custom directory

- When using this projets as submodule of a go project foo.bar/my/project consider using the env var `GO_PREFIX_IMPORT_PATH` to `foo.bar/my/project/path/where/this/project/live/as/submodule`.

## Development setup

To start using these scripts see [installation instructions](#installation). In order to import these specifications and scripts as part of another project follow the following steps:

- Include this repository as submodule e.g. `git submodule add https://github.com/skycoin/hardware-wallet-protob protob`
- In your `Makefile` (or equivalent)
  * Define a variable for the target corresponding to the programming language that needs to be generated e.g. `PROTOB_CMD=build-py` to generate Python code
  * Define a variable for the path to the folder containing protocol buffer classes e.g. `PROTOB_DIR=protob/py`
  * Include a step that executes the target e.g. `make -C protob $(PROTOB_CMD) OUT_PY=$(PROTOB_DIR)` , read about [environment variables](#environment-variables) for further details. 

The project has two branches: `master` and `develop`.

- `develop` is the default branch and will always have the latest development code.
- `master` will always be equal to the current stable release on the website, and should correspond with the latest release tag.

Versioning scheme will match the one of the hardware wallet firmware contract. Release tags will have exactly the same name as [skycoin/hardware-wallet](https://github.com/skycoin/hardware-wallet)'s using it to build firmware deliverables.

### Running tests

By design, this repository does not include a test suite. Nevertheless :

- continuous integration of the generation process in [skycoin/hardware-wallet-protob @ Travis](https://travis-ci.com/skycoin/hardware-wallet-protob)
- external projects do have a test suite that relies upon clases generated by these specifications

### Releases


#### Update the version

See [skycoin/hardware-wallet README](https://github.com/skycoin/hardware-wallet/tree/master/README.md).

