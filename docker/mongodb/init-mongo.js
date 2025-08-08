/*
 * Copyright 2017-2025, Voxel51, Inc.
 * Modifications Copyright 2025, luluiz
 * voxel51.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// MongoDB initialization script for FiftyOne
db = db.getSiblingDB('fiftyone');

// Create FiftyOne user with root privileges to avoid permission issues
db.createUser({
  user: 'fiftyone_user',
  pwd: 'fiftyone_password',
  roles: [
    {
      role: 'root',
      db: 'admin'
    }
  ]
});

print('FiftyOne user created successfully');

// Create indexes for better performance
print('Creating indexes...');

// Indexes for samples collection
db.samples.createIndex({ "filepath": 1 });
db.samples.createIndex({ "dataset_id": 1 });
db.samples.createIndex({ "created_at": 1 });
db.samples.createIndex({ "updated_at": 1 });

// Indexes for runs collection
db.runs.createIndex({ "dataset_id": 1, "key": 1 });
db.runs.createIndex({ "timestamp": 1 });

// Indexes for dataset metadata
db.datasets.createIndex({ "name": 1 }, { unique: true });
db.datasets.createIndex({ "created_at": 1 });

print('Indexes created successfully');
print('FiftyOne MongoDB initialization completed');
