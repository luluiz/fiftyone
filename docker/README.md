# FiftyOne Microservices Docker Setup

Esta configuração separa o FiftyOne em 3 containers independentes, perfeito para deploy no AWS ECS.

## Arquitetura

- **MongoDB Container**: Banco de dados dedicado
- **Backend Container**: API Python do FiftyOne 
- **Frontend Container**: Interface React + Nginx

## Containers

### 1. MongoDB (fiftyone-mongodb)
- **Imagem**: MongoDB 6.0.5
- **Porta**: 27017
- **Usuário**: fiftyone_user
- **Senha**: fiftyone_password
- **Database**: fiftyone

### 2. Backend (fiftyone-backend)
- **Imagem**: Python 3.11 + FiftyOne 1.7.2
- **Porta**: 5151
- **Endpoints**: 
  - `/events` (POST)
  - `/graphql` (POST)
  - `/plugins`, `/operators`, `/spaces`, `/state`, etc.

### 3. Frontend (fiftyone-frontend)
- **Imagem**: Nginx + React build
- **Porta**: 3000
- **Proxy**: Roteia APIs para backend

## Como usar

### 1. Build e Start
```bash
# Build todos os containers
docker-compose build

# Iniciar todos os serviços
docker-compose up -d

# Verificar status
docker-compose ps
```

### 2. Verificar Health
```bash
# Todos devem estar "healthy"
docker-compose ps

# Logs individuais
docker-compose logs mongodb
docker-compose logs backend
docker-compose logs frontend
```

### 3. Acessar aplicação
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5151
- **MongoDB**: localhost:27017

### 4. Parar serviços
```bash
# Parar todos
docker-compose down

# Parar e remover volumes (CUIDADO: perde dados)
docker-compose down -v
```

### 5. Zerar banco de dados completamente
```bash
# Parar todos os containers
docker-compose stop

# Remover containers
docker-compose rm -f

# Remover volumes do MongoDB (perde todos os dados)
docker volume rm fiftyone_mongodb_data fiftyone_mongodb_config fiftyone_fiftyone_data fiftyone_fiftyone_cache

# Remover dados locais do FiftyOne
rm -rf ~/fiftyone ~/.fiftyone

# Recriar tudo do zero
docker-compose up -d
```

## Configuração para AWS ECS

### Task Definitions
Os arquivos de task definition estão em `aws/`:
- `mongodb-task-definition.json`
- `backend-task-definition.json` 
- `frontend-task-definition.json`

### Deploy Scripts
- `aws/deploy.sh` - Deploy completo
- `aws/update-service.sh` - Update de serviço específico

### Variáveis de Ambiente
Configurar no ECS:
```
FIFTYONE_DATABASE_URI=mongodb://fiftyone_user:fiftyone_password@mongodb:27017/fiftyone
FIFTYONE_DEFAULT_APP_PORT=5151
FIFTYONE_DEFAULT_APP_ADDRESS=0.0.0.0
```

## Monitoramento

### Health Checks
Todos os containers têm health checks configurados:
- **MongoDB**: `mongosh --eval "db.adminCommand('ping')"`
- **Backend**: `curl -f http://localhost:5151/graphql`
- **Frontend**: `curl -f http://localhost/`

### Logs
```bash
# Logs em tempo real
docker-compose logs -f

# Logs de um serviço específico
docker-compose logs -f backend
```

## Troubleshooting

### Backend não conecta no MongoDB
```bash
# Verificar se MongoDB está healthy
docker-compose ps mongodb

# Verificar logs do backend
docker-compose logs backend
```

### Frontend retorna 405 errors
```bash
# Verificar configuração nginx
docker exec fiftyone-frontend cat /etc/nginx/conf.d/default.conf

# Rebuild frontend
docker-compose build frontend
docker-compose up -d frontend
```

### Erro de permissão MongoDB
```bash
# Se aparecer erro "not authorized to execute command"
# Conectar como admin e dar permissões root ao fiftyone_user
docker exec fiftyone-mongodb mongosh fiftyone -u admin -p fiftyone123 --authenticationDatabase admin --eval "db.grantRolesToUser('fiftyone_user', [{role: 'root', db: 'admin'}])"

# Verificar permissões
docker exec fiftyone-mongodb mongosh fiftyone -u fiftyone_user -p fiftyone_password --eval "db.runCommand({connectionStatus: 1})"
```

### Erro de memória no build
```bash
# Aumentar memória do Docker Desktop
# Configurações > Resources > Memory: 8GB+
```

## Estrutura de Arquivos

```
docker/
├── mongodb/
│   ├── Dockerfile
│   └── init-mongo.js
├── backend/
│   ├── Dockerfile
│   └── entrypoint.sh
├── frontend/
│   ├── Dockerfile
│   └── nginx.conf
├── aws/
│   ├── mongodb-task-definition.json
│   ├── backend-task-definition.json
│   ├── frontend-task-definition.json
│   ├── deploy.sh
│   └── update-service.sh
├── docker-compose.yml
└── README.md
```

## Performance

### Recursos Mínimos
- **MongoDB**: 1 CPU, 2GB RAM
- **Backend**: 2 CPU, 4GB RAM  
- **Frontend**: 0.5 CPU, 512MB RAM

### Volumes Persistentes
- **MongoDB**: `/data/db` (dados do banco)
- **Backend**: Sem volumes (stateless)
- **Frontend**: Sem volumes (stateless)

## Segurança

### Rede
- Containers comunicam via rede interna `fiftyone-network`
- Apenas portas necessárias expostas

### Autenticação
- MongoDB com usuário/senha dedicado
- Backend conecta com credenciais específicas
- Frontend serve apenas arquivos estáticos

## Backup

### MongoDB
```bash
# Backup
docker exec fiftyone-mongodb mongodump --uri="mongodb://fiftyone_user:fiftyone_password@localhost:27017/fiftyone" --out=/backup

# Restore  
docker exec fiftyone-mongodb mongorestore --uri="mongodb://fiftyone_user:fiftyone_password@localhost:27017/fiftyone" /backup/fiftyone
```

## License

Apache 2.0 - Mesmo do projeto FiftyOne original
