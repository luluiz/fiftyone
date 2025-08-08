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

echo -e "${BLUE}🛑 Stopping FiftyOne microservices...${NC}"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ docker-compose not found.${NC}"
    exit 1
fi

# Parse command line arguments
REMOVE_VOLUMES=false
REMOVE_IMAGES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --volumes|-v)
            REMOVE_VOLUMES=true
            shift
            ;;
        --images|-i)
            REMOVE_IMAGES=true
            shift
            ;;
        --all|-a)
            REMOVE_VOLUMES=true
            REMOVE_IMAGES=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --volumes, -v    Remove volumes (data will be lost)"
            echo "  --images, -i     Remove built images"
            echo "  --all, -a        Remove everything (volumes + images)"
            echo "  --help, -h       Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Stop services
echo -e "${YELLOW}Stopping services...${NC}"
docker-compose down

if [ "$REMOVE_VOLUMES" = true ]; then
    echo -e "${YELLOW}Removing volumes (data will be lost)...${NC}"
    docker-compose down -v
    echo -e "${GREEN}✅ Volumes removed${NC}"
fi

if [ "$REMOVE_IMAGES" = true ]; then
    echo -e "${YELLOW}Removing built images...${NC}"
    docker-compose down --rmi local
    echo -e "${GREEN}✅ Images removed${NC}"
fi

echo -e "${GREEN}🏁 FiftyOne services stopped successfully!${NC}"

# Show remaining containers/volumes if any
echo ""
echo "📊 Remaining Docker resources:"
CONTAINERS=$(docker ps -a --filter "name=fiftyone" --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo "None")
VOLUMES=$(docker volume ls --filter "name=fiftyone" --format "table {{.Name}}" 2>/dev/null || echo "None")

echo "📦 Containers:"
echo "$CONTAINERS"
echo ""
echo "💾 Volumes:"
echo "$VOLUMES"
echo ""

if [ "$REMOVE_VOLUMES" = false ]; then
    echo -e "${BLUE}💡 Tip: Use --volumes to remove data volumes${NC}"
fi

if [ "$REMOVE_IMAGES" = false ]; then
    echo -e "${BLUE}💡 Tip: Use --images to remove built images${NC}"
fi

echo -e "${BLUE}💡 Tip: Use --all to remove everything${NC}"
