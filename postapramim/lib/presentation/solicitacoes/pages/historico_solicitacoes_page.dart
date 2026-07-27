import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';
import 'package:postapramim/core/utils/formatters.dart';
import 'package:postapramim/presentation/solicitacoes/providers/solicitacoes_providers.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';
import 'package:postapramim/presentation/widgets/filtro_solicitacoes.dart';
import 'package:postapramim/shared/widgets/app_card.dart';
import 'package:postapramim/shared/widgets/state_widgets.dart';

class HistoricoSolicitacoesPage extends ConsumerStatefulWidget {
  const HistoricoSolicitacoesPage({super.key});

  @override
  ConsumerState<HistoricoSolicitacoesPage> createState() =>
      _HistoricoSolicitacoesPageState();
}

class _HistoricoSolicitacoesPageState
    extends ConsumerState<HistoricoSolicitacoesPage> {
  FiltroSolicitacoes _filtro = const FiltroSolicitacoes();

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(minhasSolicitacoesRealtimeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas solicitações')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FiltroSolicitacoesBar(
              filtro: _filtro,
              onChanged: (f) => setState(() => _filtro = f),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: async.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) =>
                    const ErrorState(mensagem: 'Erro ao carregar histórico'),
                data: (lista) {
                  final filtrada = lista
                      .where(
                        (s) =>
                            _filtro.aceita(s.criadoEm, s.status.grupoExibicao),
                      )
                      .toList();

                  if (filtrada.isEmpty) {
                    return const EmptyState(
                      titulo: 'Nenhuma solicitação encontrada',
                      mensagem:
                          'Ajuste os filtros ou crie uma nova solicitação.',
                      icone: Icons.inventory_2_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filtrada.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final s = filtrada[index];
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
                                color: AppColors.statusColor(
                                  s.status.valorBanco,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.codigoDevolucao ??
                                        s.id.substring(0, 8).toUpperCase(),
                                    style: AppTextStyles.subtitulo.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    s.status.label,
                                    style: AppTextStyles.legenda.copyWith(
                                      color: AppColors.statusColor(
                                        s.status.valorBanco,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              Formatters.data(s.criadoEm),
                              style: AppTextStyles.legenda,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.amarelo,
        onPressed: () => context.push(RoutePaths.clienteNovaSolicitacao),
        child: const Icon(Icons.add, color: AppColors.preto),
      ),
    );
  }
}
