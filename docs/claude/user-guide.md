# User Guide

A comprehensive guide for using FiftyOne to manage datasets and analyze models.

## Getting Started

### Basic Workflow

1. **Load or create a dataset**
2. **Explore your data**
3. **Apply models and analyze results**
4. **Curate and export refined datasets**

### Quick Example

```python
import fiftyone as fo
import fiftyone.zoo as foz

# Load a dataset
dataset = foz.load_zoo_dataset("quickstart")

# Load a model and apply it
model = foz.load_zoo_model("yolov8n-coco-torch")
dataset.apply_model(model, label_field="predictions")

# Launch the App
session = fo.launch_app(dataset)
```

## Dataset Management

### Creating Datasets

#### From Directory

```python
# Load images from directory
dataset = fo.Dataset.from_dir(
    dataset_dir="/path/to/images",
    dataset_type=fo.types.ImageDirectory,
    name="my_dataset"
)
```

#### From Existing Format

```python
# Load COCO dataset
dataset = fo.Dataset.from_dir(
    dataset_dir="/path/to/coco",
    dataset_type=fo.types.COCODetectionDataset,
    label_field="ground_truth"
)

# Load custom format
dataset = fo.Dataset.from_dir(
    dataset_dir="/path/to/data",
    dataset_type=fo.types.ImageClassificationDirectoryTree
)
```

#### Programmatically

```python
# Create empty dataset
dataset = fo.Dataset("my_dataset")

# Add samples
samples = []
for image_path in image_paths:
    sample = fo.Sample(filepath=image_path)
    # Add labels
    sample["ground_truth"] = fo.Classification(label="cat")
    samples.append(sample)

dataset.add_samples(samples)
```

### Dataset Operations

#### Basic Information

```python
# Dataset summary
print(dataset)
print(f"Number of samples: {len(dataset)}")
print(f"Media type: {dataset.media_type}")

# View schema
print(dataset.get_field_schema())

# Sample fields
print(dataset.get_field("ground_truth").description)
```

#### Adding Metadata

```python
# Compute metadata
dataset.compute_metadata()

# Custom metadata
for sample in dataset:
    sample.metadata["custom_field"] = "value"
    sample.save()
```

### Data Exploration

#### Basic Statistics

```python
# Count values
label_counts = dataset.count_values("ground_truth.label")
print(label_counts)

# Numeric statistics
width_stats = dataset.bounds("metadata.width")
print(f"Min width: {width_stats[0]}, Max width: {width_stats[1]}")

# Unique values
unique_labels = dataset.distinct("ground_truth.label")
print(f"Classes: {unique_labels}")
```

#### Visualizing Data

```python
# Launch App for visual exploration
session = fo.launch_app(dataset)

# Plot distributions
plot = dataset.histograms(
    ["metadata.width", "metadata.height"],
    bins=50
)
plot.show()
```

## Working with Views

Views are filtered or transformed representations of datasets that don't modify the original data.

### Creating Views

```python
# Filter by field value
cats = dataset.match({"ground_truth.label": "cat"})

# Filter by confidence
high_conf = dataset.filter_labels("predictions", fo.confidence > 0.9)

# Limit samples
subset = dataset.limit(100)

# Sort samples
sorted_view = dataset.sort_by("metadata.width", reverse=True)
```

### Combining Filters

```python
# Chain multiple operations
view = dataset.match({"metadata.width": {"$gt": 1000}}) \
              .filter_labels("predictions", fo.confidence > 0.8) \
              .limit(50)

# Complex matching
view = dataset.match({
    "$and": [
        {"metadata.width": {"$gt": 500}},
        {"ground_truth.label": {"$in": ["cat", "dog"]}}
    ]
})
```

### Advanced Filtering

```python
# Filter by label properties
detections_view = dataset.filter_labels(
    "ground_truth",
    fo.ViewField("bounding_box").length() == 4
)

# Filter by sample properties
large_images = dataset.match(
    fo.ViewField("metadata.width") * fo.ViewField("metadata.height") > 1000000
)

# Geo queries (for GPS data)
nearby = dataset.geo_near(
    "metadata.location",
    longitude=-73.9857,
    latitude=40.7484,
    max_distance=1000  # meters
)
```

## Model Integration

### Loading Models

#### Zoo Models

```python
# List available models
models = foz.list_zoo_models()
print(models)

# Load specific model
model = foz.load_zoo_model("yolov8n-coco-torch")

# Load with custom parameters
model = foz.load_zoo_model(
    "clip-vit-base32-torch",
    classes=["cat", "dog", "bird"]
)
```

#### Custom Models

```python
import fiftyone.utils.torch as fout

# Wrap PyTorch model
config = fout.TorchImageModelConfig({
    "entrypoint_fcn": "torchvision.models.resnet50",
    "entrypoint_args": {"weights": "ResNet50_Weights.DEFAULT"},
    "output_processor_cls": "fiftyone.utils.torch.ClassifierOutputProcessor",
    "labels_path": "/path/to/labels.txt"
})

model = fout.TorchImageModel(config)
```

### Applying Models

#### Basic Application

```python
# Apply model to entire dataset
dataset.apply_model(model, label_field="predictions")

# Apply to specific view
view = dataset.limit(100)
view.apply_model(model, label_field="predictions")

# With confidence threshold
dataset.apply_model(
    model,
    label_field="predictions",
    confidence_thresh=0.5
)
```

#### Batch Processing

```python
# Process in batches for efficiency
dataset.apply_model(
    model,
    label_field="predictions",
    batch_size=32,
    num_workers=4
)
```

#### Computing Embeddings

```python
# Generate embeddings
embeddings = dataset.compute_embeddings(model)
print(f"Embeddings shape: {embeddings.shape}")

# Store embeddings in dataset
dataset.compute_embeddings(
    model,
    embeddings_field="clip_embeddings"
)
```

### Model Evaluation

#### Classification Metrics

```python
# Evaluate classification results
results = dataset.evaluate_classifications(
    "predictions",
    gt_field="ground_truth",
    eval_key="eval"
)

# View results
print(results.report())
results.plot_confusion_matrix()
```

#### Detection Metrics

```python
# Evaluate detections
results = dataset.evaluate_detections(
    "predictions",
    gt_field="ground_truth",
    eval_key="eval"
)

# View mAP scores
print(f"mAP: {results.mAP()}")
print(f"mAP@50: {results.mAP(iou=0.5)}")

# Plot PR curves
results.plot_pr_curves()
```

## Data Annotation

### Manual Annotation

```python
# Launch annotation interface
dataset.annotate(
    "ground_truth",
    label_schema={
        "predictions": fo.Classification()
    }
)
```

### Using Annotation Tools

#### CVAT Integration

```python
# Configure CVAT backend
anno_key = "cvat_task"
dataset.annotate(
    anno_key,
    backend="cvat",
    url="http://localhost:8080",
    username="admin",
    password="password"
)
```

#### Label Studio Integration

```python
# Configure Label Studio
dataset.annotate(
    "labelstudio_task",
    backend="labelstudio",
    url="http://localhost:8080",
    api_key="your_api_key"
)
```

## Advanced Features

### Brain Methods

Brain methods provide AI-powered dataset insights.

#### Finding Similar Images

```python
# Compute image similarity
fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    brain_key="image_similarity"
)

# Find similar images
query_id = dataset.first().id
similar_view = dataset.sort_by_similarity(
    query_id,
    brain_key="image_similarity",
    k=10
)
```

#### Detecting Duplicates

```python
# Find duplicate images
fob.compute_similarity(
    dataset,
    model="clip-vit-base32-torch",
    brain_key="duplicates"
)

# Get duplicates
duplicates = dataset.find_duplicates(
    brain_key="duplicates",
    thresh=0.95
)
```

#### Finding Unique Samples

```python
# Find most unique samples
fob.compute_uniqueness(
    dataset,
    uniqueness_field="uniqueness"
)

# Sort by uniqueness
unique_view = dataset.sort_by("uniqueness", reverse=True)
```

### Data Curation

#### Active Learning

```python
# Find hard examples
fob.compute_hardness(
    dataset,
    "predictions",
    label_field="hardness"
)

# Select samples for annotation
hard_samples = dataset.sort_by("hardness", reverse=True).limit(100)
```

#### Class Balancing

```python
# Balance classes
balanced_view = dataset.take(50, seed=51).shuffle()

# Stratified sampling
stratified = fo.stratify(
    dataset,
    "ground_truth.label",
    max_samples=1000
)
```

### Export and Integration

#### Exporting Data

```python
# Export in various formats
dataset.export(
    export_dir="/path/to/export",
    dataset_type=fo.types.COCODetectionDataset,
    label_field="ground_truth"
)

# Export specific view
view.export(
    export_dir="/path/to/export",
    dataset_type=fo.types.ImageClassificationDirectoryTree
)
```

#### Integration with ML Frameworks

```python
# Convert to PyTorch dataset
torch_dataset = dataset.to_torch(
    transform=transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
    ])
)

# Convert to TensorFlow dataset
tf_dataset = dataset.to_tensorflow()
```

## Best Practices

### Performance Tips

1. **Use views instead of creating new datasets**
2. **Apply filters before expensive operations**
3. **Use batch processing for model inference**
4. **Index frequently queried fields**

```python
# Good: Filter first, then apply model
view = dataset.match({"metadata.width": {"$gt": 1000}})
view.apply_model(model)

# Avoid: Apply model to entire dataset unnecessarily
```

### Memory Management

```python
# For large datasets, use iterators
for sample in dataset.iter_samples(batch_size=100):
    # Process batch
    pass

# Clear unused datasets
fo.delete_dataset("unused_dataset")
```

### Data Organization

```python
# Use consistent naming
dataset.name = "project_v1_train"

# Tag samples for organization
for sample in validation_samples:
    sample.tags.append("validation")
    sample.save()

# Add dataset-level metadata
dataset.info = {
    "version": "1.0",
    "created_by": "team@company.com",
    "description": "Training data for model v1"
}
dataset.save()
```

## Troubleshooting

### Common Issues

1. **Memory errors**: Reduce batch size or use views
2. **Slow queries**: Add database indexes
3. **Import errors**: Check file paths and formats

### Performance Issues

```python
# Monitor progress
fo.config.show_progress_bars = True

# Check dataset size
print(f"Dataset size: {len(dataset)} samples")
print(f"Database size: {dataset.stats()}")

# Profile operations
import time
start = time.time()
result = dataset.count_values("ground_truth.label")
print(f"Operation took {time.time() - start:.2f} seconds")
```

### Getting Help

- **Documentation**: [Official docs](https://voxel51.com/docs/fiftyone)
- **Community**: [Discord channel](https://discord.gg/fiftyone-community)
- **GitHub**: [Issues and discussions](https://github.com/voxel51/fiftyone)
- **Examples**: [FiftyOne examples repository](https://github.com/voxel51/fiftyone-examples)
