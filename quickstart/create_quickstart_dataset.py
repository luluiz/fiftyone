#!/usr/bin/env python3
"""
Script para criar o dataset quickstart do FiftyOne.
Este script baixa o dataset da Zoo e o torna disponível na aplicação web.
"""

import fiftyone as fo
import fiftyone.zoo as foz


def create_quickstart_dataset():
    """Cria o dataset quickstart do FiftyOne."""

    print("🚀 Iniciando criação do dataset quickstart...")
    print("=" * 50)

    # Verificar se o dataset já existe
    existing_datasets = fo.list_datasets()
    if "quickstart" in existing_datasets:
        print("⚠️  Dataset 'quickstart' já existe!")
        print("Removendo dataset existente para recriar...")
        fo.delete_dataset("quickstart")

    print("\n📥 Carregando dataset quickstart da FiftyOne Zoo...")
    print("   Isso pode levar alguns minutos na primeira vez...")

    try:
        # Carrega o dataset quickstart da Zoo
        dataset = foz.load_zoo_dataset("quickstart")

        print(f"✅ Dataset criado com sucesso!")
        print(f"   Nome: {dataset.name}")
        print(f"   Número de amostras: {len(dataset)}")
        print(f"   Tipo de mídia: {dataset.media_type}")

        # Tornar o dataset persistente
        dataset.persistent = True
        print("💾 Dataset marcado como persistente")

        # Mostrar informações sobre os campos
        print(f"\n📊 Campos disponíveis:")
        for field_name, field in dataset.get_field_schema().items():
            print(f"   - {field_name}: {field}")

        # Mostrar tags disponíveis
        if dataset.tags:
            print(f"\n🏷️  Tags disponíveis: {dataset.tags}")

        print("\n📁 Datasets disponíveis no banco:")
        for name in fo.list_datasets():
            dataset_info = fo.load_dataset(name)
            print(f"   - {name} ({len(dataset_info)} amostras)")

        print("\n" + "=" * 50)
        print("🎉 Dataset quickstart criado e disponível na aplicação web!")
        print("   Acesse: http://localhost:3000")
        print("   Para abrir no FiftyOne App: fo.launch_app(dataset)")

        return dataset

    except Exception as e:
        print(f"❌ Erro ao criar dataset: {str(e)}")
        print("   Verifique sua conexão com a internet e tente novamente.")
        return None


def create_video_quickstart_dataset():
    """Cria o dataset quickstart de vídeo do FiftyOne."""

    print("\n🎬 Criando dataset quickstart de vídeo...")

    # Verificar se o dataset já existe
    existing_datasets = fo.list_datasets()
    if "quickstart-video" in existing_datasets:
        print("⚠️  Dataset 'quickstart-video' já existe!")
        print("Removendo dataset existente para recriar...")
        fo.delete_dataset("quickstart-video")

    try:
        # Carrega o dataset quickstart de vídeo da Zoo
        video_dataset = foz.load_zoo_dataset("quickstart-video")

        print(f"✅ Dataset de vídeo criado com sucesso!")
        print(f"   Nome: {video_dataset.name}")
        print(f"   Número de amostras: {len(video_dataset)}")
        print(f"   Tipo de mídia: {video_dataset.media_type}")

        # Tornar o dataset persistente
        video_dataset.persistent = True
        print("💾 Dataset de vídeo marcado como persistente")

        return video_dataset

    except Exception as e:
        print(f"❌ Erro ao criar dataset de vídeo: {str(e)}")
        return None


if __name__ == "__main__":
    # Criar dataset de imagens
    dataset = create_quickstart_dataset()

    # Perguntar se o usuário quer criar o dataset de vídeo também
    if dataset:
        print("\n" + "=" * 50)
        response = (
            input("Deseja criar também o dataset quickstart de vídeo? (y/n): ")
            .lower()
            .strip()
        )
        if response in ["y", "yes", "s", "sim"]:
            video_dataset = create_video_quickstart_dataset()
            if video_dataset:
                print("\n🎉 Ambos os datasets foram criados com sucesso!")

        print("\n🚀 Para usar os datasets:")
        print("   import fiftyone as fo")
        print("   dataset = fo.load_dataset('quickstart')")
        print("   session = fo.launch_app(dataset)")
