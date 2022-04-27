# node-ws-blog

export AWS_REGION=us-east-1 
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
export CLUSTER_NAME=eks-
export ECR_REPO=node-ws
export SERVICE=custom-kube-scheduler-webhook
export NAMESPACE=custom-kube-scheduler-webhook
export SECRET=custom-kube-scheduler-webhook-certs



