# FiftyOne Quickstart - Guia Completo

Este guia mostra como criar e usar o dataset quickstart do FiftyOne em sua configuração com microservices.

## 📦 Datasets Criados

### 1. Dataset Quickstart (Imagens)
- **Nome**: `quickstart`
- **Amostras**: 200 imagens
- **Campos**:
  - `ground_truth`: Anotações verdadeiras (detections)
  - `predictions`: Predições de modelo (detections)
  - `uniqueness`: Índice de singularidade visual (0-1)

### 2. Dataset Quickstart Video
- **Nome**: `quickstart-video`
- **Amostras**: 10 vídeos
- **Conteúdo**: Segmentos de vídeo com detecções densas

## 🛠️ Scripts Disponíveis

### 1. Script Simples (`quickstart_simple.py`)
```python
import fiftyone as fo
import fiftyone.zoo as foz

print("Carregando dataset quickstart...")
dataset = foz.load_zoo_dataset("quickstart")

print(f"Dataset criado: {dataset.name}")
print(f"Número de samples: {len(dataset)}")

# Tornar o dataset persistente
dataset.persistent = True

print("Datasets disponíveis:")
for name in fo.list_datasets():
    print(f"- {name}")

print("Dataset quickstart criado e disponível na aplicação web!")
```

**Como usar**:
```bash
/Users/ctw02228/.pyenv/versions/fiftyone-env/bin/python quickstart_simple.py
```

### 2. Script Completo (`create_quickstart_dataset.py`)
- Criação automática dos datasets quickstart e quickstart-video
- Verificação de datasets existentes
- Informações detalhadas sobre campos e estatísticas
- Interface interativa para escolher datasets

**Como usar**:
```bash
/Users/ctw02228/.pyenv/versions/fiftyone-env/bin/python create_quickstart_dataset.py
```

### 3. Script Quickstart Interativo (`run_quickstart.py`)
- Usa a função nativa `fo.quickstart()`
- Inicia automaticamente o FiftyOne App
- Exibe dicas e exemplos de exploração
- Mantém o servidor rodando

**Como usar**:
```bash
/Users/ctw02228/.pyenv/versions/fiftyone-env/bin/python run_quickstart.py
```

## 🌐 Acessando os Datasets

### Interface Web
1. **Frontend**: http://localhost:3000
2. **Backend API**: http://localhost:5151

### Python Programático
```python
import fiftyone as fo

# Carregar dataset
dataset = fo.load_dataset('quickstart')

# Iniciar app
session = fo.launch_app(dataset, port=5151, address='0.0.0.0', remote=True)

# Explorar dados
print(f"Total de amostras: {len(dataset)}")
print(f"Campos: {list(dataset.get_field_schema().keys())}")

# Filtrar por confiança
from fiftyone import ViewField as F
high_conf_view = dataset.filter_labels("predictions", F("confidence") > 0.8)
session.view = high_conf_view
```

## 🔍 Explorando o Dataset

### 1. Interface Web (http://localhost:3000)
- Clique em uma imagem para ver detalhes
- Use filtros na barra lateral
- Ordene por `uniqueness` para ver imagens únicas/comuns
- Filtre detecções por confiança

### 2. Operações Úteis

#### Filtrar por Confiança
```python
# Mostrar apenas predições com confiança > 80%
high_conf = dataset.filter_labels("predictions", F("confidence") > 0.8)
```

#### Ordenar por Singularidade
```python
# Imagens mais únicas primeiro
unique_view = dataset.sort_by("uniqueness", reverse=True)

# Imagens menos únicas primeiro  
common_view = dataset.sort_by("uniqueness", reverse=False)
```

#### Filtrar por Label
```python
# Apenas imagens com carros
cars_view = dataset.filter_labels("ground_truth", F("label") == "car")
```

#### Estatísticas do Dataset
```python
# Contar labels no ground truth
gt_counts = dataset.count_values("ground_truth.detections.label")
print(gt_counts)

# Contar labels nas predições
pred_counts = dataset.count_values("predictions.detections.label")
print(pred_counts)

# Estatísticas de confiança
conf_stats = dataset.stats("predictions.detections.confidence")
print(conf_stats)
```

## 📊 Informações dos Datasets

### Quickstart Dataset
```
Nome: quickstart
Amostras: 200 imagens
Labels GT: horse, cat, oven, snowboard, bottle, zebra, person, dog, etc.
Labels Pred: kite, cell phone, broccoli, fork, orange, person, car, etc.
Uniqueness: 0.0 - 1.0 (índice de singularidade visual)
```

### Quickstart Video Dataset
```
Nome: quickstart-video
Amostras: 10 vídeos
Conteúdo: Segmentos com detecções frame-by-frame
Formato: MP4 com anotações temporais
```

## 🐳 Integração com Docker

Os datasets funcionam perfeitamente com a configuração Docker:

```bash
# Iniciar containers
docker-compose up -d

# Executar script dentro do container backend
docker exec -it fiftyone-backend python /create_quickstart_dataset.py

# Ou usar Python local com MongoDB do container
/Users/ctw02228/.pyenv/versions/fiftyone-env/bin/python quickstart_simple.py
```

## 🎯 Casos de Uso

### 1. Exploração Visual
- Navegar pelo dataset via interface web
- Identificar padrões visuais
- Comparar ground truth vs predições

### 2. Análise de Modelo
- Avaliar performance de detecção
- Identificar falsos positivos/negativos
- Analisar distribuição de confiança

### 3. Curadoria de Dados
- Encontrar imagens únicas para treino
- Identificar duplicatas ou dados de baixa qualidade
- Selecionar subsets por critérios específicos

### 4. Prototipagem Rápida
- Testar pipelines de ML
- Validar conceitos de computer vision
- Demonstrar capacidades do FiftyOne

## 🔧 Troubleshooting

### Dataset não aparece na interface
```bash
# Verificar se o dataset existe
python -c "import fiftyone as fo; print(fo.list_datasets())"

# Recriar dataset
python create_quickstart_dataset.py
```

### Erro de conexão MongoDB
```bash
# Verificar containers
docker-compose ps

# Restart MongoDB
docker-compose restart mongodb
```

### Versão incompatível
```
Server version (1.7.2) does not match client version (1.8.0)
```
Isso é normal - o cliente Python (1.8.0) é compatível com servidor (1.7.2).

## 📚 Recursos Adicionais

- **Documentação**: https://docs.voxel51.com/
- **Dataset Zoo**: https://docs.voxel51.com/user_guide/dataset_zoo/
- **Tutoriais**: https://docs.voxel51.com/tutorials/
- **API Reference**: https://docs.voxel51.com/api/

## ✅ Resumo

Agora você tem:
1. ✅ Dataset quickstart criado (200 imagens)
2. ✅ Dataset quickstart-video criado (10 vídeos)
3. ✅ Scripts para criação automática
4. ✅ Interface web funcionando (http://localhost:3000)
5. ✅ Backend API ativo (http://localhost:5151)
6. ✅ Integração com Docker microservices
7. ✅ Exemplos de exploração e análise

**Próximos passos**: Explore os datasets na interface web e experimente os filtros e visualizações!
