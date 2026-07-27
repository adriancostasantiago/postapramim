import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/utils/formatters.dart';
import 'package:postapramim/features/auth/presentation/providers/auth_providers.dart';
import 'package:postapramim/features/solicitacoes/domain/entities/solicitacao_entity.dart';
import 'package:postapramim/features/solicitacoes/presentation/providers/solicitacoes_providers.dart';
import 'package:postapramim/features/solicitacoes/presentation/providers/usuario_publico_provider.dart';
import 'package:postapramim/features/solicitacoes/presentation/status_solicitacao_ui.dart';
import 'package:postapramim/shared/widgets/state_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tela de detalhe de uma coleta — visão do coletador.
///
/// Carrega a solicitação real via [detalheSolicitacaoProvider] (busca por
/// id) e permite ao coletador ligar para o cliente e alterar o status do
/// fluxo (aceitar, avançar etapas, cancelar).
class DetalheColetaPage extends ConsumerWidget {
  final String id;
  const DetalheColetaPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(detalheSolicitacaoProvider(id));

    ref.listen(solicitacoesControllerProvider, (prev, next) {
      if (next.erro != null && next.erro != prev?.erro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.erro!), backgroundColor: AppColors.erro),
        );
      }
    });

    // Enquanto carrega (ou em caso de erro) mantém o fundo neutro; assim
    // que a solicitação chega, a tela inteira assume o tom do status
    // atual (mesmo balde de cor usado nos cards do Dashboard).
    final grupo = async.maybeWhen(
      data: (result) => result.fold(
        onSuccess: (s) => s.status.grupoExibicao,
        onFailure: (_) => null,
      ),
      orElse: () => null,
    );
    // final corFundo = grupo == null
    //     ? AppColors.branco
    //     : _corDoGrupo(grupo).withValues(alpha: .10);

    return Scaffold(
      backgroundColor: AppColors.branco,
      body: async.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) =>
            const ErrorState(mensagem: 'Erro ao carregar a coleta'),
        data: (result) => result.fold(
          onSuccess: (solicitacao) =>
              _Conteudo(id: id, solicitacao: solicitacao),
          onFailure: (f) => ErrorState(mensagem: f.message),
        ),
      ),
    );
  }
}

class _Conteudo extends ConsumerWidget {
  final String id;
  final SolicitacaoEntity solicitacao;
  const _Conteudo({required this.id, required this.solicitacao});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carregando = ref.watch(
      solicitacoesControllerProvider.select((s) => s.carregando),
    );

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _CabecalhoDetalhe(solicitacao: solicitacao),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _StatusDaColetaCard(solicitacao: solicitacao),
                          const SizedBox(height: 14),
                          _ClienteCard(solicitacao: solicitacao),
                          if (solicitacao.coletadorId != null) ...[
                            const SizedBox(height: 14),
                            _ColetadorCard(
                              coletadorId: solicitacao.coletadorId!,
                              cor: AppColors.statusColor(
                                solicitacao.status.valorBanco,
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),
                          _EnderecoCard(solicitacao: solicitacao),
                          if (solicitacao.observacoes?.isNotEmpty == true) ...[
                            const SizedBox(height: 14),
                            _ObservacoesCard(
                              texto: solicitacao.observacoes!,
                              cor: AppColors.statusColor(
                                solicitacao.status.valorBanco,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _BotoesAcao(id: id, solicitacao: solicitacao),
            ],
          ),
          if (carregando)
            Container(
              color: Colors.black.withValues(alpha: .05),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

/// Faixa superior com back button, título, badge de status, código e
/// data/hora — mesma linguagem visual do cabeçalho da
/// `ColetadorDashboardPage`.
class _CabecalhoDetalhe extends StatelessWidget {
  final SolicitacaoEntity solicitacao;
  const _CabecalhoDetalhe({required this.solicitacao});

  @override
  Widget build(BuildContext context) {
    final status = solicitacao.status;
    final cor = AppColors.statusColor(status.valorBanco);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 230,
          color:
              Colors.transparent, // deixa o fundo colorido do Scaffold aparecer
        ),
        Positioned(
          top: 60,
          right: 0,
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/ilustracao_detalhe_solicitacao.png',
              height: 200,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.darkFundo,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Detalhes da coleta',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titulo.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: cor.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.label,
                          style: AppTextStyles.corpo.copyWith(
                            color: cor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        solicitacao.codigoDevolucao ??
                            solicitacao.id.substring(0, 8).toUpperCase(),
                        style: AppTextStyles.titulo.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Solicitado em ${Formatters.dataHora(solicitacao.criadoEm)}',
                        style: AppTextStyles.legenda,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Card com a timeline vertical de status (agrupado em 3 grandes etapas —
/// aguardando / em andamento / concluída, ver `status_solicitacao_ui.dart`)
/// + box lateral com o horário agendado e o status atual detalhado.
class _StatusDaColetaCard extends StatelessWidget {
  final SolicitacaoEntity solicitacao;
  const _StatusDaColetaCard({required this.solicitacao});

  // final status = solicitacao.status;

  static const _etapas = [
    (
      label: 'Realizada',
      icone: Icons.handshake_outlined,
      grupo: GrupoStatusExibicao.coleta,
    ),
    (
      label: 'Em coleta',
      icone: Icons.inventory_2_outlined,
      grupo: GrupoStatusExibicao.coleta,
    ),
    (
      label: 'Em trânsito',
      icone: Icons.local_shipping_outlined,
      grupo: GrupoStatusExibicao.emtransito,
    ),
    (
      label: 'Concluída',
      icone: Icons.check,
      grupo: GrupoStatusExibicao.concluida,
    ),

    (
      label: 'Cancelada',
      icone: Icons.cancel_outlined,
      grupo: GrupoStatusExibicao.cancelada,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final grupoAtual = solicitacao.status.grupoExibicao;
    final inicio = solicitacao.janelaColetaInicio;
    final fim = solicitacao.janelaColetaFim;

    final cor = AppColors.statusColor(solicitacao.status.valorBanco);

    if (grupoAtual == GrupoStatusExibicao.cancelada) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.erro.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.erro.withValues(alpha: .3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.erro),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Esta solicitação foi cancelada.',
                style: AppTextStyles.corpo.copyWith(
                  color: AppColors.erro,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final indiceAtual = _etapas.indexWhere((e) => e.grupo == grupoAtual);

    return Container(
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
            'Status da coleta',
            style: AppTextStyles.subtitulo.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      for (var i = 0; i < _etapas.length; i++) ...[
                        _EtapaTimeline(
                          etapa: _etapas[i],
                          concluida: indiceAtual >= 0 && i < indiceAtual,
                          ativa: i == indiceAtual,
                          cor: cor,
                        ),
                        if (i != _etapas.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 19),
                            child: Container(
                              width: 2,
                              height: 22,
                              color: AppColors.cinzaBorda,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cor.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: cor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Horário',
                                style: AppTextStyles.legenda.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (inicio != null && fim != null)
                              ? '${Formatters.hora(inicio)} - ${Formatters.hora(fim)}'
                              : '—',
                          style: AppTextStyles.subtitulo.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            // color: cor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: cor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Status atual',
                                style: AppTextStyles.legenda.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Center(
                          child: Text(
                            solicitacao.status.label,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.subtitulo.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _EtapaTimeline extends StatelessWidget {
  final ({String label, IconData icone, GrupoStatusExibicao grupo}) etapa;
  final bool ativa;
  final bool concluida;
  final Color cor;

  const _EtapaTimeline({
    required this.etapa,
    required this.ativa,
    required this.concluida,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final destacada = ativa || concluida;
    // final cor = destacada ? _corDoGrupo(etapa.grupo) : AppColors.cinzaBorda;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: destacada ? cor : AppColors.branco,
            shape: BoxShape.circle,
            border: Border.all(color: cor, width: destacada ? 0 : 1.5),
          ),
          child: Icon(
            concluida ? Icons.check : etapa.icone,
            size: 18,
            color: destacada ? AppColors.branco : cor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            etapa.label,
            style: AppTextStyles.corpo.copyWith(
              fontWeight: ativa ? FontWeight.w700 : FontWeight.w400,
              color: destacada ? AppColors.darkFundo : AppColors.cinzaTexto,
            ),
          ),
        ),
      ],
    );
  }
}

/// Cartão base reaproveitado pelos blocos "Cliente" e "Endereço".
class _CartaoInfo extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final Widget conteudo;
  final Widget? acao;
  final VoidCallback? onTap;

  const _CartaoInfo({
    required this.icone,
    required this.cor,
    required this.conteudo,
    this.acao,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.branco,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cinzaBorda),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cor.withValues(alpha: .15),
              child: Icon(icone, color: cor),
            ),
            const SizedBox(width: 14),
            Expanded(child: conteudo),
            if (acao != null) ...[const SizedBox(width: 8), acao!],
          ],
        ),
      ),
    );
  }
}

class _ClienteCard extends StatelessWidget {
  final SolicitacaoEntity solicitacao;
  const _ClienteCard({required this.solicitacao});

  @override
  Widget build(BuildContext context) {
    // nome/telefone agora são snapshot preenchido na criação da
    // solicitação (avulsa ou cliente cadastrado) — ver
    // `NovaSolicitacaoPage._enviar` e `SolicitacoesRepositoryImpl.criarAvulsa`.
    final nome = solicitacao.nomeExibicao;
    final telefone = solicitacao.telefoneExibicao ?? '';
    final cor = AppColors.statusColor(solicitacao.status.valorBanco);

    return _CartaoInfo(
      icone: Icons.person_outline,
      cor: cor,
      conteudo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(nome, style: AppTextStyles.subtitulo.copyWith(fontSize: 15)),
          if (telefone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(telefone, style: AppTextStyles.legenda),
          ] else ...[
            const SizedBox(height: 2),
            Text(
              'Telefone não informado',
              style: AppTextStyles.legenda.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
      acao: _BotaoCircular(
        icone: Icons.call_outlined,
        cor: cor,
        onTap: telefone.isEmpty ? null : () => _ligarPara(telefone),
      ),
    );
  }
}

/// Mostra quem aceitou a solicitação — visível tanto pro coletador quanto
/// (em telas equivalentes) pro cliente, assim que `coletadorId` deixa de
/// ser nulo. Busca nome/telefone via `usuarioPublicoProvider`, que
/// depende da policy de RLS `usuarios_select_participante_solicitacao`.
class _ColetadorCard extends ConsumerWidget {
  final String coletadorId;
  final Color cor;
  const _ColetadorCard({required this.coletadorId, required this.cor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meuId = ref.watch(authControllerProvider).usuario?.id;
    final souEu = meuId == coletadorId;
    final async = ref.watch(usuarioPublicoProvider(coletadorId));

    return _CartaoInfo(
      icone: Icons.local_shipping_outlined,
      cor: cor,
      conteudo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Responsável',
            style: AppTextStyles.legenda.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          async.when(
            loading: () => const SizedBox(
              height: 14,
              width: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) =>
                Text('Não foi possível carregar', style: AppTextStyles.legenda),
            data: (coletador) => Text(
              (coletador?.nome ?? 'Coletador'),
              style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnderecoCard extends StatelessWidget {
  final SolicitacaoEntity solicitacao;
  const _EnderecoCard({required this.solicitacao});

  @override
  Widget build(BuildContext context) {
    // enderecoResumo agora é o snapshot preenchido na criação da
    // solicitação (avulsa ou cliente cadastrado).
    final texto = solicitacao.enderecoResumo ?? 'Endereço não informado';
    final cor = AppColors.statusColor(solicitacao.status.valorBanco);

    return _CartaoInfo(
      icone: Icons.location_on_outlined,
      cor: cor,
      conteudo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Endereço da coleta',
            style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(texto, style: AppTextStyles.legenda),
        ],
      ),
      acao: _BotaoCircular(
        icone: Icons.map_outlined,
        cor: cor,
        onTap: solicitacao.enderecoResumo == null
            ? null
            : () => _abrirNoMapa(solicitacao.enderecoResumo!),
      ),
    );
  }
}

class _ObservacoesCard extends StatelessWidget {
  final String texto;
  final Color cor;
  const _ObservacoesCard({required this.texto, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cor.withValues(alpha: .2),
            child: Icon(Icons.description_outlined, color: cor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Observações',
                  style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(texto, style: AppTextStyles.corpo.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotaoCircular extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final VoidCallback? onTap;
  const _BotaoCircular({
    required this.icone,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final desabilitado = onTap == null;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: desabilitado ? AppColors.cinzaBorda : cor),
        ),
        child: Icon(
          icone,
          size: 18,
          color: desabilitado ? AppColors.cinzaTexto : cor,
        ),
      ),
    );
  }
}

/// Barra fixa no rodapé — "Ligar para cliente" e "Atualizar status", que
/// abre um bottom sheet com todas as etapas do fluxo + opção de cancelar.
class _BotoesAcao extends ConsumerWidget {
  final String id;
  final SolicitacaoEntity solicitacao;
  const _BotoesAcao({required this.id, required this.solicitacao});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final telefone = solicitacao.telefoneExibicao ?? '';
    final meuId = ref.watch(authControllerProvider).usuario?.id;

    final cor = AppColors.statusColor(solicitacao.status.valorBanco);
    final precisaAceitar =
        solicitacao.status == StatusSolicitacao.solicitacaoRealizada &&
        solicitacao.coletadorId == null;

    if (solicitacao.finalizada) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cinzaBorda.withValues(alpha: .3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: AppColors.cinzaTexto),
              const SizedBox(width: 8),
              Text(
                solicitacao.status == StatusSolicitacao.cancelada
                    ? 'Solicitação cancelada'
                    : 'Solicitação concluída',
                style: AppTextStyles.corpo.copyWith(
                  color: AppColors.cinzaTexto,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: telefone.isEmpty ? null : () => _ligarPara(telefone),
              icon: Icon(Icons.call_outlined, color: cor),
              label: Text(
                'Ligar para cliente',
                style: AppTextStyles.botao.copyWith(color: cor),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: cor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: precisaAceitar
                  ? () => _aceitar(context, ref, id, meuId)
                  : () => _abrirSeletorDeStatus(context, ref, id, solicitacao),
              icon: Icon(
                precisaAceitar ? Icons.check_circle_outline : Icons.sync_alt,
                color: AppColors.branco,
              ),
              label: Text(
                precisaAceitar ? 'Aceitar solicitação' : 'Atualizar status',
                style: AppTextStyles.botao.copyWith(
                  color: AppColors.branco,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cor por balde de status (mesmo esquema usado na Home do cliente e no
/// dashboard do coletador — ver `GrupoStatusExibicaoUiX` em
/// `cliente_home_page.dart`). Redefinido aqui localmente para não depender
/// de uma extension de outra tela.
Color _corDoGrupo(GrupoStatusExibicao grupo) {
  switch (grupo) {
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

Future<void> _aceitar(
  BuildContext context,
  WidgetRef ref,
  String id,
  String? meuId,
) async {
  if (meuId == null) return;
  await ref
      .read(solicitacoesControllerProvider.notifier)
      .atualizarStatus(
        id: id,
        novoStatus: StatusSolicitacao.aguardandoColeta,
        coletadorId: meuId,
      );
}

/// Avança para o próximo status do fluxo (aguardandoColeta -> emTransito
/// -> concluida) ou cancela. Não usa mais um seletor com todos os status
/// possíveis: como o fluxo agora é linear, só faz sentido avançar um
/// passo por vez (e o "aceitar" — que também define o coletador — já é
/// feito por um botão separado, ver `_aceitar`).
Future<void> _abrirSeletorDeStatus(
  BuildContext context,
  WidgetRef ref,
  String id,
  SolicitacaoEntity solicitacao,
) async {
  final proximo = solicitacao.status.proximoStatus;

  final acao = await showModalBottomSheet<StatusSolicitacao>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              'Alterar status da coleta',
              style: AppTextStyles.subtitulo.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (proximo != null)
              ListTile(
                leading: Icon(
                  Icons.circle,
                  size: 12,
                  color: AppColors.statusColor(proximo.valorBanco),
                ),
                title: Text(proximo.label),
                onTap: () => Navigator.of(context).pop(proximo),
              ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: AppColors.erro),
              title: const Text(
                'Cancelar solicitação',
                style: TextStyle(color: AppColors.erro),
              ),
              onTap: () =>
                  Navigator.of(context).pop(StatusSolicitacao.cancelada),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  if (acao == null || !context.mounted) return;

  if (acao == StatusSolicitacao.cancelada) {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar solicitação?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar solicitação'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;
  }

  await ref
      .read(solicitacoesControllerProvider.notifier)
      .atualizarStatus(id: id, novoStatus: acao);
}

Future<void> _ligarPara(String telefone) async {
  final numeroLimpo = telefone.replaceAll(RegExp(r'[^0-9+]'), '');
  final uri = Uri.parse('tel:$numeroLimpo');
  if (!await launchUrl(uri)) {
    throw Exception('Não foi possível iniciar a ligação.');
  }
}

Future<void> _abrirNoMapa(String endereco) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(endereco)}',
  );
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Não foi possível abrir o mapa.');
  }
}
