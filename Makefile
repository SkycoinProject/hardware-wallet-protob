.DEFAULT_GOAL := help
.PHONY: help all clean
.PHONY: build-go build-js build-c build-py
.PHONY: install-deps-go install-deps-js install-deps-nanopb install-protoc
.PHONY: clean-go clean-js clean-c clean-py

REPO_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

UNAME_S = $(shell uname -s)
PYTHON ?= python

ifeq ($(TRAVIS),true)
  OS_NAME=$(TRAVIS_OS_NAME)
else
  ifeq ($(UNAME_S),Linux)
    OS_NAME=linux
  endif
  ifeq ($(UNAME_S),Darwin)
    OS_NAME=osx
  endif
endif

PROTOC_VERSION      ?= 3.6.1
PROTOC_ZIP          ?= protoc-$(PROTOC_VERSION)-$(OS_NAME)-x86_64.zip
PROTOC_URL          ?= https://github.com/google/protobuf/releases/download/v$(PROTOC_VERSION)/$(PROTOC_ZIP)
PROTOC_GOGO_URL      = github.com/gogo/protobuf
PROTOC_NANOPBGEN_DIR = nanopb/vendor/nanopb/generator

PROTOB_SPEC_DIR = protob
PROTOB_MSG_DIR  = $(PROTOB_SPEC_DIR)/messages

PROTOB_GO_DIR = go
PROTOB_JS_DIR = js
PROTOB_PY_DIR = py
PROTOB_C_DIR  = c
PROTOB_SRC_DIR  = $(GOPATH)/src/$(PROTOC_GOGO_URL)

PROTOB_MSG_FILES = $(shell ls -1 $(PROTOB_MSG_DIR)/*.proto)
PROTOB_MSG_SPECS = $(patsubst %,$(PROTOB_MSG_DIR)/%,$(notdir $(PROTOB_MSG_FILES)))
PROTOB_MSG_GO    = $(patsubst %,$(PROTOB_GO_DIR)/%,$(notdir $(PROTOB_MSG_FILES:.proto=.pb.go)))
PROTOB_MSG_JS    = $(patsubst %,$(PROTOB_JS_DIR)/%,$(notdir $(PROTOB_MSG_FILES:.proto=.pb.js)))
PROTOB_MSG_PY    = $(patsubst %,$(PROTOB_PY_DIR)/%,$(notdir $(PROTOB_MSG_FILES:.proto=_pb2.py)))
PROTOB_MSG_C     = $(patsubst %,$(PROTOB_C_DIR)/%,$(notdir $(PROTOB_MSG_FILES:.proto=.pb.c)))

all: build-go build-js build-c build-py ## Generate protobuf classes for all languages

clean: clean-go clean-js clean-c clean-py ## Delete temporary and output files
	rm -rf \
		$$( find . -name '*.swp' ) \
		$$( find . -name '*.swo' ) \
		$$( find . -name '*.orig' )

install-protoc: /usr/local/bin/protoc

/usr/local/bin/protoc:
	echo "Downloading protobuf from $(PROTOC_URL)"
	curl -OL $(PROTOC_URL)
	echo "Installing protoc"
	sudo unzip -o $(PROTOC_ZIP) -d /usr/local bin/protoc
	rm -f $(PROTOC_ZIP)

#----------------
# Go lang
#----------------

install-deps-go: install-protoc ## Install tools to generate protobuf classes for go lang
	@if [ -e $(PROTOB_SRC_DIR) ] ; then \
		echo 'Detected $(PROTOC_GOGO_URL) on local file system. Checking v1.2.0' ; \
		cd $(PROTOB_SRC_DIR) && git checkout v1.2.0 ; \
	else \
		echo 'Cloning $(PROTOC_GOGO_URL)' ; \
		git clone --branch v1.2.0 --depth 1 https://$(PROTOC_GOGO_URL) $(PROTOB_SRC_DIR) ; \
	fi
	( cd $(PROTOB_SRC_DIR)/protoc-gen-gogofast && go install )

build-go: install-deps-go $(PROTOB_MSG_GO) ## Generate protobuf classes for go lang

$(PROTOB_GO_DIR)/%.pb.go: $(PROTOB_MSG_DIR)/%.proto
	protoc -I./$(PROTOC_NANOPBGEN_DIR)/proto/ -I protob/messages --gogofast_out=$(PROTOB_GO_DIR) $<

clean-go:
	rm $(PROTOB_GO_DIR)/*.pb.go

#----------------
# Javascript
#----------------

install-deps-js: ## Install tools to generate protobuf classes for javascript
	cd $(REPO_ROOT)/js && npm install

build-js: install-deps-js ## Generate protobuf classes for javascript
	cd $(REPO_ROOT)/js && npm run gen-proto

clean-js:
	rm -rf $(PROTOB_JS_DIR)/skycoin.js $(PROTOB_JS_DIR)/node_modules

#----------------
# C with nanopb
#----------------

install-deps-nanopb: ## Install tools to generate protobuf classes for C with nanopb
	make -C $(PROTOC_NANOPBGEN_DIR)/proto/

build-c: install-deps-nanopb $(PROTOB_MSG_C) $(PROTOB_C_DIR)/messages_map.h ## Generate protobuf classes for C with nanopb

$(PROTOB_C_DIR)/%.pb.c: $(PROTOB_C_DIR)/%.pb $(PROTOB_MSG_DIR)/%.options
#c/%.pb.c: c/%.pb $(PROTOB_MSG_DIR)/%.options
	$(eval PROTOBUF_FILE_OPTIONS := $(subst pb,options,$<))
	$(eval PROTOBUF_FILE_OPTIONS = $(subst c/,,$(PROTOBUF_FILE_OPTIONS)))
	$(PYTHON) $(PROTOC_NANOPBGEN_DIR)/nanopb_generator.py -f $(PROTOB_MSG_DIR)/$(PROTOBUF_FILE_OPTIONS) $< -L '#include "%s"' -T

$(PROTOB_C_DIR)/%.pb: $(PROTOB_MSG_DIR)/%.proto
	protoc -I./$(PROTOC_NANOPBGEN_DIR)/proto/ -I. -I./$(PROTOB_MSG_DIR) $< -o $@

$(PROTOB_C_DIR)/messages_map.h: $(PROTOB_PY_DIR)/messages_map.py $(PROTOB_PY_DIR)/messages_pb2.py $(PROTOB_PY_DIR)/types_pb2.py
	PYTHONPATH="$$PYTHONPATH:$(REPO_ROOT)/$(PROTOB_PY_DIR)" $(PYTHON) $< > $@

clean-c: clean-py
	rm -rf $(PROTOB_C_DIR)/messages_map.h \
		$$( find $(PROTOB_C_DIR) -name '*.pb.c' ) \
		$$( find $(PROTOB_C_DIR) -name '*.pb.h' ) \
		$$( find $(PROTOB_C_DIR) -name '*.d' ) \
		$$( find $(PROTOB_C_DIR) -name '*.i' ) \
		$$( find $(PROTOB_C_DIR) -name '*.s' ) \
		$$( find $(PROTOB_C_DIR) -name '*.o' )

#----------------
# Python with nanopb
#----------------

build-py: install-deps-nanopb $(PROTOB_MSG_PY) ## Generate protobuf classes for Python with nanopb

$(PROTOB_PY_DIR)/%_pb2.py: $(PROTOB_MSG_DIR)/%.proto
	protoc -I./$(PROTOC_NANOPBGEN_DIR)/proto/ -I./$(PROTOB_MSG_DIR) $< --python_out=$(PROTOB_PY_DIR)

clean-py:
	rm -rf $(PROTOB_PY_DIR)/__pycache__/ py/*_pb2.py \
		$$( find $(PROTOB_PY_DIR) -name '*_pb2.py' ) \
		$$( find $(PROTOB_PY_DIR) -name '*.pyc' ) \
		$$( find $(PROTOB_PY_DIR) -name '*.pyd' ) \
		$$( find $(PROTOB_PY_DIR) -name '*.pyo' )

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

