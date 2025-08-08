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

# Multi-stage build for FiftyOne frontend
FROM node:18-alpine as builder

WORKDIR /app

# Copy package files
COPY app/package.json app/yarn.lock ./
COPY app/.yarnrc.yml ./

# Enable corepack and install dependencies
RUN corepack enable && yarn install --check-cache

# Copy source code
COPY app/ ./

# Build the application
WORKDIR /app/packages/app
RUN NODE_OPTIONS="--max-old-space-size=8192" yarn vite build

# Production stage with Nginx
FROM nginx:alpine

# Copy built assets from builder stage
COPY --from=builder /app/packages/app/dist /usr/share/nginx/html

# Copy custom Nginx configuration
COPY docker/frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
