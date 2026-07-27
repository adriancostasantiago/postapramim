import 'package:flutter/material.dart';
import 'package:postapramim/shared/widgets/state_widgets.dart';

/// Lista alimentada por `coletasControllerProvider` (mesmo padrão de
/// solicitacoes_providers.dart: Datasource remoto/local -> Repository ->
/// UseCases -> Notifier), com cache em Hive (box `boxColetasDoDia`) para
/// uso offline durante a rota do dia.
class MinhasColetasPage extends StatelessWidget {
  const MinhasColetasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas coletas')),
      body: const EmptyState(
        titulo: 'Nenhuma coleta atribuída ainda',
        mensagem: 'Novas coletas aparecerão aqui automaticamente (Realtime).',
        icone: Icons.local_shipping_outlined,
      ),
    );
  }
}
