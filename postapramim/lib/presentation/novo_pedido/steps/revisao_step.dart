import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/core/utils/currency_formatter.dart';
import 'package:posta_pra_mim/domain/entities/novo_pedido.dart';
import 'package:posta_pra_mim/presentation/shared/state/novo_pedido_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/novo_pedido_state.dart';

/// Etapa 4: revisão de todos os dados, seleção de pagamento e
/// botão de finalização.
class RevisaoStep extends StatelessWidget {
  const RevisaoStep({required this.edicao, super.key});

  final NovoPedidoEmEdicao edicao;

  @override
  Widget build(BuildContext context) {
    final remetente = edicao.remetente!;
    final destinatario = edicao.destinatario!;
    final carga = edicao.carga!;
    final valorEstimado =
        context.read<NovoPedidoController>().calcularValorEstimado(carga);
    final isSalvando =
        context.watch<NovoPedidoController>().state is NovoPedidoSalvando;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        _ResumoCard(
          tipo: 'REMETENTE',
          titulo: remetente.nomeCompleto,
          subtitulo:
              '${remetente.endereco.logradouro}, ${remetente.endereco.numero}'
              ' - ${remetente.endereco.cidade}, ${remetente.endereco.uf}',
          onEditar: () => context.read<NovoPedidoController>().voltarEtapa(),
        ),
        const SizedBox(height: 12),
        _ResumoCard(
          tipo: 'DESTINATÁRIO',
          titulo: destinatario.nomeCompleto,
          subtitulo:
              '${destinatario.endereco.logradouro}, ${destinatario.endereco.numero}'
              ' - ${destinatario.endereco.cidade}, ${destinatario.endereco.uf}',
          onEditar: () {
            // Volta duas etapas (3 → 1).
            context.read<NovoPedidoController>()
              ..voltarEtapa()
              ..voltarEtapa();
          },
        ),
        const SizedBox(height: 12),
        _CargaResumoCard(carga: carga),
        const SizedBox(height: 20),
        const Text(
          'Forma de Pagamento',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        for (final forma in FormaPagamentoNovoPedido.values) ...[
          _PagamentoRadioCard(
            forma: forma,
            selecionada: edicao.formaPagamento,
            onTap: () => context
                .read<NovoPedidoController>()
                .selecionarFormaPagamento(forma),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VALOR TOTAL DO ENVIO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(valorEstimado),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        if (isSalvando) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard({
    required this.tipo,
    required this.titulo,
    required this.subtitulo,
    required this.onEditar,
  });

  final String tipo;
  final String titulo;
  final String subtitulo;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tipo,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEditar,
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.primary,
            tooltip: 'Editar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _CargaResumoCard extends StatelessWidget {
  const _CargaResumoCard({required this.carga});

  final RascunhoCarga carga;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'INFORMAÇÕES DA CARGA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _CargaInfo(label: 'Tipo', value: '${carga.tipo.label} Média'),
              const SizedBox(width: 24),
              _CargaInfo(
                  label: 'Peso',
                  value:
                      '${carga.pesoKg.toStringAsFixed(1).replaceAll('.', ',')} kg'),
            ],
          ),
          const SizedBox(height: 6),
          _CargaInfo(label: 'Dimensões', value: carga.dimensoesLabel),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (carga.fragil)
                const _CargaBadge(label: 'Carga Frágil', isFragil: true),
              if (carga.urgente)
                const _CargaBadge(label: 'Envio Urgente', isFragil: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _CargaInfo extends StatelessWidget {
  const _CargaInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _CargaBadge extends StatelessWidget {
  const _CargaBadge({required this.label, required this.isFragil});

  final String label;
  final bool isFragil;

  @override
  Widget build(BuildContext context) {
    final color = isFragil ? AppColors.error : const Color(0xFFB8860B);
    final bg = isFragil
        ? AppColors.errorContainer.withValues(alpha: 0.6)
        : const Color(0xFFFFF4D6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFragil ? Icons.warning_amber_outlined : Icons.bolt,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PagamentoRadioCard extends StatelessWidget {
  const _PagamentoRadioCard({
    required this.forma,
    required this.selecionada,
    required this.onTap,
  });

  final FormaPagamentoNovoPedido forma;
  final FormaPagamentoNovoPedido selecionada;
  final VoidCallback onTap;

  IconData get _icon => switch (forma) {
        FormaPagamentoNovoPedido.cartaoCredito => Icons.credit_card_outlined,
        FormaPagamentoNovoPedido.pix => Icons.pix_outlined,
        FormaPagamentoNovoPedido.boleto => Icons.receipt_long_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final isSelected = forma == selecionada;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _icon,
              size: 20,
              color:
                  isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                forma.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : AppColors.outlineVariant,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
