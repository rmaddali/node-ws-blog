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
  
IMAGE_REPO="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com" <br />
IMAGE_NAME=${ECR_REPO} <br />

export ECR_REPO_URI=$(aws ecr describe-repositories --repository-name ${IMAGE_NAME}  | jq -r '.repositories[0].repositoryUri') <br />

if [ -z "$ECR_REPO_URI" ] <br />
then <br />
      echo "${IMAGE_REPO}/${IMAGE_NAME} does not exist. So creating it..." <br />
      ECR_REPO_URI=$(aws ecr create-repository \ <br />
        --repository-name $IMAGE_NAME\ <br />
        --region $AWS_REGION \ <br />
        --query 'repository.repositoryUri' \ <br />
        --output text)  <br />
      echo "ECR_REPO_URI=$ECR_REPO_URI" <br />
else <br />
      echo "${IMAGE_REPO}/${IMAGE_NAME} already exist..." <br />
fi <br />


