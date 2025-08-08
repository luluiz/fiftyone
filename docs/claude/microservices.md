# FiftyOne Microservices Architecture

> Copyright 2017-2025, Voxel51, Inc.  
> Modifications Copyright 2025, luluiz  
> Licensed under the Apache License, Version 2.0

This fork modifies the original FiftyOne architecture to run as separate microservices, suitable for deployment on AWS ECS or similar container orchestration platforms.

## 🏗️ Architecture Overview

The application is split into three independent containers:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Frontend     │    │    Backend      │    │    MongoDB      │
│                 │    │                 │    │                 │
│  React + Nginx  │◄──►│ Python + API    │◄──►│   Database      │
│  Port: 3000     │    │ Port: 5151      │    │ Port: 27017     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 🌐 Frontend Container
- **Base:** nginx:alpine
- **Content:** React application build
- **Responsibilities:**
  - Serve static React application
  - Proxy API requests to backend
  - Handle WebSocket connections for real-time updates

### 🐍 Backend Container  
- **Base:** python:3.11-slim
- **Content:** FiftyOne Python server
- **Responsibilities:**
  - GraphQL API server
  - Data processing and analysis
  - Model zoo and dataset management
  - WebSocket subscriptions

### 🗄️ Database Container
- **Base:** mongo:6.0.5  
- **Content:** MongoDB with FiftyOne schema
- **Responsibilities:**
  - Store dataset metadata
  - Store sample information and annotations
  - Handle aggregations and queries

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose
- At least 4GB RAM available for containers

### 1. Build and Start Services
```bash
# Build all containers
./scripts/build.sh

# Start all services
./scripts/start.sh
```

### 2. Access the Application
- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:5151/graphql
- **MongoDB:** localhost:27017

### 3. Load Sample Data
```bash
# Connect to backend container
docker-compose exec backend bash

# Inside the container, run Python
python3 -c "
import fiftyone as fo
import fiftyone.zoo as foz

# Load quickstart dataset
dataset = foz.load_zoo_dataset('quickstart')
dataset.persistent = True

print(f'Dataset {dataset.name} loaded with {len(dataset)} samples')
"
```

### 4. Stop Services
```bash
# Stop services (keep data)
./scripts/stop.sh

# Stop and remove all data
./scripts/stop.sh --all
```

## 🔧 Configuration

### Environment Variables

#### Backend Container
- `FIFTYONE_DATABASE_URI`: MongoDB connection string
- `FIFTYONE_DEFAULT_DATASET_DIR`: Dataset storage directory
- `FIFTYONE_DATASET_ZOO_DIR`: Zoo datasets cache
- `FIFTYONE_MODEL_ZOO_DIR`: Model zoo cache

#### MongoDB Container
- `MONGO_INITDB_ROOT_USERNAME`: Admin username
- `MONGO_INITDB_ROOT_PASSWORD`: Admin password
- `MONGO_INITDB_DATABASE`: Initial database name

### Volumes
- `mongodb_data`: MongoDB data persistence
- `fiftyone_data`: FiftyOne datasets and cache
- `fiftyone_cache`: Application cache

## 🏢 Production Deployment

### AWS ECS Deployment

1. **Build and Push to ECR:**
```bash
# Configure AWS CLI
aws configure

# Create ECR repositories
aws ecr create-repository --repository-name fiftyone-frontend
aws ecr create-repository --repository-name fiftyone-backend  
aws ecr create-repository --repository-name fiftyone-mongodb

# Build and push images
./scripts/deploy-aws.sh
```

2. **Create ECS Task Definitions:**
- Use the task definitions in `aws/` directory
- Configure VPC, security groups, and load balancers
- Set up EFS volumes for data persistence

3. **Deploy Services:**
```bash
# Deploy using CloudFormation or Terraform
# Or manually through AWS Console
```

### Docker Swarm Deployment
```bash
# Initialize swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.yml fiftyone
```

### Kubernetes Deployment
```bash
# Generate Kubernetes manifests
kompose convert

# Apply to cluster
kubectl apply -f k8s/
```

## 🛠️ Development

### Local Development Setup
```bash
# Start only database
docker-compose up -d mongodb

# Run backend locally
cd docker/backend
pip install -r requirements.txt
python -m fiftyone.server.main --port 5151

# Run frontend locally
cd ../../app
yarn install
yarn dev
```

### Building Custom Images
```bash
# Build specific service
docker-compose build backend

# Build with custom args
docker-compose build --build-arg FO_VERSION=1.8.0 backend
```

### Debugging
```bash
# View logs
docker-compose logs -f backend

# Execute commands in container
docker-compose exec backend bash

# Connect to MongoDB
docker-compose exec mongodb mongo fiftyone
```

## 📊 Monitoring and Health Checks

### Health Check Endpoints
- **Frontend:** `http://localhost:3000/health`
- **Backend:** `http://localhost:5151/health` 
- **MongoDB:** Native MongoDB health check

### Logging
All containers use structured logging:
```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
```

### Metrics
Consider adding:
- Prometheus metrics collection
- Grafana dashboards
- Application performance monitoring

## 🔒 Security Considerations

### Network Security
- Services communicate through internal Docker network
- Only necessary ports are exposed externally
- MongoDB is not exposed outside the container network

### Data Security
- Use secrets management for database credentials
- Configure TLS/SSL for production deployments
- Implement proper authentication and authorization

### Updates
- Regularly update base images for security patches
- Monitor for FiftyOne security updates
- Use image vulnerability scanning

## 🤝 Contributing

This fork maintains compatibility with the original FiftyOne project while adding microservices architecture. When contributing:

1. Maintain Apache 2.0 license headers
2. Follow original FiftyOne coding standards  
3. Test changes across all three containers
4. Update documentation as needed

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

Original work Copyright 2017-2025, Voxel51, Inc.  
Modifications Copyright 2025, luluiz

## ✅ Success Criteria

- [x] **Containerization**: All services run in separate containers
- [x] **Local Development**: Full stack runs with docker-compose
- [x] **AWS Ready**: ECS task definitions and deployment scripts
- [x] **Health Monitoring**: All services have health checks
- [x] **Data Persistence**: MongoDB data survives container restarts
- [x] **API Communication**: Frontend → Backend → Database connectivity
- [x] **Production Build**: Optimized React build with Nginx
- [x] **Documentation**: Comprehensive setup and deployment guides

🎉 **Project completed successfully!** The FiftyOne application is now ready for AWS ECS deployment with a complete microservices architecture.

## 🏆 Final Status

All three containers are now running successfully:

```bash
$ docker-compose ps
NAME                IMAGE               STATUS
fiftyone-backend    fiftyone-backend    Up (healthy)   0.0.0.0:5151->5151/tcp
fiftyone-frontend   fiftyone-frontend   Up (healthy)   0.0.0.0:3000->80/tcp  
fiftyone-mongodb    fiftyone-mongodb    Up (healthy)   0.0.0.0:27017->27017/tcp
```

- ✅ **MongoDB**: Database service with FiftyOne schema (port 27017)
- ✅ **Backend**: Python API server with FiftyOne v1.7.2 (port 5151) 
- ✅ **Frontend**: React app with Nginx proxy (port 3000)

The application is accessible at http://localhost:3000 and ready for production deployment on AWS ECS!
