import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/presentation/solicitacoes/providers/usuario_publico_provider.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';

/// Cards de solicitação/coleta reaproveitados entre os dashboards
/// (Cliente/Coletador) e as respectivas listas completas ("Minhas
/// solicitações" e "Minhas coletas"), para manter a mesma cara em toda a
/// área logada.

String formatarDataHoraCard(DateTime dt) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(dt.day)}/${dois(dt.month)}/${dt.year} às '
      '${dois(dt.hour)}:${dois(dt.minute)}';
}

String formatarHorarioCard(SolicitacaoEntity s) {
  String dois(int n) => n.toString().padLeft(2, '0');
  final c = s.criadoEm;
  if (s.janelaColetaInicio != null && s.janelaColetaFim != null) {
    final ini = s.janelaColetaInicio!;
    final fim = s.janelaColetaFim!;
    return 'Criada em ${dois(c.day)}/${dois(c.month)}/${c.year} às ${dois(c.hour)}:${dois(c.minute)}\nColetar às ${dois(ini.hour)}:${dois(ini.minute)} - ${dois(fim.hour)}:${dois(fim.minute)}';
  }
  return 'Criada em ${dois(c.day)}/${dois(c.month)}/${c.year} às ${dois(c.hour)}:${dois(c.minute)}';
}

extension GrupoStatusExibicaoCardX on GrupoStatusExibicao {
  String get labelCard => switch (this) {
    GrupoStatusExibicao.realizada => 'Realizada',
    GrupoStatusExibicao.coleta => 'Em Coleta',
    GrupoStatusExibicao.emtransito => 'Em trânsito',
    GrupoStatusExibicao.concluida => 'Concluída',
    GrupoStatusExibicao.cancelada => 'Cancelada',
  };

  Color get corCard => switch (this) {
    GrupoStatusExibicao.realizada => AppColors.amarelo,
    GrupoStatusExibicao.coleta => AppColors.marron,
    GrupoStatusExibicao.emtransito => AppColors.azulInstitucional,
    GrupoStatusExibicao.concluida => Colors.green,
    GrupoStatusExibicao.cancelada => AppColors.erro,
  };

  IconData get iconeCard => switch (this) {
    GrupoStatusExibicao.realizada => Icons.handshake_outlined,
    GrupoStatusExibicao.coleta => Icons.inventory_2_outlined,
    GrupoStatusExibicao.emtransito => Icons.local_shipping_outlined,
    GrupoStatusExibicao.concluida => Icons.check_circle_outline,
    GrupoStatusExibicao.cancelada => Icons.cancel_outlined,
  };
}

String getStatusImage(StatusSolicitacao status) {
  switch (status) {
    case StatusSolicitacao.solicitacaoRealizada:
      return 'assets/icons/novo.png';

    case StatusSolicitacao.aguardandoColeta:
      return 'assets/icons/caixa.png';

    case StatusSolicitacao.emTransito:
      return 'assets/icons/caminhao-de-carga.png';

    case StatusSolicitacao.concluida:
      return 'assets/icons/verificar.png';

    case StatusSolicitacao.cancelada:
      return 'assets/icons/cancelar.png';
  }
}

/// Card no padrão visual da Home do cliente.
class SolicitacaoClienteCard extends StatelessWidget {
  final SolicitacaoEntity solicitacao;
  final VoidCallback onTap;

  const SolicitacaoClienteCard({
    super.key,
    required this.solicitacao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final grupo = solicitacao.status.grupoExibicao;
    final codigo =
        solicitacao.codigoDevolucao ??
        solicitacao.id.substring(0, 8).toUpperCase();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.branco,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cinzaBorda),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: grupo.corCard.withValues(alpha: .12),
              child: Icon(grupo.iconeCard, size: 20, color: grupo.corCard),
            ),
            const SizedBox(width: 12),
            Expanded(
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
                    'Cliente: ${solicitacao.nomeExibicao}',
                    style: AppTextStyles.legenda,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (solicitacao.enderecoResumo != null) ...[
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
                            solicitacao.enderecoResumo!,
                            style: AppTextStyles.legenda.copyWith(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: AppColors.cinzaTexto,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatarHorarioCard(solicitacao),
                        style: AppTextStyles.legenda.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                  if (solicitacao.coletadorId != null) ...[
                    const SizedBox(height: 2),
                    _ColetadorLinha(coletadorId: solicitacao.coletadorId!),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: grupo.corCard.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    grupo.labelCard,
                    style: AppTextStyles.legenda.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: grupo.corCard,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.chevron_right, color: AppColors.cinzaTexto),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card no padrão visual do dashboard do coletador.
class ColetaCard extends StatelessWidget {
  final SolicitacaoEntity solicitacao;
  final VoidCallback onTap;

  const ColetaCard({super.key, required this.solicitacao, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final grupo = solicitacao.status.grupoExibicao;
    final codigo =
        solicitacao.codigoDevolucao ??
        solicitacao.id.substring(0, 8).toUpperCase();
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
                    color: grupo.corCard,
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
                        // CircleAvatar(
                        //   radius: 22,
                        //   backgroundColor: grupo.corCard.withValues(alpha: .12),
                        //   child: Icon(
                        //     grupo.iconeCard,
                        //     size: 20,
                        //     color: grupo.corCard,
                        //   ),
                        // ),
                        Image.asset(
                          getStatusImage(solicitacao.status),
                          height: 20,
                          width: 20,
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
                                  Expanded(
                                    child: Text(
                                      codigo,
                                      style: AppTextStyles.subtitulo.copyWith(
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: grupo.corCard.withValues(
                                        alpha: .12,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      grupo.labelCard,
                                      style: AppTextStyles.legenda.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: grupo.corCard,
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
                                      maxLines: 3,
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
                                    formatarHorarioCard(solicitacao),
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
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.cinzaTexto,
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

class _ColetadorLinha extends ConsumerWidget {
  final String coletadorId;
  const _ColetadorLinha({required this.coletadorId});

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

class _AceitaPorLinha extends ConsumerWidget {
  final String coletadorId;
  const _AceitaPorLinha({required this.coletadorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              coletador?.nome ?? '—',
              style: AppTextStyles.legenda.copyWith(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
