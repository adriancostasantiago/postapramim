import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/presentation/solicitacoes/providers/solicitacoes_providers.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';
import 'package:postapramim/presentation/widgets/filtro_solicitacoes.dart';
import 'package:postapramim/presentation/widgets/solicitacao_cards.dart';
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
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.preto),
        title: Text(
          'Solicitações',
          style: AppTextStyles.titulo.copyWith(color: AppColors.preto),
        ),
        backgroundColor: AppColors.branco,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Coletador pesquisa por código OU pelo nome do cliente.
            FiltroSolicitacoesBar(
              filtro: _filtro,
              onChanged: (f) => setState(() => _filtro = f),
              hintBusca: 'Pesquisar por código ou cliente',
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
                      .where((s) => _filtro.aceitaBusca(s, porCliente: true))
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
                      return ColetaCard(
                        solicitacao: s,
                        onTap: () => context.push(
                          RoutePaths.coletadorDetalheColeta.replaceFirst(
                            ':id',
                            s.id,
                          ),
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
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.branco,
        indicatorColor: AppColors.amarelo,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.legenda.copyWith(
              color: AppColors.amarelo,
              fontWeight: FontWeight.bold,
            );
          }

          return AppTextStyles.legenda.copyWith(color: AppColors.cinzaTexto);
        }),
        selectedIndex: 1,
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.push(RoutePaths.coletadorDashboard);
              break;
            // case 2:
            //   context.push(RoutePaths.coletadorMapaRota);
            //   break;
            case 2:
              context.push(RoutePaths.ajuda);
              break;
            case 3:
              context.push(RoutePaths.perfil);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: AppColors.cinzaTexto),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined, color: AppColors.branco),
            label: 'Solicitações',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.map_outlined, color: AppColors.cinzaTexto),
          //   label: 'Rotas',
          // ),
          NavigationDestination(
            icon: Icon(Icons.help_outline, color: AppColors.cinzaTexto),
            label: 'Ajuda',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: AppColors.cinzaTexto),
            label: 'Conta',
          ),
        ],
      ),
    );
  }
}
