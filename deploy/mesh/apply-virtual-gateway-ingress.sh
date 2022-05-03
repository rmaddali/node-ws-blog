#!/bin/bash

# sample value for your variables
IMAGE_REPO=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "Image repo ${IMAGE_REPO}"

# read the yml template from a file and substitute the string 
# {{MYVARNAME}} with the value of the MYVARVALUE variable
echo "yaml file" | sed "s#{{IMAGE_REPO}}#$IMAGE_REPO#g;s#{{AWS_REGION}}#$AWS_REGION#g" ./deploy/mesh/mesh-all.yaml | kubectl apply -f -