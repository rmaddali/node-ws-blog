# node-ws-blog

Let’s start by setting a few environment variables:

export AWS_REGION=us-west-2 <br />
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text) <br />
export CLUSTER_NAME=eks-websockets-test-env <br />
export ECR_REPO=node-ws <br />
export NAMESPACE=node-ws <br />

<b>Create EKS Cluster </b>

kubectl create cluster \  <br />
  --name $CLUSTER_NAME \
  --region $AWS_REGION \
  --managed
  
 <b>Create ECR Image repo </b>
 
 Create an Amazon ECR repository to store the container image for the node-ws. The following commands creates a new repo if it does not already exist:
  
IMAGE_REPO="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_NAME=${ECR_REPO}

export ECR_REPO_URI=$(aws ecr describe-repositories --repository-name ${IMAGE_NAME}  | jq -r '.repositories[0].repositoryUri')

if [ -z "$ECR_REPO_URI" ]
then
      echo "${IMAGE_REPO}/${IMAGE_NAME} does not exist. So creating it..."
      ECR_REPO_URI=$(aws ecr create-repository \
        --repository-name $IMAGE_NAME\
        --region $AWS_REGION \
        --query 'repository.repositoryUri' \
        --output text)
      echo "ECR_REPO_URI=$ECR_REPO_URI"
else
      echo "${IMAGE_REPO}/${IMAGE_NAME} already exist..."
fi


