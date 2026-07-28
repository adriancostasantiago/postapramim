import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/presentation/solicitacoes/providers/solicitacoes_providers.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';
import 'package:postapramim/presentation/widgets/campo_busca.dart';
import 'package:postapramim/presentation/widgets/solicitacao_cards.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:postapramim/shared/widgets/app_drawer.dart';

/// Painel principal do coletador.
class ColetadorDashboardPage extends ConsumerStatefulWidget {
  const ColetadorDashboardPage({super.key});

  @override
  ConsumerState<ColetadorDashboardPage> createState() =>
      _ColetadorDashboardPageState();
}

class _ColetadorDashboardPageState
    extends ConsumerState<ColetadorDashboardPage> {
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(authControllerProvider).usuario;
    final primeiroNome = (usuario?.nome ?? '').split(' ').first;
    final solicitacoesAsync = ref.watch(todasSolicitacoesRealtimeProvider);
    final hoje = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.amareloClaro,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: solicitacoesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erro, _) => _ErroCarregamento(
            onTentarNovamente: () =>
                ref.invalidate(todasSolicitacoesRealtimeProvider),
          ),
          data: (solicitacoes) {
            final resumo = _ResumoColetas.deLista(solicitacoes);

            // Coletador pesquisa por código OU pelo nome do cliente.
            final termo = _busca.trim().toLowerCase();
            final proximas = solicitacoes
                .where((s) {
                  if (termo.isEmpty) return true;
                  final codigo = (s.codigoDevolucao ?? s.id.substring(0, 8))
                      .toLowerCase();
                  return codigo.contains(termo) ||
                      s.nomeExibicao.toLowerCase().contains(termo);
                })
                .take(10)
                .toList();

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _Cabecalho(nome: primeiroNome),
                Container(
                  color: AppColors.branco,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ResumoDoDiaCard(resumo: resumo, data: hoje),
                        // const SizedBox(height: 20),
                        // _AcoesRapidas(
                        //   onVerRotas: () =>
                        //       context.push(RoutePaths.coletadorMapaRota),
                        //   onEscanear: () =>
                        //       context.push(RoutePaths.coletadorScanner),
                        //   onNovaColeta: () =>
                        //       context.push(RoutePaths.coletadorScanner),
                        //   onContatoSuporte: _ligarSuporte,
                        // ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Solicitações',
                              style: AppTextStyles.subtitulo.copyWith(
                                fontSize: 17,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(
                                RoutePaths.coletadorMinhasColetas,
                              ),
                              child: Text(
                                'Ver todas',
                                style: AppTextStyles.corpo.copyWith(
                                  color: AppColors.azulInstitucional,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CampoBusca(
                          hint: 'Pesquisar por código ou cliente',
                          onChanged: (v) => setState(() => _busca = v),
                        ),
                        const SizedBox(height: 12),
                        if (proximas.isEmpty)
                          const _ListaVazia()
                        else
                          for (final s in proximas) ...[
                            ColetaCard(
                              solicitacao: s,
                              onTap: () => context.push(
                                RoutePaths.coletadorDetalheColeta.replaceFirst(
                                  ':id',
                                  s.id,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        const SizedBox(height: 8),
                        const _DicaDoDia(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.branco,
        indicatorColor: AppColors.darkFundo,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.legenda.copyWith(
              color: AppColors.darkFundo,
              fontWeight: FontWeight.bold,
            );
          }

          return AppTextStyles.legenda.copyWith(color: AppColors.darkFundo);
        }),
        selectedIndex: 0,
        onDestinationSelected: (i) {
          switch (i) {
            case 1:
              context.push(RoutePaths.coletadorMinhasColetas);
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
            icon: Icon(Icons.home_outlined, color: AppColors.branco),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined, color: AppColors.cinzaTexto),
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

Future<void> _ligarSuporte() async {
  final uri = Uri.parse('tel:+5575992873792');
  if (!await launchUrl(uri)) {
    throw Exception('Não foi possível iniciar a ligação.');
  }
}

class _Cabecalho extends StatelessWidget {
  final String nome;
  const _Cabecalho({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.amareloClaro, AppColors.branco],
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 0,
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/ilustracao_nova_solicitacao.png',
              height: 200,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.darkFundo),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  Row(
                    children: [
                      Badge(
                        label: const Text('2'),
                        backgroundColor: AppColors.amarelo,
                        textColor: AppColors.preto,
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.darkFundo,
                          ),
                          onPressed: () =>
                              context.push(RoutePaths.notificacoes),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.account_circle_outlined,
                          color: AppColors.darkFundo,
                        ),
                        onPressed: () => context.push(RoutePaths.perfil),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Image.asset('assets/images/logo.png', height: 46),
              const SizedBox(height: 16),
              Text(
                'Olá, ${nome.isEmpty ? 'coletador' : nome}! 👋',
                style: AppTextStyles.titulo.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pronto para mais coletas hoje?',
                style: AppTextStyles.corpo.copyWith(
                  color: AppColors.cinzaTexto,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErroCarregamento extends StatelessWidget {
  final VoidCallback onTentarNovamente;
  const _ErroCarregamento({required this.onTentarNovamente});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.erro),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar as solicitações.',
              textAlign: TextAlign.center,
              style: AppTextStyles.corpo,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onTentarNovamente,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaVazia extends StatelessWidget {
  const _ListaVazia();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cinzaBorda),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 36,
            color: AppColors.cinzaBorda,
          ),
          const SizedBox(height: 8),
          Text('Nenhuma solicitação no momento', style: AppTextStyles.legenda),
        ],
      ),
    );
  }
}

class _ResumoColetas {
  final int realizadas;
  final int agendadas;
  final int emAndamento;
  final int concluidas;
  final int canceladas;

  const _ResumoColetas({
    required this.realizadas,
    required this.agendadas,
    required this.emAndamento,
    required this.concluidas,
    required this.canceladas,
  });

  factory _ResumoColetas.deLista(List<SolicitacaoEntity> lista) {
    var realizadas = 0;
    var agendadas = 0;
    var emAndamento = 0;
    var concluidas = 0;
    var canceladas = 0;
    for (final s in lista) {
      switch (s.status.grupoExibicao) {
        case GrupoStatusExibicao.realizada:
          realizadas++;
          break;
        case GrupoStatusExibicao.coleta:
          agendadas++;
          break;
        case GrupoStatusExibicao.emtransito:
          emAndamento++;
          break;
        case GrupoStatusExibicao.concluida:
          concluidas++;
          break;
        case GrupoStatusExibicao.cancelada:
          canceladas++;
          break;
      }
    }
    return _ResumoColetas(
      realizadas: realizadas,
      agendadas: agendadas,
      emAndamento: emAndamento,
      concluidas: concluidas,
      canceladas: canceladas,
    );
  }
}

// class _ResumoDoDiaCard extends StatelessWidget {
//   final _ResumoColetas resumo;
//   final DateTime data;

//   const _ResumoDoDiaCard({required this.resumo, required this.data});

//   String _formatarData(DateTime d) {
//     const meses = [
//       'janeiro',
//       'fevereiro',
//       'março',
//       'abril',
//       'maio',
//       'junho',
//       'julho',
//       'agosto',
//       'setembro',
//       'outubro',
//       'novembro',
//       'dezembro',
//     ];
//     return '${d.day.toString().padLeft(2, '0')} de ${meses[d.month - 1]}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.branco,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: AppColors.cinzaBorda),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Resumo do dia',
//                 style: AppTextStyles.subtitulo.copyWith(fontSize: 16),
//               ),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.calendar_today,
//                     size: 14,
//                     color: AppColors.cinzaTexto,
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     'Hoje, ${_formatarData(data)}',
//                     style: AppTextStyles.legenda.copyWith(fontSize: 12),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 SizedBox(
//                   width: 200,
//                   child: _ResumoItem(
//                     valor: resumo.agendadas,
//                     label: 'Aguardando',
//                     linkLabel: 'Ver agenda',
//                     imagePath: 'assets/icons/icone_solicitar_sem_cadastro.png',
//                     icone: Icons.inventory_2_outlined,
//                     cor: AppColors.alerta,
//                     onTap: () =>
//                         context.push(RoutePaths.coletadorMinhasColetas),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 SizedBox(
//                   width: 120,
//                   child: _ResumoItem(
//                     valor: resumo.emAndamento,
//                     label: 'Em trânsito',
//                     linkLabel: 'Ver rotas',
//                     imagePath: 'assets/icons/em_transito.png',
//                     icone: Icons.local_shipping_outlined,
//                     cor: AppColors.azulInstitucional,
//                     onTap: () => context.push(RoutePaths.coletadorMapaRota),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 SizedBox(
//                   width: 120,
//                   child: _ResumoItem(
//                     valor: resumo.concluidas,
//                     label: 'Concluídas',
//                     linkLabel: 'Ver concluídas',
//                     imagePath: 'assets/icons/concluida.png',
//                     icone: Icons.check_circle_outline,
//                     cor: AppColors.sucesso,
//                     onTap: () =>
//                         context.push(RoutePaths.coletadorMinhasColetas),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 SizedBox(
//                   width: 100,
//                   child: _ResumoItem(
//                     valor: resumo.canceladas,
//                     label: 'Canceladas',
//                     linkLabel: 'Ver detalhes',
//                     imagePath: 'assets/icons/cancelada.png',
//                     icone: Icons.cancel_outlined,
//                     cor: AppColors.erro,
//                     onTap: () =>
//                         context.push(RoutePaths.coletadorMinhasColetas),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _ResumoDoDiaCard extends StatelessWidget {
  final _ResumoColetas resumo;
  final DateTime data;

  const _ResumoDoDiaCard({required this.resumo, required this.data});

  String _formatarData(DateTime d) {
    const meses = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    return '${d.day.toString().padLeft(2, '0')} de ${meses[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cinzaBorda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resumo do dia',
                style: AppTextStyles.subtitulo.copyWith(fontSize: 16),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.cinzaTexto,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Hoje, ${_formatarData(data)}',
                    style: AppTextStyles.legenda.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          _ResumoItem(
            valor: resumo.realizadas,
            label: 'Realizadas',
            linkLabel: 'Ver agenda',
            imagePath: 'assets/icons/novo.png',
            icone: Icons.inventory_2_outlined,
            cor: AppColors.amarelo,
            onTap: () => context.push(RoutePaths.coletadorMinhasColetas),
          ),
          const SizedBox(height: 4),
          _ResumoItem(
            valor: resumo.agendadas,
            label: 'Em coleta',
            linkLabel: 'Ver agenda',
            imagePath: 'assets/icons/caixa.png',
            icone: Icons.inventory_2_outlined,
            cor: AppColors.marron,
            onTap: () => context.push(RoutePaths.coletadorMinhasColetas),
          ),
          const SizedBox(height: 4),
          _ResumoItem(
            valor: resumo.emAndamento,
            label: 'Em trânsito',
            linkLabel: 'Ver rotas',
            imagePath: 'assets/icons/caminhao-de-carga.png',
            icone: Icons.local_shipping_outlined,
            cor: AppColors.azulInstitucional,
            onTap: () => context.push(RoutePaths.coletadorMapaRota),
          ),
          const SizedBox(height: 4),
          _ResumoItem(
            valor: resumo.concluidas,
            label: 'Concluídas',
            linkLabel: 'Ver concluídas',
            imagePath: 'assets/icons/verificar.png',
            icone: Icons.check_circle_outline,
            cor: AppColors.sucesso,
            onTap: () => context.push(RoutePaths.coletadorMinhasColetas),
          ),
          const SizedBox(height: 4),
          _ResumoItem(
            valor: resumo.canceladas,
            label: 'Canceladas',
            linkLabel: 'Ver detalhes',
            imagePath: 'assets/icons/cancelar.png',
            icone: Icons.cancel_outlined,
            cor: AppColors.erro,
            onTap: () => context.push(RoutePaths.coletadorMinhasColetas),
          ),
        ],
      ),
    );
  }
}

class _ResumoItem extends StatelessWidget {
  final int valor;
  final String label;
  final String linkLabel;

  final String imagePath;
  final IconData icone;
  final Color cor;
  final VoidCallback onTap;

  const _ResumoItem({
    required this.valor,
    required this.label,
    required this.linkLabel,
    required this.imagePath,
    required this.icone,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.contain),
          // Spacer(),
          SizedBox(width: 10),
          Text(
            '$valor',
            style: AppTextStyles.titulo.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.legenda.copyWith(fontSize: 11)),
          SizedBox(width: 10),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Ver',
                    style: AppTextStyles.legenda.copyWith(
                      fontSize: 11,
                      color: cor,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right, size: 14, color: cor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcoesRapidas extends StatelessWidget {
  final VoidCallback onVerRotas;
  final VoidCallback onEscanear;
  final VoidCallback onNovaColeta;
  final VoidCallback onContatoSuporte;

  const _AcoesRapidas({
    required this.onVerRotas,
    required this.onEscanear,
    required this.onNovaColeta,
    required this.onContatoSuporte,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cinzaBorda),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _AcaoRapidaItem(
            icone: Icons.map_outlined,
            label: 'Ver rotas\ndo dia',
            onTap: onVerRotas,
          ),
          _AcaoRapidaItem(
            icone: Icons.qr_code_scanner,
            label: 'Escanear\ncódigo',
            onTap: onEscanear,
          ),
          _AcaoRapidaItem(
            icone: Icons.inventory_2_outlined,
            label: 'Nova coleta\nrápida',
            onTap: onNovaColeta,
          ),
          _AcaoRapidaItem(
            icone: Icons.call_outlined,
            label: 'Contato\nsuporte',
            onTap: onContatoSuporte,
          ),
        ],
      ),
    );
  }
}

class _AcaoRapidaItem extends StatelessWidget {
  final IconData icone;
  final String label;
  final VoidCallback onTap;

  const _AcaoRapidaItem({
    required this.icone,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.amarelo.withValues(alpha: .25),
              child: Icon(icone, size: 19, color: AppColors.darkFundo),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.legenda.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DicaDoDia extends StatelessWidget {
  const _DicaDoDia();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.azulInstitucional.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.azulInstitucional),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica do dia',
                  style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confirme os dados e escaneie o código no momento da coleta '
                  'para garantir mais agilidade e segurança.',
                  style: AppTextStyles.corpo.copyWith(
                    fontSize: 13,
                    color: AppColors.cinzaTexto,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
