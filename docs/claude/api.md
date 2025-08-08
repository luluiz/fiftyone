# API Documentation

FiftyOne provides both REST and GraphQL APIs for interacting with datasets, models, and the application state.

## GraphQL API

The primary API interface uses GraphQL for efficient, type-safe data operations.

### Schema Overview

```graphql
type Query {
  dataset(name: String!): Dataset
  datasets: [Dataset!]!
  samples(first: Int, after: String): SampleConnection
  aggregations(pipeline: [AggregationStage!]!): AggregationResult
}

type Mutation {
  createDataset(input: CreateDatasetInput!): Dataset
  deleteDataset(name: String!): Boolean
  updateSample(input: UpdateSampleInput!): Sample
}

type Subscription {
  datasetUpdated(name: String!): Dataset
  samplesUpdated: SampleConnection
}
```

### Core Types

#### Dataset
```graphql
type Dataset {
  id: ID!
  name: String!
  persistent: Boolean!
  mediaType: MediaType!
  sampleCollection: SampleConnection
  defaultClasses: [String!]
  defaultMask: String
  info: JSON
  createdAt: DateTime!
  lastModified: DateTime!
}
```

#### Sample
```graphql
type Sample {
  id: ID!
  filepath: String!
  metadata: Metadata
  tags: [String!]
  labels: [Label!]
  frames: [Frame!]
}
```

#### Label Types
```graphql
interface Label {
  id: ID!
  confidence: Float
  tags: [String!]
}

type Classification implements Label {
  id: ID!
  confidence: Float
  tags: [String!]
  label: String!
}

type Detection implements Label {
  id: ID!
  confidence: Float
  tags: [String!]
  label: String!
  boundingBox: [Float!]!
}

type Segmentation implements Label {
  id: ID!
  confidence: Float
  tags: [String!]
  mask: String!
}
```

### Query Examples

#### Fetch Dataset with Samples
```graphql
query GetDataset($name: String!, $first: Int) {
  dataset(name: $name) {
    id
    name
    mediaType
    sampleCollection(first: $first) {
      edges {
        node {
          id
          filepath
          metadata {
            width
            height
          }
          labels {
            ... on Detection {
              label
              confidence
              boundingBox
            }
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
```

#### Create New Dataset
```graphql
mutation CreateDataset($input: CreateDatasetInput!) {
  createDataset(input: $input) {
    id
    name
    persistent
  }
}
```

#### Real-time Updates
```graphql
subscription DatasetUpdates($name: String!) {
  datasetUpdated(name: $name) {
    id
    name
    lastModified
    sampleCollection {
      totalCount
    }
  }
}
```

### Aggregation Pipeline

FiftyOne supports MongoDB-style aggregation pipelines through GraphQL:

```graphql
query Aggregations($pipeline: [AggregationStage!]!) {
  aggregations(pipeline: $pipeline) {
    data
    totalCount
  }
}
```

Example aggregation:
```json
[
  {
    "stage": "match",
    "expression": {
      "predictions.detections.confidence": {"$gte": 0.5}
    }
  },
  {
    "stage": "group",
    "expression": {
      "_id": "$predictions.detections.label",
      "count": {"$sum": 1}
    }
  }
]
```

## REST API

Additional REST endpoints for specific operations:

### Authentication

```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "user@example.com",
  "password": "password"
}
```

Response:
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "email": "user@example.com"
  }
}
```

### File Upload

```http
POST /api/samples/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

file: <binary_data>
dataset: dataset_name
metadata: {"width": 1920, "height": 1080}
```

### Model Inference

```http
POST /api/models/predict
Authorization: Bearer <token>
Content-Type: application/json

{
  "model_name": "yolov8n-coco-torch",
  "sample_ids": ["sample_1", "sample_2"],
  "confidence_threshold": 0.5
}
```

## Python SDK

The Python SDK provides a Pythonic interface to FiftyOne:

### Dataset Operations

```python
import fiftyone as fo

# Create dataset
dataset = fo.Dataset("my_dataset")

# Add samples
samples = [
    fo.Sample(filepath="image1.jpg"),
    fo.Sample(filepath="image2.jpg"),
]
dataset.add_samples(samples)

# Query samples
view = dataset.match({"metadata.width": {"$gt": 1920}})

# Apply model
model = fo.zoo.load_zoo_model("yolov8n-coco-torch")
dataset.apply_model(model, label_field="predictions")
```

### Label Creation

```python
# Classification
classification = fo.Classification(label="cat", confidence=0.95)

# Detection
detection = fo.Detection(
    label="person",
    bounding_box=[0.1, 0.2, 0.3, 0.4],
    confidence=0.85
)

# Segmentation
segmentation = fo.Segmentation(mask=mask_array)

# Add to sample
sample["ground_truth"] = fo.Detections(detections=[detection])
```

### Aggregations

```python
# Count values
counts = dataset.count_values("ground_truth.detections.label")

# Compute statistics
stats = dataset.bounds("metadata.width")

# Custom aggregation
pipeline = [
    {"$group": {"_id": "$ground_truth.detections.label", "count": {"$sum": 1}}}
]
results = dataset.aggregate(pipeline)
```

## Authentication & Authorization

### JWT Token Authentication

FiftyOne uses JWT tokens for API authentication:

```python
import requests

# Login
response = requests.post('/api/auth/login', {
    'username': 'user@example.com',
    'password': 'password'
})
token = response.json()['token']

# Use token in subsequent requests
headers = {'Authorization': f'Bearer {token}'}
```

### Role-Based Access Control

- **Admin**: Full access to all datasets and operations
- **User**: Access to assigned datasets
- **Viewer**: Read-only access

### Permissions

- `dataset:read`: View dataset contents
- `dataset:write`: Modify dataset and samples
- `dataset:delete`: Delete datasets
- `model:apply`: Apply models to datasets
- `annotation:edit`: Edit annotations

## Rate Limiting

API endpoints are rate-limited to prevent abuse:

- **GraphQL**: 1000 requests per hour per user
- **REST**: 100 requests per minute per IP
- **File Upload**: 10 uploads per minute per user

Rate limit headers:
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

## Error Handling

### GraphQL Errors

```json
{
  "errors": [
    {
      "message": "Dataset not found",
      "locations": [{"line": 2, "column": 3}],
      "path": ["dataset"],
      "extensions": {
        "code": "DATASET_NOT_FOUND",
        "dataset": "nonexistent_dataset"
      }
    }
  ]
}
```

### REST API Errors

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input parameters",
    "details": {
      "field": "confidence_threshold",
      "issue": "must be between 0 and 1"
    }
  }
}
```

## SDK Integration Examples

### Custom Model Integration

```python
import fiftyone as fo
from fiftyone.core.models import Model

class CustomModel(Model):
    def predict(self, image):
        # Custom prediction logic
        predictions = self._model.predict(image)
        return self._convert_predictions(predictions)

# Register and use
model = CustomModel(config)
dataset.apply_model(model, label_field="custom_predictions")
```

### Batch Processing

```python
# Process large datasets efficiently
with fo.ProgressBar() as pb:
    for batch in dataset.iter_samples(batch_size=32, progress=pb):
        # Process batch
        results = model.predict_batch(batch)
        # Update samples
        for sample, result in zip(batch, results):
            sample["predictions"] = result
            sample.save()
```

## WebSocket API

Real-time updates via WebSocket connections:

```javascript
const ws = new WebSocket('ws://localhost:5151/api/ws');

ws.onmessage = function(event) {
  const data = JSON.parse(event.data);
  if (data.type === 'dataset_updated') {
    // Handle dataset update
    refreshDataset(data.dataset);
  }
};

// Subscribe to updates
ws.send(JSON.stringify({
  type: 'subscribe',
  channel: 'dataset_updates',
  dataset: 'my_dataset'
}));
```
