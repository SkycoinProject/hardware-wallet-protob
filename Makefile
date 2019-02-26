.DEFAULT_GOAL := help
.PHONY: help
.PHONY: build-go   build-js   build-nanopb
.PHONY: install-go install-js install-nanopb

REPO_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

UNAME_S = $(shell uname -s)

ifeq ($(TRAVIS),true)
  OS_NAME=$(TRAVIS_OS_NAME)
else ifeq ($(UNAME_S,Linux))
  OS_NAME=linux
else ifeq ($(UNAME_S,Darwin))
  OS_NAME=osx
endif

PROTOB_SPEC_DIR = $(REPO_ROOT)/protob

PROTOC_VERSION ?= 3.6.1
PROTOC_ZIP ?= protoc-$(PROTOC_VERSION)-$(OS_NAME)-x86_64.zip
PROTOC_URL ?= https://github.com/google/protobuf/releases/download/v$(PROTOC_VERSION)/$(PROTOC_ZIP)

PROTO_FILES = $(shell find $(PROTOB_SPEC_DIR) -type f -name "*.go")

all: build-go build-js build-nanopb ## Generate protobuf classes for all languages

install-protoc:
	echo "Downloading protobuf from $(PROTOC_URL)"
	curl -OL $(PROTOC_URL)
	"Installing protoc"
	sudo unzip -o $(PROTOC_ZIP) -d /usr/local bin/protoc
	rm -f $(PROTOC_ZIP)

#----------------
# Go lang
#----------------

install-deps-go: install-protoc ## Install tools to generate protobuf classes for go lang
	git clone --branch v1.2.0 --depth 1 https://github.com/gogo/protobuf $(GOPATH)/src/github.com/gogo/protobuf
	( cd $(GOPATH)/src/github.com/gogo/protobuf/protoc-gen-gogofast && go install )

build-go: install-go ## Generate protobuf classes for go lang
	protoc -I protob  --gogofast_out=go/ device-wallet/messages/messages.proto device-wallet/messages/types.proto device-wallet/messages/descriptor.proto

#----------------
# Javascript
#----------------

install-deps-js: ## Install tools to generate protobuf classes for javascript
	cd $(REPO_ROOT)/js && npm install

build-js: install-js ## Generate protobuf classes for javascript
	cd $(REPO_ROOT)/js

#----------------
# C with nanopb
#----------------

install-deps-nanopb: ## Install tools to generate protobuf classes for C with nanopb

build-nanopb: install-nanopb ## Generate protobuf classes for C with nanopb

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

