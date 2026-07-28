import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/utils/formatters.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/presentation/solicitacoes/providers/solicitacoes_providers.dart';
import 'package:postapramim/presentation/solicitacoes/providers/usuario_publico_provider.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';
import 'package:postapramim/shared/widgets/state_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/shared/widgets/confirm_dialog.dart';

/// Tela de detalhe de uma solicitação — visão do cliente.
///
/// Mesma estrutura visual da `DetalheColetaPage` (do coletador), mas
/// somente leitura: o cliente acompanha o andamento e pode cancelar a
/// solicitação enquanto ela ainda não foi finalizada.
class DetalheSolicitacaoPage extends ConsumerWidget {
  final String id;
  const DetalheSolicitacaoPage({super.key, required this.id});

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
    // atual (mesmo balde de cor usado nos cards da Home/Dashboard).
    final grupo = async.maybeWhen(
      data: (result) => result.fold(
        onSuccess: (s) => s.status.grupoExibicao,
        onFailure: (_) => null,
      ),
      orElse: () => null,
    );
    final corFundo = grupo == null
        ? AppColors.branco
        : _corDoGrupo(grupo).withValues(alpha: .10);

    return Scaffold(
      backgroundColor: AppColors.branco,
      body: async.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) =>
            const ErrorState(mensagem: 'Erro ao carregar solicitação'),
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
                          _StatusCard(solicitacao: solicitacao),
                          const SizedBox(height: 14),
                          _ColetadorCard(solicitacao: solicitacao),
                          const SizedBox(height: 14),
                          _EnderecoCard(solicitacao: solicitacao),
                          if (solicitacao.observacoes?.isNotEmpty == true) ...[
                            const SizedBox(height: 14),
                            _ObservacoesCard(texto: solicitacao.observacoes!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _BotaoCancelar(id: id, solicitacao: solicitacao),
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

/// Faixa superior — mesma linguagem visual do cabeçalho da
/// `DetalheColetaPage`, adaptada para "solicitação" em vez de "coleta".
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
                        'Detalhes da solicitação',
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

/// Timeline de acompanhamento — igual à `_StatusDaColetaCard` do
/// coletador, mas somente leitura (sem botão de ação).
class _StatusCard extends StatelessWidget {
  final SolicitacaoEntity solicitacao;
  const _StatusCard({required this.solicitacao});

  static const _etapas = [
    (
      label: 'Aguardando',
      icone: Icons.inventory_2_outlined,
      grupo: GrupoStatusExibicao.coleta,
    ),
    (
      label: 'Em andamento',
      icone: Icons.local_shipping_outlined,
      grupo: GrupoStatusExibicao.emtransito,
    ),
    (
      label: 'Concluída',
      icone: Icons.check,
      grupo: GrupoStatusExibicao.concluida,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final grupoAtual = solicitacao.status.grupoExibicao;
    final inicio = solicitacao.janelaColetaInicio;
    final fim = solicitacao.janelaColetaFim;

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
            'Acompanhe sua solicitação',
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
                      color: AppColors.amareloClaro.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.amarelo,
                            ),
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
                            color: AppColors.amarelo,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.amarelo,
                            ),
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

  const _EtapaTimeline({
    required this.etapa,
    required this.ativa,
    required this.concluida,
  });

  @override
  Widget build(BuildContext context) {
    final destacada = ativa || concluida;
    final cor = destacada ? _corDoGrupo(etapa.grupo) : AppColors.cinzaBorda;

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

class _CartaoInfo extends StatelessWidget {
  final IconData icone;
  final Widget conteudo;
  final Widget? acao;
  final VoidCallback? onTap;

  const _CartaoInfo({required this.icone, required this.conteudo, this.acao})
    : onTap = null;

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
              backgroundColor: AppColors.amarelo.withValues(alpha: .15),
              child: Icon(icone, color: AppColors.amarelo),
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

/// Card do coletador designado. Enquanto não existe join com
/// `usuarios`/`coletadores` no datasource, mostramos apenas se já foi
/// atribuído um coletador ou não — sem nome/telefone (a entidade hoje só
/// guarda `coletadorId`).
class _ColetadorCard extends ConsumerWidget {
  final SolicitacaoEntity solicitacao;
  const _ColetadorCard({required this.solicitacao});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coletadorId = solicitacao.coletadorId;

    if (coletadorId == null) {
      return _CartaoInfo(
        icone: Icons.local_shipping_outlined,
        conteudo: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aguardando coletador',
              style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 2),
            Text(
              'Assim que um coletador aceitar, você verá a atualização aqui.',
              style: AppTextStyles.legenda,
            ),
          ],
        ),
      );
    }

    final async = ref.watch(usuarioPublicoProvider(coletadorId));

    return _CartaoInfo(
      icone: Icons.local_shipping_outlined,
      conteudo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Coletador a caminho',
            style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 2),
          async.when(
            loading: () => Text('Carregando...', style: AppTextStyles.legenda),
            error: (_, __) => Text(
              'Um coletador já foi designado para sua solicitação.',
              style: AppTextStyles.legenda,
            ),
            data: (coletador) => Text(
              coletador != null
                  ? '${coletador.nome} foi designado para sua solicitação.'
                  : 'Um coletador já foi designado para sua solicitação.',
              style: AppTextStyles.legenda,
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

    return _CartaoInfo(
      icone: Icons.location_on_outlined,
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
      acao: solicitacao.enderecoResumo == null
          ? null
          : InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _abrirNoMapa(solicitacao.enderecoResumo!),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.amarelo),
                ),
                child: const Icon(
                  Icons.map_outlined,
                  size: 18,
                  color: AppColors.amarelo,
                ),
              ),
            ),
    );
  }
}

class _ObservacoesCard extends StatelessWidget {
  final String texto;
  const _ObservacoesCard({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amareloClaro.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.amarelo.withValues(alpha: .2),
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.amarelo,
            ),
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

/// Botão de cancelar no rodapé — só aparece enquanto a solicitação não
/// estiver finalizada (concluída ou já cancelada).
class _BotaoCancelar extends ConsumerWidget {
  final String id;
  final SolicitacaoEntity solicitacao;
  const _BotaoCancelar({required this.id, required this.solicitacao});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _confirmarCancelamento(context, ref, id),
          icon: const Icon(Icons.cancel_outlined, color: AppColors.erro),
          label: Text(
            'Cancelar solicitação',
            style: AppTextStyles.botao.copyWith(color: AppColors.erro),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: AppColors.erro),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cor por balde de status — mesmo esquema visual da Home do cliente e do
/// dashboard do coletador, redefinido aqui localmente (sem depender de
/// extension de outra tela).
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

Future<void> _confirmarCancelamento(
  BuildContext context,
  WidgetRef ref,
  String id,
) async {
  final confirmou = await showAppConfirmDialog(
    context,
    icone: Icons.cancel_outlined,
    cor: AppColors.erro,
    titulo: 'Cancelar solicitação?',
    mensagem: 'Essa ação não pode ser desfeita.',
    labelConfirmar: 'Cancelar solicitação',
  );

  if (confirmou) {
    final ok = await ref
        .read(solicitacoesControllerProvider.notifier)
        .cancelar(id);
    if (ok && context.mounted) {
      context.go(RoutePaths.clienteHome);
    }
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
