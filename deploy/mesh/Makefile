#!/bin/bash

IMAGE_REPO ?= ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
IMAGE_NAME ?= node-ws
IMAGE_TAG ?= latest
PWD := $(shell pwd)
BASE_DIR := $(shell basename $(PWD))
LBC_VERSION ?= ${LBC_VERSION}
LBC_CHART_VERSION ?= ${LBC_CHART_VERSION}
POLICY_NAME ?= AWSAppMeshK8sControllerIAMPolicy
IAM_SA_NAME ?= appmesh-controller



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

image: install-mesh-crds create-iam-policy create-iam-sa helm-update install-mesh-controller

install-mesh-crds:
	@echo "Installing mesh CRD's"
	kubectl apply -k "github.com/aws/eks-charts/stable/appmesh-controller//crds?ref=master"
	@echo "Installed mesh CRD's"
create-iam-policy: 
	@echo "Checking if iam policy for $(CLUSTER_NAME) exists"
	curl -fsSLo controller-mesh-iam-policy.json https://raw.githubusercontent.com/aws/aws-app-mesh-controller-for-k8s/master/config/iam/controller-iam-policy.json
	MESH_CONT_POLICY=$$(aws iam get-policy --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}); \
	if [ -z "$$MESH_CONT_POLICY" ]; then \
	echo "creating policy"; \
		aws iam create-policy \
	--policy-name ${POLICY_NAME} \
	--policy-document file://controller-mesh-iam-policy.json; \
	MESH_CONT_POLICY=$$(aws iam get-policy --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}); \
	echo "created Policy MESH_CONT_POLICY=$$MESH_CONT_POLICY"; \
    else \
		echo "MESH_CONT_POLICY already exists"; \
	fi
create-iam-sa: create-iam-policy
	@echo "Checking IAM role and serviceaccounts"
	MESH_CONT_IAM_ROLE=$$(aws iam get-role --role-name appmesh-controller); \
	if [ -z "$$MESH_CONT_IAM_ROLE" ]; then \
	echo "creating MESH_CONT_IAM_ROLE Role"; \
	eksctl create iamserviceaccount \
	--cluster ${CLUSTER_NAME} \
	--namespace appmesh-system  \
	--name ${IAM_SA_NAME} \
	--attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}, arn:aws:iam::aws:policy/AWSCloudMapFullAccess, arn:aws:iam::aws:policy/AWSAppMeshFullAccess \
	--override-existing-serviceaccounts \
	--approve; \
	echo "created IAM Role = appmesh-controller"; \
	else \
	   	echo "IAM role already exists"; \
	fi
helm-update:
	helm repo add eks https://aws.github.io/eks-charts
	helm repo update
install-mesh-controller: helm-update create-iam-sa create-iam-policy install-mesh-crds
	helm upgrade -i appmesh-controller eks/appmesh-controller \
		--namespace appmesh-system \
    	--set region=${AWS_REGION} \
    	--set serviceAccount.create=false \
    	--set serviceAccount.name=appmesh-controller \
		--set tracing.provider=x-ray; \
         echo "Installed lb controller"; \

############################################################
# clean section
############################################################
clean:
	@rm -rf output

.PHONY: all build image clean