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

FROM mongo:6.0.5

# MongoDB configuration for FiftyOne
ENV MONGO_INITDB_DATABASE=fiftyone
ENV MONGO_INITDB_ROOT_USERNAME=admin
ENV MONGO_INITDB_ROOT_PASSWORD=fiftyone123

# Create data directory
RUN mkdir -p /data/db

# Copy initialization script
COPY init-mongo.js /docker-entrypoint-initdb.d/

# Expose MongoDB port
EXPOSE 27017

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD mongosh --host localhost --port 27017 -u fiftyone_user -p fiftyone_password --authenticationDatabase fiftyone --eval "db.runCommand({ping: 1})" || exit 1

# Run MongoDB with bind to all interfaces
CMD ["mongod", "--bind_ip_all"]
