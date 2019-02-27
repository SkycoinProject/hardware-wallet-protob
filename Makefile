.DEFAULT_GOAL := help
.PHONY: help
.PHONY: build-go   build-js   build-nanopb
.PHONY: install-deps-go install-deps-js install-deps-nanopb

REPO_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

UNAME_S = $(shell uname -s)
PYTHON ?= python

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
	@echo "Downloading protobuf from $(PROTOC_URL)"
	curl -OL $(PROTOC_URL)
	@echo "Installing protoc"
	sudo unzip -o $(PROTOC_ZIP) -d /usr/local bin/protoc
	rm -f $(PROTOC_ZIP)

#----------------
# Go lang
#----------------

install-deps-go: install-protoc ## Install tools to generate protobuf classes for go lang
	git clone --branch v1.2.0 --depth 1 https://github.com/gogo/protobuf $(GOPATH)/src/github.com/gogo/protobuf
	( cd $(GOPATH)/src/github.com/gogo/protobuf/protoc-gen-gogofast && go install )

build-go: install-deps-go ## Generate protobuf classes for go lang
	protoc -I protob  --gogofast_out=go/ device-wallet/messages/messages.proto device-wallet/messages/types.proto device-wallet/messages/descriptor.proto

#----------------
# Javascript
#----------------

install-deps-js: ## Install tools to generate protobuf classes for javascript
	cd $(REPO_ROOT)/js && npm install

build-js: install-deps-js ## Generate protobuf classes for javascript
	cd $(REPO_ROOT)/js && npm run gen-proto

#----------------
# C with nanopb
#----------------

install-deps-nanopb: ## Install tools to generate protobuf classes for C with nanopb
	make -C vendor/nanopb/generator/proto/

build-nanopb: install-deps-nanopb nanopb/c/messages.pb.c nanopb/c/types.pb.c nanopb/c/messages_map.h ## Generate protobuf classes for C with nanopb

nanopb/c/%.pb.c: nanopb/c/%.pb nanopb/c/%.options
	$(PYTHON) vendor/nanopb/generator/nanopb_generator.py $< -L '#include "%s"' -T

nanopb/c/%.pb: protob/%.proto
	protoc -I./vendor/nanopb/generator/proto/ -I. -I./protob $< -o $@

nanopb/messages_map.h: nanopb/py/messages_map.py nanopb/py/messages_pb2.py nanopb/py/types_pb2.py
	$(PYTHON) $< > $@

#----------------
# Python with nanopb
#----------------

build-py: install-deps-nanopb nanopb/py/messages_pb2.py nanopb/py/types_pb2.py ## Generate protobuf classes for Python with nanopb

nanopb/py/%_pb2.py: protob/%.proto
	protoc -I../vendor/nanopb/generator/proto/ -I. $< --python_out=nanopb/py

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

