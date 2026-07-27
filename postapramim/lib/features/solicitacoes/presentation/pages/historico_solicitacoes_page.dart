import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/utils/formatters.dart';
import 'package:postapramim/features/solicitacoes/presentation/providers/solicitacoes_providers.dart';
import 'package:postapramim/shared/widgets/app_card.dart';
import 'package:postapramim/shared/widgets/state_widgets.dart';

class HistoricoSolicitacoesPage extends ConsumerWidget {
  const HistoricoSolicitacoesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(minhasSolicitacoesRealtimeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas solicitações')),
      body: async.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) =>
            const ErrorState(mensagem: 'Erro ao carregar histórico'),
        data: (lista) {
          if (lista.isEmpty) {
            return const EmptyState(
              titulo: 'Nenhuma solicitação ainda',
              mensagem: 'Toque em "+" para solicitar sua primeira coleta.',
              icone: Icons.inventory_2_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = lista[index];
              return AppCard(
                onTap: () => context.push(
                  RoutePaths.clienteDetalheSolicitacao.replaceFirst(
                    ':id',
                    s.id,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.statusColor(s.status.valorBanco),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.descricaoItem ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            s.status.label,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.data(s.criadoEm),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.amarelo,
        onPressed: () => context.push(RoutePaths.clienteNovaSolicitacao),
        child: const Icon(Icons.add, color: AppColors.preto),
      ),
    );
  }
}
