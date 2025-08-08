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
