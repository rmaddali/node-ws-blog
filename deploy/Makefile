#!/bin/bash

IMAGE_REPO ?= ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
IMAGE_NAME ?= node-ws
IMAGE_TAG ?= latest
PWD := $(shell pwd)
BASE_DIR := $(shell basename $(PWD))
LBC_VERSION ?= ${LBC_VERSION}
LBC_CHART_VERSION ?= ${LBC_CHART_VERSION}
POLICY_NAME ?= AWSLoadBalancerControllerIAMPolicy
IAM-SA ?= aws-load-balancer-controller



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

image: create-iam-policy create-iam-sa install-lb-controller

create-iam-policy: 
	@echo "Checking if iam policy for $(CLUSTER_NAME) exists"
	curl -fsSLo iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${LBC_VERSION}/docs/install/iam_policy.json
	LB_CONT_POLICY=$$(aws iam get-policy --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}); \
	if [ -z "$$LB_CONT_POLICY" ]; then \
	echo "createing policy"; \
		aws iam create-policy \
	--policy-name ${POLICY_NAME} \
	--policy-document file://iam_policy.json; \
	LB_CONT_POLICY=$$(aws iam get-policy --policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}); \
	echo "created Policy ECR_REPO_URI=$$LB_CONT_POLICY"; \
    else \
		echo "Policy already exists"; \
	fi
create-iam-sa: create-iam-policy
	@echo "Checking IAM role and serviceaccounts"
	LB_IAM_ROLE=$$(aws iam get-role --role-name aws-load-balancer-controller); \
	if [ -z "$$LB_IAM_ROLE" ]; then \
	echo "creating IAM Role"; \
	eksctl create iamserviceaccount \
	--cluster ${CLUSTER_NAME} \
	--namespace kube-system \
	--name aws-load-balancer-controller \
	--attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
	--override-existing-serviceaccounts \
	--approve; \
	echo "created IAM Role = aws-load-balancer-controller"; \
	else \
	   	echo "IAM role already exists"; \
	fi
install-tgb-crd:
	kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master
install-lb-controller: install-tgb-crd
	helm repo add eks https://aws.github.io/eks-charts 
	helm upgrade -i aws-load-balancer-controller \
		eks/aws-load-balancer-controller \
    	-n kube-system \
    	--set clusterName=${CLUSTER_NAME} \
    	--set serviceAccount.create=false \
    	--set serviceAccount.name=aws-load-balancer-controller \
    	--set image.tag="${LBC_VERSION}" \
    	--version="${LBC_CHART_VERSION}"; \
    echo "Installed lb controller"; 

############################################################
# clean section
############################################################
clean:
	@rm -rf output

.PHONY: all build image clean