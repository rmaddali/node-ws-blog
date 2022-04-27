# node-ws-blog

Let’s start by setting a few environment variables:

export AWS_REGION=us-west-2 <br />
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text) <br />
export CLUSTER_NAME=eks-websockets-test-env <br />
export ECR_REPO=node-ws <br />
export NAMESPACE=node-ws <br />

Create EKS Cluster 

ksctl create cluster \  <br />
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --managed



