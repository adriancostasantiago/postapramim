import 'package:flutter/material.dart';
import 'package:postapramim/shared/widgets/state_widgets.dart';

/// Alimentada por `notificacoesRealtimeProvider`, que observa a tabela
/// `notificacoes` filtrada por `usuario_id` (mesmo padrão Realtime usado
/// em solicitacoes_providers.dart), marcando como lida ao abrir.
class NotificacoesPage extends StatelessWidget {
  const NotificacoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: const EmptyState(
        titulo: 'Você está em dia!',
        mensagem: 'Nenhuma notificação nova por aqui.',
        icone: Icons.notifications_none_outlined,
      ),
    );
  }
}
