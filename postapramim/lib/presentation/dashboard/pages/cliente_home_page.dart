import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/presentation/solicitacoes/providers/solicitacoes_providers.dart';
import 'package:postapramim/presentation/solicitacoes/providers/usuario_publico_provider.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';

class ClienteHomePage extends ConsumerWidget {
  const ClienteHomePage({super.key});

  // Cor de fundo levemente acinzentada por trás dos cards brancos, igual ao
  // mockup. Ajuste para AppColors.xxx caso já exista uma cor equivalente no
  // seu design system.
  static const _corFundo = Color(0xFFF6F7F9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider).usuario;
    final primeiroNome = (usuario?.nome ?? '').split(' ').first;
    final solicitacoesAsync = ref.watch(minhasSolicitacoesRealtimeProvider);

    return Scaffold(
      backgroundColor: _corFundo,
      body: SafeArea(
        child: solicitacoesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (erro, _) => _ErroCarregamento(
            mensagem: 'Não foi possível carregar suas solicitações.',
            onTentarNovamente: () =>
                ref.invalidate(minhasSolicitacoesRealtimeProvider),
          ),
          data: (solicitacoes) {
            final resumo = _ResumoDevolucoes.deLista(solicitacoes);
            final recentes = solicitacoes.take(5).toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _Cabecalho(nome: primeiroNome),
                const SizedBox(height: 20),
                _ResumoCard(resumo: resumo),
                const SizedBox(height: 20),
                _BotaoNovaSolicitacao(
                  onTap: () => context.push(RoutePaths.clienteNovaSolicitacao),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Minhas solicitações',
                      style: AppTextStyles.subtitulo.copyWith(fontSize: 17),
                    ),
                    GestureDetector(
                      onTap: () => context.push(RoutePaths.clienteHistorico),
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
                if (recentes.isEmpty)
                  const _ListaVazia()
                else
                  for (final s in recentes) ...[
                    _SolicitacaoCard(
                      solicitacao: s,
                      onTap: () => context.push(
                        RoutePaths.clienteDetalheSolicitacao.replaceFirst(
                          ':id',
                          s.id,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
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
              context.push(RoutePaths.clienteHistorico);
              break;
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
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Solicitações',
          ),
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

class _Cabecalho extends StatelessWidget {
  final String nome;

  const _Cabecalho({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/images/logo.png', height: 36),
        const Spacer(),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.amarelo.withValues(alpha: .25),
          child: const Icon(Icons.person, color: AppColors.amarelo),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Olá, ${nome.isEmpty ? 'visitante' : nome}! 👋',
              style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
            ),
            Text('Bem-vindo de volta', style: AppTextStyles.legenda),
          ],
        ),
      ],
    );
  }
}

class _ErroCarregamento extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentarNovamente;

  const _ErroCarregamento({
    required this.mensagem,
    required this.onTentarNovamente,
  });

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
              mensagem,
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
            Icons.inbox_outlined,
            size: 36,
            color: AppColors.cinzaBorda,
          ),
          const SizedBox(height: 8),
          Text('Você ainda não tem solicitações', style: AppTextStyles.legenda),
        ],
      ),
    );
  }
}

class _ResumoDevolucoes {
  final int aguardando;
  final int emTransito;
  final int concluidas;

  const _ResumoDevolucoes({
    required this.aguardando,
    required this.emTransito,
    required this.concluidas,
  });

  factory _ResumoDevolucoes.deLista(List<SolicitacaoEntity> lista) {
    var realizada = 0;
    var aguardando = 0;
    var emTransito = 0;
    var concluidas = 0;
    for (final s in lista) {
      switch (s.status.grupoExibicao) {
        case GrupoStatusExibicao.realizada:
          realizada++;
          break;
        case GrupoStatusExibicao.coleta:
          aguardando++;
          break;
        case GrupoStatusExibicao.emtransito:
          emTransito++;
          break;
        case GrupoStatusExibicao.concluida:
          concluidas++;
          break;
        case GrupoStatusExibicao.cancelada:
          break;
      }
    }
    return _ResumoDevolucoes(
      aguardando: aguardando,
      emTransito: emTransito,
      concluidas: concluidas,
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final _ResumoDevolucoes resumo;

  const _ResumoCard({required this.resumo});

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
          Text(
            'Resumo das suas devoluções',
            style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ResumoItem(
                  valor: resumo.aguardando,
                  label: 'Aguardando',
                  imagePath: 'assets/icons/icone_solicitar_sem_cadastro.png',
                  corFundo: AppColors.amarelo.withValues(alpha: .15),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResumoItem(
                  valor: resumo.emTransito,
                  label: 'Em trânsito',
                  imagePath: 'assets/icons/em_transito.png',
                  corFundo: AppColors.azulInstitucional.withValues(alpha: .1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResumoItem(
                  valor: resumo.concluidas,
                  label: 'Concluídas',
                  imagePath: 'assets/icons/concluida.png',
                  corFundo: Colors.green.withValues(alpha: .1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResumoItem extends StatelessWidget {
  final int valor;
  final String label;
  final String imagePath;
  final Color corFundo;

  const _ResumoItem({
    required this.valor,
    required this.label,
    required this.imagePath,
    required this.corFundo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
              Text(
                '$valor',
                style: AppTextStyles.titulo.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(label, style: AppTextStyles.legenda.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _BotaoNovaSolicitacao extends StatelessWidget {
  final VoidCallback onTap;

  const _BotaoNovaSolicitacao({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.amarelo,
          foregroundColor: AppColors.preto,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, color: AppColors.preto),
            const SizedBox(width: 10),
            Text(
              'Nova Solicitação',
              style: AppTextStyles.botao.copyWith(
                color: AppColors.preto,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// UI (labels/cores/ícones) para os baldes de status definidos em
/// `status_solicitacao_ui.dart`, no esquema de cores da Home do cliente.
extension GrupoStatusExibicaoUiX on GrupoStatusExibicao {
  String get label {
    switch (this) {
      case GrupoStatusExibicao.realizada:
        return 'Realizada';
      case GrupoStatusExibicao.coleta:
        return 'Em coleta';
      case GrupoStatusExibicao.emtransito:
        return 'Em trânsito';
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
        return AppColors.amarelo;
      case GrupoStatusExibicao.emtransito:
        return AppColors.azulInstitucional;
      case GrupoStatusExibicao.concluida:
        return Colors.green;
      case GrupoStatusExibicao.cancelada:
        return AppColors.erro;
    }
  }

  String get imagem {
    switch (this) {
      case GrupoStatusExibicao.realizada:
        return 'assets/icons/icone_solicitar_sem_cadastro.png';
      case GrupoStatusExibicao.coleta:
        return 'assets/icons/icone_solicitar_sem_cadastro.png';
      case GrupoStatusExibicao.emtransito:
        return 'assets/icons/em_transito.png';
      case GrupoStatusExibicao.concluida:
        return 'assets/icons/concluida.png';
      case GrupoStatusExibicao.cancelada:
        return 'assets/icons/cancelada.png';
    }
  }
}

String _formatarDataHora(DateTime dt) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(dt.day)}/${dois(dt.month)}/${dt.year} às '
      '${dois(dt.hour)}:${dois(dt.minute)}';
}

/// Mostra o nome do coletador assim que a solicitação já tiver um
/// atribuído — visível pro cliente tanto aqui na Home quanto na tela de
/// detalhe da solicitação.
class _ColetadorAtribuidoLinha extends ConsumerWidget {
  final String coletadorId;
  const _ColetadorAtribuidoLinha({required this.coletadorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(usuarioPublicoProvider(coletadorId));
    return Row(
      children: [
        const Icon(
          Icons.local_shipping_outlined,
          size: 12,
          color: AppColors.cinzaTexto,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: async.when(
            loading: () => Text(
              'Coletador: ...',
              style: AppTextStyles.legenda.copyWith(fontSize: 11),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (coletador) => Text(
              'Coletador: ${coletador?.nome ?? '—'}',
              style: AppTextStyles.legenda.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _SolicitacaoCard extends StatelessWidget {
  final SolicitacaoEntity solicitacao;
  final VoidCallback onTap;

  const _SolicitacaoCard({required this.solicitacao, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final grupo = solicitacao.status.grupoExibicao;
    final codigo =
        solicitacao.codigoDevolucao ??
        solicitacao.id.substring(0, 8).toUpperCase();
    // Usa sempre o snapshot gravado na criação da solicitação, e não o
    // nome atual do usuário logado — assim, se o cliente editar o perfil
    // depois, as solicitações antigas continuam mostrando o nome de
    // quando foram criadas.
    final nomeExibido = solicitacao.nomeExibicao;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cinzaBorda),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(grupo.imagem, width: 50, height: 50, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    codigo,
                    style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cliente: $nomeExibido',
                    style: AppTextStyles.legenda,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatarDataHora(solicitacao.criadoEm),
                    style: AppTextStyles.legenda.copyWith(fontSize: 11),
                  ),
                  if (solicitacao.coletadorId != null) ...[
                    const SizedBox(height: 2),
                    _ColetadorAtribuidoLinha(
                      coletadorId: solicitacao.coletadorId!,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: grupo.cor),
                      const SizedBox(width: 6),
                      Text(
                        grupo.label,
                        style: AppTextStyles.corpo.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: grupo.cor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.azulInstitucional),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Ver detalhes',
                style: AppTextStyles.corpo.copyWith(
                  color: AppColors.azulInstitucional,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
