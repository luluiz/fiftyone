#!/usr/bin/env python3
"""
Script para usar a funcionalidade quickstart nativa do FiftyOne.
Este script usa a função fo.quickstart() que automaticamente:
1. Carrega o dataset quickstart
2. Inicia uma sessão do FiftyOne App
3. Mostra dicas de como explorar o dataset
"""

import fiftyone as fo


def run_quickstart():
    """Execute FiftyOne quickstart with tips and instructions."""

    print("🚀 Executando FiftyOne Quickstart...")
    print("=" * 60)

    # Usar a função quickstart nativa do FiftyOne
    # Isso carrega o dataset e inicia o app automaticamente
    dataset, session = fo.quickstart(
        port=5151,  # Porta para o backend
        address="0.0.0.0",  # Aceitar conexões de qualquer IP
        remote=True,  # Não abrir browser automaticamente
    )

    print("\n" + "=" * 60)
    print("✅ FiftyOne Quickstart executado com sucesso!")
    print(f"📊 Dataset: {dataset.name}")
    print(f"📈 Amostras: {len(dataset)}")
    print(f"🌐 App Backend: http://localhost:5151")
    print(f"🖥️  App Frontend: http://localhost:3000")

    print("\n📋 Informações do Dataset:")
    print(f"   • Nome: {dataset.name}")
    print(f"   • Tipo de mídia: {dataset.media_type}")
    print(f"   • Total de amostras: {len(dataset)}")

    # Mostrar campos disponíveis
    schema = dataset.get_field_schema()
    print(f"\n🏷️  Campos disponíveis:")
    for field_name, field_type in schema.items():
        if field_name not in [
            "id",
            "filepath",
            "tags",
            "metadata",
            "created_at",
            "last_modified_at",
        ]:
            print(f"   • {field_name}: {field_type}")

    # Mostrar estatísticas básicas
    print(f"\n📊 Estatísticas:")
    if "ground_truth" in schema:
        gt_stats = dataset.count_values("ground_truth.detections.label")
        print(f"   • Labels ground truth: {list(gt_stats.keys())[:5]}...")

    if "predictions" in schema:
        pred_stats = dataset.count_values("predictions.detections.label")
        print(f"   • Labels predições: {list(pred_stats.keys())[:5]}...")

    print(f"\n💡 Como explorar o dataset:")
    print(f"   1. Acesse http://localhost:3000")
    print(f"   2. Clique em uma imagem para ver detalhes")
    print(f"   3. Use os filtros na barra lateral")
    print(f"   4. Ordene por 'uniqueness' para ver imagens únicas")
    print(f"   5. Filtre detecções por confiança > 0.8")

    print(f"\n🐍 Para usar no Python:")
    print(f"   import fiftyone as fo")
    print(f"   dataset = fo.load_dataset('quickstart')")
    print(f"   session = fo.launch_app(dataset)")

    return dataset, session


def show_dataset_samples():
    """Show some sample information from the dataset."""

    try:
        dataset = fo.load_dataset("quickstart")
        print(f"\n📸 Exemplo de amostra:")

        # Pegar uma amostra aleatória
        sample = dataset.take(1).first()
        print(f"   • Arquivo: {sample.filepath}")
        print(f"   • Uniqueness: {sample.uniqueness:.3f}")

        if sample.ground_truth:
            gt_labels = [det.label for det in sample.ground_truth.detections]
            print(f"   • Ground truth: {gt_labels[:3]}...")

        if sample.predictions:
            pred_labels = [
                f"{det.label}({det.confidence:.2f})"
                for det in sample.predictions.detections[:3]
            ]
            print(f"   • Predições: {pred_labels}...")

    except Exception as e:
        print(f"   Erro ao carregar amostra: {e}")


if __name__ == "__main__":
    try:
        # Executar quickstart
        dataset, session = run_quickstart()

        # Mostrar informações de amostra
        show_dataset_samples()

        print(f"\n🎉 FiftyOne está rodando!")
        print(f"   Frontend: http://localhost:3000")
        print(f"   Backend: http://localhost:5151")
        print(f"\n⚡ Pressione Ctrl+C para parar o servidor")

        # Manter o script rodando
        import time

        while True:
            time.sleep(1)

    except KeyboardInterrupt:
        print(f"\n\n🛑 Parando FiftyOne...")
        print(f"✅ Obrigado por usar FiftyOne!")
