import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/utils/formatters.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/presentation/solicitacoes/providers/solicitacoes_providers.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';
import 'package:postapramim/presentation/widgets/filtro_solicitacoes.dart';
import 'package:postapramim/shared/widgets/app_card.dart';
import 'package:postapramim/shared/widgets/state_widgets.dart';

class MinhasColetasPage extends ConsumerStatefulWidget {
  const MinhasColetasPage({super.key});

  @override
  ConsumerState<MinhasColetasPage> createState() => _MinhasColetasPageState();
}

class _MinhasColetasPageState extends ConsumerState<MinhasColetasPage> {
  FiltroSolicitacoes _filtro = const FiltroSolicitacoes();

  @override
  Widget build(BuildContext context) {
    final meuId = ref.watch(authControllerProvider).usuario?.id;
    final async = ref.watch(todasSolicitacoesRealtimeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas coletas')),
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
                    const ErrorState(mensagem: 'Erro ao carregar coletas'),
                data: (lista) {
                  final minhas = lista
                      .where((s) => s.coletadorId == meuId)
                      .where(
                        (s) =>
                            _filtro.aceita(s.criadoEm, s.status.grupoExibicao),
                      )
                      .toList();

                  if (minhas.isEmpty) {
                    return const EmptyState(
                      titulo: 'Nenhuma coleta encontrada',
                      mensagem:
                          'Aceite solicitações no Dashboard ou ajuste os filtros.',
                      icone: Icons.local_shipping_outlined,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: minhas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final s = minhas[index];
                      return AppCard(
                        onTap: () => context.push(
                          RoutePaths.coletadorDetalheColeta.replaceFirst(
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
    );
  }
}
