# Integration Guide

This guide covers integrating FiftyOne with various tools, frameworks, and platforms.

## Machine Learning Frameworks

### PyTorch Integration

#### Custom Model Wrapper

```python
import torch
import fiftyone.utils.torch as fout

class CustomTorchModel(fout.TorchImageModel):
    def __init__(self, config):
        super().__init__(config)
        
    def _load_model(self, config):
        # Load your custom PyTorch model
        model = torch.load(config.model_path)
        model.eval()
        return model
    
    def _predict_all(self, imgs):
        # Batch prediction logic
        with torch.no_grad():
            predictions = self._model(imgs)
        return self._process_predictions(predictions)

# Use the model
config = fout.TorchImageModelConfig({
    "model_path": "/path/to/model.pth",
    "labels_path": "/path/to/labels.txt"
})
model = CustomTorchModel(config)
dataset.apply_model(model)
```

#### Dataset Conversion

```python
# Convert FiftyOne dataset to PyTorch
import torchvision.transforms as transforms

transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], 
                        std=[0.229, 0.224, 0.225])
])

torch_dataset = dataset.to_torch(
    transform=transform,
    target_transform=lambda x: x.label
)

# Use with DataLoader
from torch.utils.data import DataLoader
dataloader = DataLoader(torch_dataset, batch_size=32, shuffle=True)
```

### TensorFlow Integration

#### Custom Model Integration

```python
import tensorflow as tf
import fiftyone.utils.tensorflow as fout

class CustomTFModel(fout.TensorFlowImageModel):
    def _load_model(self, config):
        return tf.keras.models.load_model(config.model_path)
    
    def _predict_all(self, imgs):
        predictions = self._model.predict(imgs)
        return self._process_predictions(predictions)

# Convert to TensorFlow dataset
tf_dataset = dataset.to_tensorflow(
    preprocessing=lambda x: tf.image.resize(x, [224, 224])
)
```

### Scikit-learn Integration

```python
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from fiftyone.core.models import Model

class SklearnModel(Model):
    def __init__(self, model_path=None):
        self.model = RandomForestClassifier()
        if model_path:
            import joblib
            self.model = joblib.load(model_path)
    
    def predict(self, image):
        # Extract features from image
        features = self._extract_features(image)
        prediction = self.model.predict_proba([features])[0]
        
        # Convert to FiftyOne format
        return fo.Classification(
            label=self.classes[np.argmax(prediction)],
            confidence=np.max(prediction)
        )

# Use with FiftyOne
model = SklearnModel("/path/to/model.pkl")
dataset.apply_model(model)
```

## Model Serving Platforms

### MLflow Integration

```python
import mlflow
import mlflow.sklearn
from fiftyone.core.models import Model

class MLflowModel(Model):
    def __init__(self, model_uri):
        self.model = mlflow.sklearn.load_model(model_uri)
        
    def predict(self, image):
        # Preprocess image
        features = self._preprocess(image)
        
        # Get prediction
        prediction = self.model.predict_proba([features])[0]
        
        return fo.Classification(
            label=self.classes[np.argmax(prediction)],
            confidence=np.max(prediction)
        )

# Load model from MLflow
model_uri = "models:/my-model/production"
model = MLflowModel(model_uri)
dataset.apply_model(model)
```

### TensorFlow Serving

```python
import requests
import numpy as np

class TFServingModel(Model):
    def __init__(self, serving_url, model_name):
        self.serving_url = serving_url
        self.model_name = model_name
        
    def predict(self, image):
        # Preprocess image
        img_array = np.array(image).astype(np.float32)
        img_array = np.expand_dims(img_array, axis=0)
        
        # Prepare request
        data = {
            "signature_name": "serving_default",
            "instances": img_array.tolist()
        }
        
        # Send request
        url = f"{self.serving_url}/v1/models/{self.model_name}:predict"
        response = requests.post(url, json=data)
        predictions = response.json()["predictions"][0]
        
        # Convert to FiftyOne format
        return fo.Classification(
            label=self.classes[np.argmax(predictions)],
            confidence=np.max(predictions)
        )
```

### Triton Inference Server

```python
import tritonclient.http as httpclient

class TritonModel(Model):
    def __init__(self, server_url, model_name):
        self.client = httpclient.InferenceServerClient(server_url)
        self.model_name = model_name
        
    def predict(self, image):
        # Preprocess
        input_data = self._preprocess(image)
        
        # Create input object
        inputs = httpclient.InferInput("INPUT", input_data.shape, "FP32")
        inputs.set_data_from_numpy(input_data)
        
        # Create output object
        outputs = httpclient.InferRequestedOutput("OUTPUT")
        
        # Infer
        results = self.client.infer(
            self.model_name,
            inputs=[inputs],
            outputs=[outputs]
        )
        
        # Process results
        output_data = results.as_numpy("OUTPUT")
        return self._postprocess(output_data)
```

## Annotation Tools

### CVAT Integration

#### Setup and Configuration

```python
# Configure CVAT backend
cvat_config = {
    "url": "http://localhost:8080",
    "username": "admin", 
    "password": "password",
    "organization": "my_org"
}

# Create annotation task
anno_key = "cvat_annotation"
dataset.annotate(
    anno_key,
    backend="cvat",
    **cvat_config,
    label_schema={
        "detections": fo.Detections()
    }
)
```

#### Custom CVAT Workflow

```python
import fiftyone.utils.cvat as fouc

# Custom CVAT backend
class CustomCVATBackend(fouc.CVATBackend):
    def upload_annotations(self, samples, anno_key, **kwargs):
        # Custom upload logic
        api = self.connect_to_api()
        
        # Create project
        project = api.create_project(
            name=f"FiftyOne_{anno_key}",
            labels=self._get_labels_config()
        )
        
        # Upload samples
        task = api.create_task(
            project_id=project.id,
            samples=samples
        )
        
        return fouc.CVATAnnotationResults(
            backend=self,
            anno_key=anno_key,
            task_id=task.id
        )
```

### Label Studio Integration

```python
# Configure Label Studio
labelstudio_config = {
    "url": "http://localhost:8080",
    "api_key": "your_api_key"
}

# Create labeling interface config
label_config = '''
<View>
  <Image name="image" value="$image"/>
  <RectangleLabels name="label" toName="image">
    <Label value="Person" background="red"/>
    <Label value="Car" background="blue"/>
    <Label value="Bike" background="green"/>
  </RectangleLabels>
</View>
'''

# Start annotation
dataset.annotate(
    "labelstudio_task",
    backend="labelstudio",
    label_config=label_config,
    **labelstudio_config
)
```

### Labelbox Integration

```python
import fiftyone.utils.labelbox as foul

# Configure Labelbox
labelbox_config = {
    "api_key": "your_api_key",
    "project_name": "FiftyOne Annotation Project"
}

# Upload to Labelbox
dataset.annotate(
    "labelbox_task",
    backend="labelbox",
    **labelbox_config
)

# Download annotations
annotations = foul.download_annotations(
    api_key="your_api_key",
    project_id="project_id"
)
```

## Cloud Platforms

### AWS Integration

#### S3 Storage

```python
import boto3
import fiftyone as fo

class S3Dataset:
    def __init__(self, bucket_name, prefix=""):
        self.s3 = boto3.client('s3')
        self.bucket = bucket_name
        self.prefix = prefix
        
    def load_dataset(self):
        # List objects in S3
        objects = self.s3.list_objects_v2(
            Bucket=self.bucket,
            Prefix=self.prefix
        )
        
        # Create dataset
        dataset = fo.Dataset("s3_dataset")
        samples = []
        
        for obj in objects.get('Contents', []):
            if obj['Key'].endswith(('.jpg', '.jpeg', '.png')):
                # Create S3 URL
                url = f"s3://{self.bucket}/{obj['Key']}"
                sample = fo.Sample(filepath=url)
                samples.append(sample)
        
        dataset.add_samples(samples)
        return dataset

# Use S3 dataset
s3_loader = S3Dataset("my-bucket", "images/")
dataset = s3_loader.load_dataset()
```

#### SageMaker Integration

```python
import sagemaker
from sagemaker.pytorch import PyTorch

# Deploy model to SageMaker
class SageMakerModel(Model):
    def __init__(self, endpoint_name):
        self.predictor = sagemaker.predictor.Predictor(
            endpoint_name=endpoint_name
        )
        
    def predict(self, image):
        # Serialize image
        img_bytes = self._serialize_image(image)
        
        # Get prediction
        result = self.predictor.predict(img_bytes)
        
        # Convert to FiftyOne format
        return self._deserialize_prediction(result)

# Use SageMaker model
model = SageMakerModel("my-endpoint")
dataset.apply_model(model)
```

### Google Cloud Integration

#### Cloud Storage

```python
from google.cloud import storage
import fiftyone as fo

def load_from_gcs(bucket_name, prefix=""):
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    
    dataset = fo.Dataset("gcs_dataset")
    samples = []
    
    for blob in bucket.list_blobs(prefix=prefix):
        if blob.name.endswith(('.jpg', '.jpeg', '.png')):
            url = f"gs://{bucket_name}/{blob.name}"
            sample = fo.Sample(filepath=url)
            samples.append(sample)
    
    dataset.add_samples(samples)
    return dataset
```

#### Vertex AI Integration

```python
from google.cloud import aiplatform

class VertexAIModel(Model):
    def __init__(self, endpoint_id, project_id, location="us-central1"):
        aiplatform.init(project=project_id, location=location)
        self.endpoint = aiplatform.Endpoint(endpoint_id)
        
    def predict(self, image):
        # Prepare image data
        img_data = self._prepare_image(image)
        
        # Get prediction
        predictions = self.endpoint.predict(instances=[img_data])
        
        # Process results
        return self._process_vertex_predictions(predictions)
```

### Azure Integration

#### Blob Storage

```python
from azure.storage.blob import BlobServiceClient
import fiftyone as fo

def load_from_azure_blob(connection_string, container_name):
    blob_service = BlobServiceClient.from_connection_string(connection_string)
    container_client = blob_service.get_container_client(container_name)
    
    dataset = fo.Dataset("azure_dataset")
    samples = []
    
    for blob in container_client.list_blobs():
        if blob.name.endswith(('.jpg', '.jpeg', '.png')):
            url = f"https://{blob_service.account_name}.blob.core.windows.net/{container_name}/{blob.name}"
            sample = fo.Sample(filepath=url)
            samples.append(sample)
    
    dataset.add_samples(samples)
    return dataset
```

## Data Pipeline Integration

### Apache Airflow

```python
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
import fiftyone as fo

def process_dataset(**context):
    # Load dataset
    dataset = fo.load_dataset("raw_data")
    
    # Apply model
    model = fo.zoo.load_zoo_model("yolov8n-coco-torch")
    dataset.apply_model(model, label_field="predictions")
    
    # Export results
    dataset.export(
        export_dir="/data/processed",
        dataset_type=fo.types.COCODetectionDataset
    )

# Define DAG
dag = DAG(
    'fiftyone_pipeline',
    schedule_interval='@daily',
    start_date=datetime(2023, 1, 1)
)

# Add task
process_task = PythonOperator(
    task_id='process_dataset',
    python_callable=process_dataset,
    dag=dag
)
```

### Apache Beam

```python
import apache_beam as beam
import fiftyone as fo

class ProcessSamples(beam.DoFn):
    def setup(self):
        self.model = fo.zoo.load_zoo_model("yolov8n-coco-torch")
    
    def process(self, sample_data):
        # Create sample
        sample = fo.Sample(filepath=sample_data['filepath'])
        
        # Apply model
        img = fo.utils.image.read(sample_data['filepath'])
        predictions = self.model.predict(img)
        sample['predictions'] = predictions
        
        yield sample

# Use in Beam pipeline
with beam.Pipeline() as pipeline:
    (pipeline
     | 'Read Data' >> beam.io.ReadFromText('gs://bucket/manifest.txt')
     | 'Parse JSON' >> beam.Map(json.loads)
     | 'Process Samples' >> beam.ParDo(ProcessSamples())
     | 'Save Results' >> beam.io.WriteToText('gs://bucket/results'))
```

### Kubeflow Pipelines

```python
import kfp
from kfp import dsl

@dsl.component
def process_with_fiftyone(
    dataset_name: str,
    model_name: str,
    output_path: str
):
    import fiftyone as fo
    import fiftyone.zoo as foz
    
    # Load dataset
    dataset = fo.load_dataset(dataset_name)
    
    # Apply model
    model = foz.load_zoo_model(model_name)
    dataset.apply_model(model, label_field="predictions")
    
    # Export
    dataset.export(
        export_dir=output_path,
        dataset_type=fo.types.COCODetectionDataset
    )

@dsl.pipeline(name='fiftyone-pipeline')
def fiftyone_pipeline():
    process_task = process_with_fiftyone(
        dataset_name="my_dataset",
        model_name="yolov8n-coco-torch",
        output_path="/data/output"
    )
```

## MLOps Integration

### DVC (Data Version Control)

```python
import dvc.api
import fiftyone as fo

# Track dataset with DVC
def save_dataset_with_dvc(dataset, version_tag):
    # Export dataset
    export_dir = f"/data/datasets/{dataset.name}_{version_tag}"
    dataset.export(
        export_dir=export_dir,
        dataset_type=fo.types.FiftyOneDataset
    )
    
    # Add to DVC
    import subprocess
    subprocess.run(["dvc", "add", export_dir])
    subprocess.run(["git", "add", f"{export_dir}.dv"])
    subprocess.run(["git", "commit", "-m", f"Add dataset {version_tag}"])
    subprocess.run(["git", "tag", version_tag])

# Load dataset from DVC
def load_dataset_from_dvc(dataset_name, version_tag):
    with dvc.api.open(f"/data/datasets/{dataset_name}_{version_tag}") as f:
        dataset = fo.Dataset.from_archive(f.name)
    return dataset
```

### Weights & Biases

```python
import wandb
import fiftyone as fo

# Log dataset to W&B
def log_dataset_to_wandb(dataset, project_name):
    wandb.init(project=project_name)
    
    # Create W&B table
    table = wandb.Table(columns=["image", "ground_truth", "predictions"])
    
    for sample in dataset.limit(100):  # Log subset
        img = wandb.Image(sample.filepath)
        gt = sample.ground_truth.label if sample.ground_truth else "None"
        pred = sample.predictions.label if sample.predictions else "None"
        table.add_data(img, gt, pred)
    
    wandb.log({"dataset_samples": table})
    
    # Log metrics
    metrics = dataset.evaluate_classifications(
        "predictions",
        gt_field="ground_truth"
    )
    wandb.log({"accuracy": metrics.accuracy()})

# Use in training loop
def train_with_fiftyone_logging():
    dataset = fo.load_dataset("training_data")
    
    # Log initial dataset state
    log_dataset_to_wandb(dataset, "my_project")
    
    # Train model and log predictions
    for epoch in range(num_epochs):
        # Training code...
        
        # Apply model and log predictions
        if epoch % 5 == 0:
            dataset.apply_model(model, label_field=f"predictions_epoch_{epoch}")
            log_dataset_to_wandb(dataset, "my_project")
```

### MLflow Tracking

```python
import mlflow
import fiftyone as fo

def train_and_track_with_fiftyone():
    with mlflow.start_run():
        # Load dataset
        dataset = fo.load_dataset("training_data")
        
        # Log dataset info
        mlflow.log_param("dataset_size", len(dataset))
        mlflow.log_param("num_classes", len(dataset.distinct("ground_truth.label")))
        
        # Train model
        model = train_model(dataset)
        
        # Evaluate on test set
        test_dataset = fo.load_dataset("test_data")
        test_dataset.apply_model(model, label_field="predictions")
        
        # Compute metrics
        results = test_dataset.evaluate_classifications(
            "predictions",
            gt_field="ground_truth"
        )
        
        # Log metrics
        mlflow.log_metric("accuracy", results.accuracy())
        mlflow.log_metric("f1_score", results.f1())
        
        # Log model
        mlflow.sklearn.log_model(model, "model")
        
        # Export and log dataset
        export_dir = "test_results"
        test_dataset.export(export_dir, dataset_type=fo.types.COCODetectionDataset)
        mlflow.log_artifacts(export_dir)
```

## Monitoring and Observability

### Custom Metrics Integration

```python
from prometheus_client import Counter, Histogram, start_http_server
import fiftyone as fo

# Metrics
prediction_counter = Counter('fiftyone_predictions_total', 'Total predictions')
inference_time = Histogram('fiftyone_inference_seconds', 'Inference time')

class MonitoredModel(fo.Model):
    def predict(self, image):
        with inference_time.time():
            prediction = super().predict(image)
            prediction_counter.inc()
            return prediction

# Start metrics server
start_http_server(8000)
```

This comprehensive integration guide covers the major platforms and tools that FiftyOne can work with, enabling you to build robust ML pipelines and workflows.
