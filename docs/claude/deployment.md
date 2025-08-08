# Deployment Guide

This guide covers various deployment options for FiftyOne in production environments.

## Installation Options

### Standard Installation

```bash
pip install fiftyone
```

### Development Installation

```bash
git clone https://github.com/voxel51/fiftyone.git
cd fiftyone
pip install -e .
```

### Docker Deployment

#### Basic Docker Setup

```dockerfile
FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install FiftyOne
RUN pip install fiftyone

# Create app directory
WORKDIR /app

# Copy application code
COPY . .

# Expose port
EXPOSE 5151

# Start FiftyOne
CMD ["python", "-c", "import fiftyone as fo; fo.launch_app(port=5151, address='0.0.0.0')"]
```

#### Docker Compose

```yaml
version: '3.8'

services:
  fiftyone:
    build: .
    ports:
      - "5151:5151"
    environment:
      - FIFTYONE_DATABASE_URI=mongodb://mongo:27017
      - FIFTYONE_DATABASE_NAME=fiftyone
    depends_on:
      - mongo
    volumes:
      - ./data:/data

  mongo:
    image: mongo:4.4
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

volumes:
  mongo_data:
```

### Kubernetes Deployment

#### Deployment Configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fiftyone-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fiftyone
  template:
    metadata:
      labels:
        app: fiftyone
    spec:
      containers:
      - name: fiftyone
        image: fiftyone:latest
        ports:
        - containerPort: 5151
        env:
        - name: FIFTYONE_DATABASE_URI
          value: "mongodb://mongo-service:27017"
        - name: FIFTYONE_DATABASE_NAME
          value: "fiftyone"
        resources:
          requests:
            memory: "2Gi"
            cpu: "500m"
          limits:
            memory: "4Gi"
            cpu: "1000m"
---
apiVersion: v1
kind: Service
metadata:
  name: fiftyone-service
spec:
  selector:
    app: fiftyone
  ports:
  - port: 80
    targetPort: 5151
  type: LoadBalancer
```

#### MongoDB StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongo
spec:
  serviceName: mongo-service
  replicas: 1
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      containers:
      - name: mongo
        image: mongo:4.4
        ports:
        - containerPort: 27017
        volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongo-persistent-storage
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 20Gi
```

## Configuration

### Environment Variables

```bash
# Database Configuration
FIFTYONE_DATABASE_URI=mongodb://localhost:27017
FIFTYONE_DATABASE_NAME=fiftyone

# App Configuration
FIFTYONE_APP_PORT=5151
FIFTYONE_APP_ADDRESS=localhost
FIFTYONE_APP_ALLOW_MEDIA_EXPORT=true

# Security
FIFTYONE_APP_SECRET_KEY=your-secret-key
FIFTYONE_APP_CSRF_PROTECT=true

# Performance
FIFTYONE_APP_MAX_SAMPLES=10000
FIFTYONE_SHOW_PROGRESS_BARS=true

# Storage
FIFTYONE_DEFAULT_DATASET_DIR=/data/datasets
FIFTYONE_MODEL_ZOO_DIR=/data/models
```

### Configuration File

Create `~/.fiftyone/config.json`:

```json
{
  "database_uri": "mongodb://localhost:27017",
  "database_name": "fiftyone",
  "default_app_port": 5151,
  "default_app_address": "localhost",
  "show_progress_bars": true,
  "desktop_app": false,
  "plugins_dir": "/path/to/plugins",
  "operators_dir": "/path/to/operators"
}
```

## Security Considerations

### Authentication

#### JWT-based Authentication

```python
import fiftyone as fo
from fiftyone.core.session import Session

# Configure authentication
fo.config.app_auth = True
fo.config.app_secret_key = "your-secret-key"

# Create authenticated session
session = Session(
    dataset=dataset,
    auth_required=True
)
```

#### OAuth Integration

```python
# OAuth configuration
fo.config.oauth_provider = "google"
fo.config.oauth_client_id = "your-client-id"
fo.config.oauth_client_secret = "your-client-secret"
```

### HTTPS Configuration

#### Nginx Reverse Proxy

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;

    location / {
        proxy_pass http://localhost:5151;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### Network Security

```bash
# Firewall configuration
ufw allow 22/tcp      # SSH
ufw allow 443/tcp     # HTTPS
ufw allow 27017/tcp   # MongoDB (internal only)
ufw enable
```

## Performance Optimization

### Database Optimization

#### MongoDB Configuration

```javascript
// MongoDB configuration
db.adminCommand({
  setParameter: 1,
  wiredTigerCacheSizeGB: 4
});

// Create indexes
db.samples.createIndex({"filepath": 1});
db.samples.createIndex({"metadata.width": 1});
db.samples.createIndex({"tags": 1});
```

#### Connection Pooling

```python
import fiftyone as fo

# Configure connection pool
fo.config.database_uri = "mongodb://localhost:27017/?maxPoolSize=50"
```

### Application Performance

#### Memory Management

```python
# Optimize memory usage
fo.config.max_samples_in_memory = 1000
fo.config.lazy_evaluation = True
```

#### Caching

```python
# Enable caching
fo.config.enable_caching = True
fo.config.cache_dir = "/tmp/fiftyone_cache"
```

### Load Balancing

#### Multiple App Instances

```python
# Run multiple app instances
instances = []
for port in range(5151, 5155):
    instance = fo.launch_app(
        dataset=dataset,
        port=port,
        remote=True
    )
    instances.append(instance)
```

#### HAProxy Configuration

```
global
    daemon

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend fiftyone_frontend
    bind *:80
    default_backend fiftyone_backend

backend fiftyone_backend
    balance roundrobin
    server app1 localhost:5151 check
    server app2 localhost:5152 check
    server app3 localhost:5153 check
```

## Monitoring and Logging

### Application Monitoring

```python
import logging
import fiftyone as fo

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/fiftyone.log'),
        logging.StreamHandler()
    ]
)

# Custom metrics
fo.config.enable_metrics = True
fo.config.metrics_endpoint = "http://prometheus:9090"
```

### Health Checks

```python
# Health check endpoint
@app.get("/health")
def health_check():
    try:
        # Check database connection
        fo.list_datasets()
        return {"status": "healthy"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}, 500
```

### Log Aggregation

#### ELK Stack Integration

```yaml
# Filebeat configuration
filebeat.inputs:
- type: log
  paths:
    - /var/log/fiftyone.log
  fields:
    service: fiftyone
    environment: production

output.elasticsearch:
  hosts: ["elasticsearch:9200"]
```

## Backup and Recovery

### Database Backup

```bash
# MongoDB backup
mongodump --host localhost:27017 --db fiftyone --out /backup/mongodb

# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mongodump --host localhost:27017 --db fiftyone --out /backup/mongodb_$DATE
tar -czf /backup/mongodb_$DATE.tar.gz /backup/mongodb_$DATE
rm -rf /backup/mongodb_$DATE
```

### Data Recovery

```bash
# Restore from backup
mongorestore --host localhost:27017 --db fiftyone /backup/mongodb/fiftyone
```

### Disaster Recovery

```python
# Export dataset metadata
import fiftyone as fo

dataset = fo.load_dataset("my_dataset")
dataset.export_metadata("/backup/dataset_metadata.json")

# Import dataset metadata
dataset = fo.Dataset.from_metadata("/backup/dataset_metadata.json")
```

## Scaling Considerations

### Horizontal Scaling

1. **Stateless Application Design**: Ensure app instances are stateless
2. **Shared Storage**: Use network-attached storage for datasets
3. **Database Clustering**: MongoDB replica sets for high availability

### Vertical Scaling

1. **Memory**: Increase RAM for larger datasets
2. **CPU**: More cores for faster processing
3. **Storage**: SSD storage for better I/O performance

### Auto-scaling

```yaml
# Kubernetes HPA
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: fiftyone-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: fiftyone-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Troubleshooting

### Common Issues

1. **Port conflicts**:
   ```bash
   lsof -i :5151
   kill -9 <PID>
   ```

2. **Database connection**:
   ```bash
   mongo --host localhost:27017
   ```

3. **Memory issues**:
   ```python
   # Reduce memory usage
   fo.config.max_samples_in_memory = 500
   ```

### Performance Issues

1. **Slow queries**: Add database indexes
2. **High memory usage**: Reduce batch sizes
3. **Network latency**: Use local data storage

### Log Analysis

```bash
# Check application logs
tail -f /var/log/fiftyone.log

# Filter errors
grep ERROR /var/log/fiftyone.log

# Monitor resource usage
htop
iostat -x 1
```
