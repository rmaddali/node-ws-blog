#!/bin/bash

IMAGE_REPO ?= ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
IMAGE_NAME ?= ${ECR_REPO}
IMAGE_TAG ?= latest


PWD := $(shell pwd)
BASE_DIR := $(shell basename $(PWD))

# Keep an existing NODE_WS_PATH, make a private one if it is undefined
NODE_WS_PATH_DEFAULT := $(PWD)/app
export NODE_WS_PATH ?= $(NODE_WS_PATH_DEFAULT)
TESTARGS_DEFAULT := "-v"
export TESTARGS ?= $(TESTARGS_DEFAULT)
DEST := $(NODE_WS_PATH)/src/$(GIT_HOST)/$(BASE_DIR)





LOCAL_OS := $(shell uname)
ifeq ($(LOCAL_OS),Linux)
    TARGET_OS ?= linux
    XARGS_FLAGS="-r"
else ifeq ($(LOCAL_OS),Darwin)
    TARGET_OS ?= darwin
    XARGS_FLAGS=
else
    $(error "This system's OS $(LOCAL_OS) isn't recognized/supported")
endif

all: image





############################################################
# image section
############################################################

image: build-image push-image

build-image: 
	@echo "Building the docker image: $(IMAGE_NAME):$(IMAGE_TAG)..."
	@docker build --no-cache -t  $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) .

push-image: build-image
	@echo "Pushing the docker image for $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG) ..."	
	aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $(IMAGE_REPO)/$(IMAGE_NAME)
	@docker push $(IMAGE_REPO)/$(IMAGE_NAME):$(IMAGE_TAG)
	

############################################################
# clean section
############################################################
clean:
	@rm -rf output

.PHONY: all build image clean