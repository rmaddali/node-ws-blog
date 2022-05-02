#!/bin/bash

IMAGE_REPO ?= ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
IMAGE_NAME ?= ${ECR_REPO}
IMAGE_TAG ?= latest
ECR_REPO_URI ?= aws ecr describe-repositories --repository-name ${IMAGE_NAME}  | jq -r '.repositories[0].repositoryUri'


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

image: create-repo build-image push-image

create-repo:
	@echo " Creating ECR image repo: ${IMAGE_REPO}"
	@echo "$(ECR_REPO_URI) already exist..."
	if [ -z "$(ECR_REPO_URI)" ]; then \
		 aws ecr create-repository \
        --repository-name $(IMAGE_NAME) \
        --region $(AWS_REGION) \
        --query 'repository.repositoryUri' \
        --output text; \
      echo "created image repo ECR_REPO_URI=$(ECR_REPO_URI)"; \
	else \
		echo "Not empty"; \
	fi
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