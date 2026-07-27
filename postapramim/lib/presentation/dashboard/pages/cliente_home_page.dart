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
import 'package:postapramim/shared/widgets/app_drawer.dart';

class ClienteHomePage extends ConsumerStatefulWidget {
  const ClienteHomePage({super.key});

  @override
  ConsumerState<ClienteHomePage> createState() => _ClienteHomePageState();
}

class _ClienteHomePageState extends ConsumerState<ClienteHomePage> {
  // Cor de fundo levemente acinzentada por trás dos cards brancos, igual ao
  // mockup.
  static const _corFundo = Color(0xFFF6F7F9);

  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(authControllerProvider).usuario;
    final primeiroNome = (usuario?.nome ?? '').split(' ').first;
    final solicitacoesAsync = ref.watch(minhasSolicitacoesRealtimeProvider);

    return Scaffold(
      backgroundColor: _corFundo,
      drawer: const AppDrawer(),
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

            // Cliente pesquisa somente pelo código de devolução.
            final termo = _busca.trim().toLowerCase();
            final filtradas = termo.isEmpty
                ? solicitacoes
                : solicitacoes.where((s) {
                    final codigo = (s.codigoDevolucao ?? s.id.substring(0, 8))
                        .toLowerCase();
                    return codigo.contains(termo);
                  }).toList();
            final recentes = filtradas.take(5).toList();

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
                CampoBusca(
                  hint: 'Pesquisar por código',
                  onChanged: (v) => setState(() => _busca = v),
                ),
                const SizedBox(height: 16),
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
                    SolicitacaoClienteCard(
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
            icon: Icon(Icons.home_outlined, color: AppColors.branco),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined, color: AppColors.cinzaTexto),
            label: 'Solicitações',
          ),
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

class _Cabecalho extends StatelessWidget {
  final String nome;

  const _Cabecalho({required this.nome});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.menu, color: AppColors.preto),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
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
