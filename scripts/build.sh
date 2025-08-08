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

echo "🚀 Building FiftyOne microservices..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Build function
build_service() {
    local service=$1
    echo -e "${YELLOW}Building $service...${NC}"
    
    if docker-compose build $service; then
        echo -e "${GREEN}✅ $service built successfully${NC}"
    else
        echo -e "${RED}❌ Failed to build $service${NC}"
        exit 1
    fi
}

# Build all services
echo "📦 Building MongoDB container..."
build_service mongodb

echo "🐍 Building Backend container..."
build_service backend

echo "⚛️ Building Frontend container..."
build_service frontend

echo -e "${GREEN}🎉 All containers built successfully!${NC}"
echo ""
echo "To start the services, run:"
echo "  docker-compose up -d"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f"
echo ""
echo "To access the application:"
echo "  Frontend: http://localhost:3000"
echo "  Backend API: http://localhost:5151"
echo "  MongoDB: localhost:27017"
