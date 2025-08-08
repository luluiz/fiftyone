# FiftyOne Docker Commands

## Como rodar o FiftyOne v1.7.2 com Docker

### 1. Build da Imagem Docker

```bash
# Build para versão 1.7.2 (servidor)
docker build -t fiftyone:1.7.2 \
  --build-arg BUILD_TYPE=released \
  --build-arg FO_VERSION=1.7.2 \
  --target server .

# Build para versão interativa (iPython)
docker build -t fiftyone:1.7.2-interactive \
  --build-arg BUILD_TYPE=released \
  --build-arg FO_VERSION=1.7.2 \
  --target interactive .
```

### 2. Executar o Container

```bash
# Criar diretório compartilhado (apenas uma vez)
mkdir -p ~/Documents/FiftyOne/shared

# Executar servidor FiftyOne (acesso via http://localhost:5151)
docker run \
  -v ~/Documents/FiftyOne/shared:/fiftyone \
  -p 5151:5151 \
  -it fiftyone:1.7.2

# Executar modo interativo (iPython)
docker run \
  -v ~/Documents/FiftyOne/shared:/fiftyone \
  -it fiftyone:1.7.2-interactive
```

### 3. Acessar a Aplicação

Após executar o comando acima, você pode acessar o FiftyOne através de:
- **URL:** http://localhost:5151
- **Frontend e Backend:** Completamente containerizados

### 4. Comandos Úteis

```bash
# Verificar containers em execução
docker ps

# Parar o container
docker stop <container_id>

# Ver logs do container
docker logs <container_id>

# Executar comandos dentro do container
docker exec -it <container_id> bash
```

### 5. Variáveis de Ambiente do Container

O container já está configurado com as seguintes variáveis:
- `FIFTYONE_DATABASE_DIR=/fiftyone/db`
- `FIFTYONE_DEFAULT_APP_ADDRESS=0.0.0.0`
- `FIFTYONE_DEFAULT_DATASET_DIR=/fiftyone/default`
- `FIFTYONE_DATASET_ZOO_DIR=/fiftyone/zoo/datasets`
- `FIFTYONE_MODEL_ZOO_DIR=/fiftyone/zoo/models`

### 6. Diretório Compartilhado

O diretório `~/Documents/FiftyOne/shared` no seu sistema será mapeado para `/fiftyone` no container, permitindo:
- Persistência de dados
- Acesso aos datasets
- Armazenamento do banco de dados
- Cache de modelos

### 7. Dockerfile Disponível

O projeto já inclui um Dockerfile configurado que suporta:
- Build a partir do código fonte (`BUILD_TYPE=source`)
- Build a partir de versões lançadas (`BUILD_TYPE=released`)
- Target para servidor (`--target server`)
- Target para modo interativo (`--target interactive`)
