import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/presentation/solicitacoes/providers/solicitacoes_providers.dart';
import 'package:postapramim/presentation/solicitacoes/providers/usuario_publico_provider.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Painel principal do coletador.
///
/// Mostra TODAS as solicitações do sistema (não só as já atribuídas a este
/// coletador) — qualquer coletador logado pode ver a demanda em aberto e,
/// futuramente, aceitar uma coleta. Depende da policy de RLS
/// `solicitacoes_select_coletador_todas` (ver
/// sql/schema_patch_dashboard.sql).
class ColetadorDashboardPage extends ConsumerWidget {
  const ColetadorDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider).usuario;
    final primeiroNome = (usuario?.nome ?? '').split(' ').first;
    final solicitacoesAsync = ref.watch(todasSolicitacoesRealtimeProvider);
    final hoje = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.amareloClaro,
      body: SafeArea(
        child: solicitacoesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erro, _) => _ErroCarregamento(
            onTentarNovamente: () =>
                ref.invalidate(todasSolicitacoesRealtimeProvider),
          ),
          data: (solicitacoes) {
            final resumo = _ResumoColetas.deLista(solicitacoes);
            final proximas = solicitacoes
                .where(
                  (s) =>
                      s.status.grupoExibicao != GrupoStatusExibicao.cancelada,
                )
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
                        const SizedBox(height: 20),
                        _AcoesRapidas(
                          onVerRotas: () =>
                              context.push(RoutePaths.coletadorMapaRota),
                          onEscanear: () =>
                              context.push(RoutePaths.coletadorScanner),
                          // TODO: criar rota dedicada para coleta avulsa iniciada
                          // pelo próprio coletador, se esse fluxo existir no app.
                          onNovaColeta: () =>
                              context.push(RoutePaths.coletadorScanner),
                          onContatoSuporte: _ligarSuporte,
                        ),
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
                        if (proximas.isEmpty)
                          const _ListaVazia()
                        else
                          for (final s in proximas) ...[
                            _ColetaCard(
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
        selectedIndex: 0,
        onDestinationSelected: (i) {
          switch (i) {
            case 1:
              context.push(RoutePaths.coletadorMinhasColetas);
              break;
            case 2:
              context.push(RoutePaths.coletadorMapaRota);
              break;
            case 3:
              context.push(RoutePaths.ajuda);
              break;
            case 4:
              context.push(RoutePaths.perfil);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Solicitações',
          ),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Rotas'),
          NavigationDestination(icon: Icon(Icons.help_outline), label: 'Ajuda'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Conta',
          ),
        ],
      ),
    );
  }
}

/// Liga para o suporte via WhatsApp/telefone.
///
/// TODO: substituir o número fixo por uma constante de configuração
/// (ex.: `AppConstants.telefoneSuporte`), igual ao padrão já usado em
/// `SolicitarSemCadastroPage.enviarWhatsApp`.
Future<void> _ligarSuporte() async {
  final uri = Uri.parse('tel:+5575992873792');
  if (!await launchUrl(uri)) {
    throw Exception('Não foi possível iniciar a ligação.');
  }
}

/// Cabeçalho com faixa em degradê amarelo -> branco, menu, notificações,
/// avatar e saudação — mesma linguagem visual do banner usado em
/// `SolicitarSemCadastroPage`.
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
            // TODO: trocar pelo asset final da ilustração do caminhão do
            // dashboard (ex.: 'assets/images/ilustracao_dashboard.png').
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
                  // TODO: abrir o Drawer/menu lateral quando existir.
                  IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.darkFundo),
                    onPressed: () {},
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
  final int agendadas;
  final int emAndamento;
  final int concluidas;
  final int canceladas;

  const _ResumoColetas({
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
      agendadas: agendadas,
      emAndamento: emAndamento,
      concluidas: concluidas,
      canceladas: canceladas,
    );
  }
}

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
                'Resumo geral',
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
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: _ResumoItem(
                    valor: resumo.agendadas,
                    label: 'Aguardando',
                    linkLabel: 'Ver agenda',
                    imagePath: 'assets/icons/icone_solicitar_sem_cadastro.png',
                    icone: Icons.inventory_2_outlined,
                    cor: AppColors.alerta,
                    onTap: () =>
                        context.push(RoutePaths.coletadorMinhasColetas),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  child: _ResumoItem(
                    valor: resumo.emAndamento,
                    label: 'Em trânsito',
                    linkLabel: 'Ver rotas',
                    imagePath: 'assets/icons/em_transito.png',
                    icone: Icons.local_shipping_outlined,
                    cor: AppColors.azulInstitucional,
                    onTap: () => context.push(RoutePaths.coletadorMapaRota),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  child: _ResumoItem(
                    valor: resumo.concluidas,
                    label: 'Concluídas',
                    linkLabel: 'Ver concluídas',
                    imagePath: 'assets/icons/concluida.png',
                    icone: Icons.check_circle_outline,
                    cor: AppColors.sucesso,
                    onTap: () =>
                        context.push(RoutePaths.coletadorMinhasColetas),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 100,
                  child: _ResumoItem(
                    valor: resumo.canceladas,
                    label: 'Canceladas',
                    linkLabel: 'Ver detalhes',
                    imagePath: 'assets/icons/cancelada.png',
                    icone: Icons.cancel_outlined,
                    cor: AppColors.erro,
                    onTap: () =>
                        context.push(RoutePaths.coletadorMinhasColetas),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                '$valor',
                style: AppTextStyles.titulo.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.legenda.copyWith(fontSize: 11)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    linkLabel,
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

/// Atalhos rápidos, no mesmo espírito de "card com ícone circular" usado
/// em `SolicitarSemCadastroPage._IconeCircular`.
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

/// UI (labels/cores/ícones) para os baldes de status, no esquema de cores
/// original do dashboard do coletador.
extension _GrupoStatusColetaUiX on GrupoStatusExibicao {
  String get label {
    switch (this) {
      case GrupoStatusExibicao.realizada:
        return 'Realizada';
      case GrupoStatusExibicao.coleta:
        return 'Aguardando';
      case GrupoStatusExibicao.emtransito:
        return 'Em andamento';
      case GrupoStatusExibicao.concluida:
        return 'Concluída';
      case GrupoStatusExibicao.cancelada:
        return 'Cancelada';
    }
  }

  Color get cor {
    switch (this) {
      case GrupoStatusExibicao.realizada:
        return AppColors.cinzaTexto;
      case GrupoStatusExibicao.coleta:
        return AppColors.alerta;
      case GrupoStatusExibicao.emtransito:
        return AppColors.azulInstitucional;
      case GrupoStatusExibicao.concluida:
        return AppColors.sucesso;
      case GrupoStatusExibicao.cancelada:
        return AppColors.erro;
    }
  }

  IconData get icone {
    switch (this) {
      case GrupoStatusExibicao.realizada:
        return Icons.handshake_outlined;
      case GrupoStatusExibicao.coleta:
        return Icons.inventory_2_outlined;
      case GrupoStatusExibicao.emtransito:
        return Icons.local_shipping_outlined;
      case GrupoStatusExibicao.concluida:
        return Icons.check_circle_outline;
      case GrupoStatusExibicao.cancelada:
        return Icons.cancel_outlined;
    }
  }
}

String _formatarHorario(SolicitacaoEntity s) {
  String dois(int n) => n.toString().padLeft(2, '0');
  if (s.janelaColetaInicio != null && s.janelaColetaFim != null) {
    final ini = s.janelaColetaInicio!;
    final fim = s.janelaColetaFim!;
    return '${dois(ini.hour)}:${dois(ini.minute)} - ${dois(fim.hour)}:${dois(fim.minute)}';
  }
  final c = s.criadoEm;
  return 'Criada às ${dois(c.hour)}:${dois(c.minute)}';
}

/// Linha curta "Aceita por: <nome>" exibida nos cards do dashboard assim
/// que uma solicitação já tem coletador atribuído — vale tanto pra quem
/// aceitou (aparece "Você") quanto pros demais coletadores, que veem que
/// já não está mais em aberto.
class _AceitaPorLinha extends ConsumerWidget {
  final String coletadorId;
  const _AceitaPorLinha({required this.coletadorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meuId = ref.watch(authControllerProvider).usuario?.id;
    final souEu = meuId == coletadorId;
    final async = ref.watch(usuarioPublicoProvider(coletadorId));

    return Row(
      children: [
        const Icon(
          Icons.local_shipping_outlined,
          size: 13,
          color: AppColors.cinzaTexto,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: async.when(
            loading: () => Text(
              'Aceita por: ...',
              style: AppTextStyles.legenda.copyWith(fontSize: 12),
            ),
            error: (_, __) => Text(
              'Aceita',
              style: AppTextStyles.legenda.copyWith(fontSize: 12),
            ),
            data: (coletador) => Text(
              (coletador?.nome ?? '—'),
              style: AppTextStyles.legenda.copyWith(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _ColetaCard extends StatelessWidget {
  final SolicitacaoEntity solicitacao;
  final VoidCallback onTap;

  const _ColetaCard({required this.solicitacao, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final grupo = solicitacao.status.grupoExibicao;
    final codigo =
        solicitacao.codigoDevolucao ??
        solicitacao.id.substring(0, 8).toUpperCase();
    // nomeContato/enderecoResumo agora são um snapshot preenchido na
    // criação da solicitação (tanto para avulsa quanto para cliente
    // cadastrado — ver `NovaSolicitacaoPage._enviar`), então não há mais
    // necessidade de diferenciar por `avulsa` aqui.
    final cliente = solicitacao.nomeExibicao;
    final endereco = solicitacao.enderecoResumo ?? 'Endereço não informado';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.branco,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cinzaBorda),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: grupo.cor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: grupo.cor.withValues(alpha: .12),
                          child: Icon(grupo.icone, size: 20, color: grupo.cor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    codigo,
                                    style: AppTextStyles.subtitulo.copyWith(
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: grupo.cor.withValues(alpha: .12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      grupo.label,
                                      style: AppTextStyles.legenda.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: grupo.cor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Cliente: $cliente',
                                style: AppTextStyles.legenda,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    size: 13,
                                    color: AppColors.cinzaTexto,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      endereco,
                                      style: AppTextStyles.legenda.copyWith(
                                        fontSize: 12,
                                      ),
                                      maxLines: 5, // ou 3, se preferir
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 13,
                                    color: AppColors.cinzaTexto,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatarHorario(solicitacao),
                                    style: AppTextStyles.legenda.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (solicitacao.coletadorId != null) ...[
                                const SizedBox(height: 2),
                                _AceitaPorLinha(
                                  coletadorId: solicitacao.coletadorId!,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Center(
                          child: const Icon(
                            Icons.chevron_right,
                            color: AppColors.cinzaTexto,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bloco de dica informativa, no mesmo padrão de
/// `SolicitarSemCadastroPage._AvisoImportante`.
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
