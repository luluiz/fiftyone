# Backend Documentation

FiftyOne's backend provides a robust Python-based foundation for computer vision dataset management and model inference.

## Core Components

### Dataset Management (`fiftyone.core.dataset`)

The core dataset management system provides:

- **Dataset**: Main container for collections of samples
- **Sample**: Individual data items (images, videos, etc.)
- **DatasetView**: Filtered/transformed views of datasets
- **Field**: Data schema definitions and validation

### Model Interface (`fiftyone.core.models`)

FiftyOne provides a unified model interface for various ML frameworks:

```python
# Apply model to dataset
dataset.apply_model(model, label_field="predictions")

# Compute embeddings
embeddings = dataset.compute_embeddings(model)
```

#### Model Types

1. **TorchImageModel**: PyTorch-based image models
2. **TorchVideoModel**: PyTorch-based video models  
3. **Custom Models**: User-defined model wrappers

#### Model Mixins

- **EmbeddingsMixin**: For models that generate embeddings
- **LogitsMixin**: For models that expose prediction logits
- **PromptMixin**: For models that accept text/visual prompts
- **SamplesMixin**: For models that need access to sample metadata

### Database Layer

FiftyOne uses MongoDB as its primary data store:

- **Collections**: Store dataset metadata and sample information
- **Indexing**: Optimized for fast queries and aggregations
- **Aggregation Pipeline**: Complex data transformations

### Server Components (`fiftyone.server`)

The server layer provides:

- **GraphQL API**: Primary interface for frontend communication
- **REST endpoints**: Additional API endpoints for specific operations
- **WebSocket support**: Real-time updates and streaming

## API Reference

### Core Dataset Operations

```python
import fiftyone as fo

# Create dataset
dataset = fo.Dataset("my_dataset")

# Add samples
sample = fo.Sample(filepath="image.jpg")
dataset.add_sample(sample)

# Apply filters
view = dataset.match({"metadata.width": {"$gt": 1920}})

# Aggregate data
counts = dataset.count_values("ground_truth.label")
```

### Model Zoo Integration

```python
import fiftyone.zoo as foz

# Load model from zoo
model = foz.load_zoo_model("yolov8n-coco-torch")

# Apply to dataset
dataset.apply_model(model, label_field="predictions")
```

### Label Types

FiftyOne supports various label types:

- **Classification**: Single or multi-class labels
- **Detection**: Bounding boxes with labels
- **Segmentation**: Pixel-level segmentation masks
- **Keypoints**: Pose estimation and landmark detection
- **Polylines**: Line and polygon annotations

### Field Schema

```python
# Define custom field schema
schema = fo.DatasetSchema()
schema.add_field("custom_field", fo.StringField)
dataset.add_schema(schema)
```

## Database Schema

### Collections Structure

1. **Datasets Collection**: Dataset metadata
2. **Samples Collection**: Sample documents with embedded labels
3. **Frames Collection**: Video frame data (for video datasets)

### Sample Document Structure

```json
{
  "_id": "sample_id",
  "filepath": "/path/to/image.jpg",
  "metadata": {
    "width": 1920,
    "height": 1080,
    "mime_type": "image/jpeg"
  },
  "ground_truth": {
    "_cls": "Detections",
    "detections": [
      {
        "_cls": "Detection",
        "label": "person",
        "confidence": 0.95,
        "bounding_box": [0.1, 0.2, 0.3, 0.4]
      }
    ]
  }
}
```

## Performance Optimization

### Indexing Strategy

- Compound indexes on frequently queried fields
- Sparse indexes for optional fields
- Text indexes for search functionality

### Caching

- MongoDB query result caching
- Model prediction caching
- Metadata computation caching

### Batch Processing

- Efficient batch model inference
- Parallelized data loading
- Optimized aggregation pipelines

## Error Handling

The backend implements comprehensive error handling:

- **Validation errors**: Schema and data validation
- **Model errors**: Inference failures and recovery
- **Database errors**: Connection and query issues
- **File system errors**: Missing or corrupted media files

## Extensibility

### Custom Operators

```python
import fiftyone.operators as foo

class CustomOperator(foo.Operator):
    def execute(self, ctx):
        # Custom operation logic
        pass
```

### Plugin System

- Custom panels for UI extensions
- Custom operators for dataset operations
- Custom model wrappers for new frameworks

### Integration Points

- **Model Zoo**: Add custom models to the zoo
- **Data Formats**: Support for custom import/export formats
- **Annotation Backends**: Custom annotation tool integrations
