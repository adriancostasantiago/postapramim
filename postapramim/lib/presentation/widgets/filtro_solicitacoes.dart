import 'package:flutter/material.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/utils/formatters.dart';
import 'package:postapramim/domain/solicitacoes/entities/solicitacao_entity.dart';
import 'package:postapramim/presentation/solicitacoes/status_solicitacao_ui.dart';
import 'package:postapramim/presentation/widgets/campo_busca.dart';

class FiltroSolicitacoes {
  final DateTimeRange? periodo;
  final GrupoStatusExibicao? status;
  final String busca;

  const FiltroSolicitacoes({this.periodo, this.status, this.busca = ''});

  FiltroSolicitacoes copyWith({
    DateTimeRange? periodo,
    bool limparPeriodo = false,
    GrupoStatusExibicao? status,
    bool limparStatus = false,
    String? busca,
  }) {
    return FiltroSolicitacoes(
      periodo: limparPeriodo ? null : (periodo ?? this.periodo),
      status: limparStatus ? null : (status ?? this.status),
      busca: busca ?? this.busca,
    );
  }
}

/// Barra de busca + filtro: campo de pesquisa (código/cliente), campo de
/// período e chips de status em pílula.
class FiltroSolicitacoesBar extends StatelessWidget {
  final FiltroSolicitacoes filtro;
  final ValueChanged<FiltroSolicitacoes> onChanged;

  /// Texto de dica do campo de busca. Ex.: "Pesquisar por código" (fluxo
  /// do cliente) ou "Pesquisar por código ou cliente" (fluxo do
  /// coletador).
  final String hintBusca;

  const FiltroSolicitacoesBar({
    super.key,
    required this.filtro,
    required this.onChanged,
    this.hintBusca = 'Pesquisar por código ou cliente',
  });

  Future<void> _selecionarPeriodo(BuildContext context) async {
    final agora = DateTime.now();
    // final resultado = await showDateRangePicker(
    //   context: context,
    //   firstDate: DateTime(agora.year - 2),
    //   lastDate: DateTime(agora.year + 1),
    //   initialDateRange: filtro.periodo,
    //   locale: const Locale('pt', 'BR'),
    // );
    final resultado = await showDateRangePicker(
      context: context,
      firstDate: DateTime(agora.year - 2),
      lastDate: DateTime(agora.year + 1),
      initialDateRange: filtro.periodo,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            colorScheme: const ColorScheme.light(
              surface: Colors.white,
              primary: Color(0xFF864303),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            datePickerTheme: const DatePickerThemeData(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (resultado != null) onChanged(filtro.copyWith(periodo: resultado));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CampoBusca(
          hint: hintBusca,
          onChanged: (v) => onChanged(filtro.copyWith(busca: v)),
          onFiltrar: () => _selecionarPeriodo(context),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selecionarPeriodo(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.cinzaBorda),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range_outlined,
                        size: 18,
                        color: AppColors.cinzaTexto,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          filtro.periodo == null
                              ? 'Filtrar por período'
                              : '${Formatters.data(filtro.periodo!.start)} até '
                                    '${Formatters.data(filtro.periodo!.end)}',
                          style: AppTextStyles.corpo.copyWith(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (filtro.periodo != null) ...[
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Limpar período',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () =>
                    onChanged(filtro.copyWith(limparPeriodo: true)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _ChipStatus(
                label: 'Todos',
                selecionado: filtro.status == null,
                onTap: () => onChanged(filtro.copyWith(limparStatus: true)),
              ),
              const SizedBox(width: 8),
              for (final grupo in GrupoStatusExibicao.values) ...[
                _ChipStatus(
                  label: _labelGrupo(grupo),
                  selecionado: filtro.status == grupo,
                  onTap: () => onChanged(filtro.copyWith(status: grupo)),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _labelGrupo(GrupoStatusExibicao grupo) {
    switch (grupo) {
      case GrupoStatusExibicao.realizada:
        return 'Realizada';
      case GrupoStatusExibicao.coleta:
        return 'Em Coleta';
      case GrupoStatusExibicao.emtransito:
        return 'Em trânsito';
      case GrupoStatusExibicao.concluida:
        return 'Concluída';
      case GrupoStatusExibicao.cancelada:
        return 'Cancelada';
    }
  }
}

class _ChipStatus extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  const _ChipStatus({
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.amarelo : AppColors.cinzaFundo,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionado ? AppColors.amarelo : AppColors.cinzaBorda,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selecionado) ...[
              const Icon(Icons.circle, size: 6, color: AppColors.preto),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.legenda.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selecionado ? AppColors.preto : AppColors.cinzaTexto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension FiltroSolicitacoesX on FiltroSolicitacoes {
  bool aceita(DateTime criadoEm, GrupoStatusExibicao grupo) {
    if (status != null && status != grupo) return false;
    if (periodo != null) {
      final inicio = DateTime(
        periodo!.start.year,
        periodo!.start.month,
        periodo!.start.day,
      );
      final fim = DateTime(
        periodo!.end.year,
        periodo!.end.month,
        periodo!.end.day,
        23,
        59,
        59,
      );
      if (criadoEm.isBefore(inicio) || criadoEm.isAfter(fim)) return false;
    }
    return true;
  }

  /// Verifica se [s] corresponde ao termo digitado no campo de busca.
  /// Quando [porCliente] é `true` também compara com o nome do cliente
  /// (fluxo do coletador); caso contrário só compara com o código de
  /// devolução (fluxo do cliente).
  bool aceitaBusca(SolicitacaoEntity s, {bool porCliente = false}) {
    final termo = busca.trim().toLowerCase();
    if (termo.isEmpty) return true;

    final codigo = (s.codigoDevolucao ?? s.id.substring(0, 8)).toLowerCase();
    if (codigo.contains(termo)) return true;

    if (porCliente) return s.nomeExibicao.toLowerCase().contains(termo);
    return false;
  }
}
