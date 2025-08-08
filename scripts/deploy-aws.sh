#!/bin/bash
# Copyright 2017-2025, Voxel51, Inc.
# Modifications Copyright 2025, luluiz
# voxel51.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION=${AWS_REGION:-us-east-1}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}
ECR_REGISTRY=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
PROJECT_NAME="fiftyone"

echo -e "${BLUE}🚀 Deploying FiftyOne to AWS ECR...${NC}"
echo "📍 Region: $AWS_REGION"
echo "🆔 Account: $AWS_ACCOUNT_ID"
echo "📦 Registry: $ECR_REGISTRY"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found. Please install and configure AWS CLI first.${NC}"
    exit 1
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker not found. Please install Docker first.${NC}"
    exit 1
fi

# Login to ECR
echo -e "${YELLOW}🔐 Logging into ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Function to create ECR repository if it doesn't exist
create_ecr_repo() {
    local repo_name=$1
    echo -e "${YELLOW}📦 Checking ECR repository: $repo_name${NC}"
    
    if aws ecr describe-repositories --repository-names $repo_name --region $AWS_REGION >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Repository $repo_name already exists${NC}"
    else
        echo -e "${YELLOW}📦 Creating ECR repository: $repo_name${NC}"
        aws ecr create-repository --repository-name $repo_name --region $AWS_REGION
        echo -e "${GREEN}✅ Repository $repo_name created${NC}"
    fi
}

# Function to build and push image
build_and_push() {
    local service=$1
    local dockerfile_path=$2
    local context_path=${3:-.}
    
    local image_name="$PROJECT_NAME-$service"
    local local_tag="$image_name:latest"
    local remote_tag="$ECR_REGISTRY/$image_name:latest"
    
    echo -e "${YELLOW}🔨 Building $service...${NC}"
    
    # Build the image
    if [ "$service" = "frontend" ]; then
        docker build -f $dockerfile_path -t $local_tag $context_path
    else
        docker build -f $dockerfile_path -t $local_tag $context_path
    fi
    
    # Tag for ECR
    docker tag $local_tag $remote_tag
    
    # Push to ECR
    echo -e "${YELLOW}📤 Pushing $service to ECR...${NC}"
    docker push $remote_tag
    
    echo -e "${GREEN}✅ $service pushed successfully${NC}"
    echo "📍 Image URI: $remote_tag"
}

# Create ECR repositories
create_ecr_repo "$PROJECT_NAME-mongodb"
create_ecr_repo "$PROJECT_NAME-backend"
create_ecr_repo "$PROJECT_NAME-frontend"

# Build and push MongoDB
echo -e "${BLUE}🗄️ Building and pushing MongoDB...${NC}"
build_and_push "mongodb" "./docker/mongodb/Dockerfile" "./docker/mongodb"

# Build and push Backend
echo -e "${BLUE}🐍 Building and pushing Backend...${NC}"
build_and_push "backend" "./docker/backend/Dockerfile" "./docker/backend"

# Build and push Frontend
echo -e "${BLUE}⚛️ Building and pushing Frontend...${NC}"
build_and_push "frontend" "./docker/frontend/Dockerfile" "."

echo ""
echo -e "${GREEN}🎉 All images pushed successfully to ECR!${NC}"
echo ""
echo "📋 Image URIs:"
echo "  MongoDB:  $ECR_REGISTRY/$PROJECT_NAME-mongodb:latest"
echo "  Backend:  $ECR_REGISTRY/$PROJECT_NAME-backend:latest"
echo "  Frontend: $ECR_REGISTRY/$PROJECT_NAME-frontend:latest"
echo ""
echo "🚀 Next steps for ECS deployment:"
echo "  1. Update task definitions in aws/ directory with these image URIs"
echo "  2. Create ECS cluster, services, and load balancers"
echo "  3. Configure VPC, security groups, and networking"
echo "  4. Set up EFS volumes for data persistence"
echo "  5. Configure secrets manager for database credentials"
