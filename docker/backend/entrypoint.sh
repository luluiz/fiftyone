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

echo "Starting FiftyOne Backend..."

# Wait for MongoDB to be available
echo "Waiting for MongoDB connection..."
until python -c "
import pymongo
import time
import sys
try:
    client = pymongo.MongoClient('$FIFTYONE_DATABASE_URI', serverSelectionTimeoutMS=5000)
    client.server_info()
    print('MongoDB connected successfully!')
except Exception as e:
    print(f'MongoDB not ready yet: {e}')
    sys.exit(1)
"; do
  echo "MongoDB not ready, retrying in 5 seconds..."
  sleep 5
done

echo "MongoDB is ready! Starting FiftyOne server..."

# Execute the main command
exec "$@"
