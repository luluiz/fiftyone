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

echo -e "${BLUE}🚀 Starting FiftyOne microservices...${NC}"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ docker-compose not found. Please install docker-compose first.${NC}"
    exit 1
fi

# Start services
echo -e "${YELLOW}Starting services in detached mode...${NC}"
docker-compose up -d

# Wait a moment for services to start
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 10

# Check service health
echo -e "${YELLOW}Checking service health...${NC}"

check_service() {
    local service=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    echo -n "Checking $service... "
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s $url > /dev/null 2>&1; then
            echo -e "${GREEN}✅ healthy${NC}"
            return 0
        fi
        
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ unhealthy${NC}"
    return 1
}

# Check MongoDB
if docker-compose exec -T mongodb mongo --eval "db.adminCommand('ismaster')" > /dev/null 2>&1; then
    echo -e "MongoDB... ${GREEN}✅ healthy${NC}"
else
    echo -e "MongoDB... ${RED}❌ unhealthy${NC}"
fi

# Check Backend
check_service "Backend" "http://localhost:5151/graphql" || true

# Check Frontend
check_service "Frontend" "http://localhost:3000/health" || true

echo ""
echo -e "${GREEN}🎉 FiftyOne is running!${NC}"
echo ""
echo "📱 Access points:"
echo "  🌐 Frontend:  http://localhost:3000"
echo "  🔗 Backend:   http://localhost:5151"
echo "  🗄️  MongoDB:   localhost:27017"
echo ""
echo "📊 Useful commands:"
echo "  📋 View logs:        docker-compose logs -f"
echo "  📋 View logs (service): docker-compose logs -f [mongodb|backend|frontend]"
echo "  ⏹️  Stop services:    docker-compose down"
echo "  🔄 Restart:          docker-compose restart"
echo "  📊 Status:           docker-compose ps"
echo ""
echo "🎯 Quick start:"
echo "  1. Open http://localhost:3000 in your browser"
echo "  2. Load a dataset using the Python API or web interface"
echo "  3. Explore your data!"
