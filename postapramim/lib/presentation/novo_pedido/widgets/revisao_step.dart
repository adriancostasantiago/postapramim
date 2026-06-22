import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/core/utils/currency_formatter.dart';
import 'carga_step.dart';
import 'destinatario_step.dart';
import 'remetente_step.dart';

enum FormaPagamentoNovo { cartao, pix, boleto }

/// Passo 4: Revisão do pedido — mostra resumo de todas as etapas
/// e permite selecionar forma de pagamento antes de finalizar.
class RevisaoStep extends StatefulWidget {
  const RevisaoStep({
    required this.remetente,
    required this.destinatario,
    required this.carga,
    super.key,
  });

  final RemetenteStepData remetente;
  final DestinatarioStepData destinatario;
  final CargaStepData carga;

  @override
  State<RevisaoStep> createState() => RevisaoStepState();
}

class RevisaoStepState extends State<RevisaoStep> {
  FormaPagamentoNovo _pagamento = FormaPagamentoNovo.cartao;

  FormaPagamentoNovo get selectedPagamento => _pagamento;

  static const double _valorFrete = 45.90;

  @override
  Widget build(BuildContext context) {
    final r = widget.remetente;
    final d = widget.destinatario;
    final c = widget.carga;

    final nomeRemetente = r.nomeController.text.isEmpty
        ? 'Não informado'
        : r.nomeController.text;
    final endRemetente = _buildEndereco(r.logradouroController.text,
        r.numeroController.text, r.cidadeController.text, r.ufController.text);

    final nomeDestinatario = d.nomeController.text.isEmpty
        ? 'Não informado'
        : d.nomeController.text;
    final endDestinatario = _buildEndereco(d.logradouroController.text,
        d.numeroController.text, d.cidadeController.text, d.ufController.text);

    final tipoCargaLabel = switch (c.tipoCarga) {
      TipoCarga.caixa => 'Caixa',
      TipoCarga.envelope => 'Envelope',
      TipoCarga.pallet => 'Pallet',
    };
    final pesoLabel = c.pesoController.text.isEmpty
        ? '—'
        : '${c.pesoController.text} kg';
    final dimLabel = _buildDimensoes(c.larguraController.text,
        c.alturaController.text, c.comprimentoController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Remetente
        _ReviewSection(
          title: 'REMETENTE',
          onEdit: () => _notifyEdit(context, 0),
          child: _ReviewSectionContent(
            title: nomeRemetente,
            subtitle: endRemetente,
          ),
        ),
        const SizedBox(height: 12),

        // Destinatário
        _ReviewSection(
          title: 'DESTINATÁRIO',
          onEdit: () => _notifyEdit(context, 1),
          child: _ReviewSectionContent(
            title: nomeDestinatario,
            subtitle: endDestinatario,
          ),
        ),
        const SizedBox(height: 12),

        // Carga
        _ReviewSection(
          title: 'INFORMAÇÕES DA CARGA',
          onEdit: () => _notifyEdit(context, 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _InfoPair(label: 'Tipo', value: tipoCargaLabel),
                  const SizedBox(width: 24),
                  _InfoPair(label: 'Peso', value: pesoLabel),
                ],
              ),
              if (dimLabel.isNotEmpty) ...[
                const SizedBox(height: 6),
                _InfoPair(label: 'Dimensões', value: dimLabel),
              ],
              if (c.fragil || c.urgente) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (c.fragil)
                      _TagBadge(
                        label: 'Carga Frágil',
                        icon: Icons.favorite_border,
                        color: AppColors.error,
                        background: AppColors.errorContainer,
                      ),
                    if (c.urgente)
                      _TagBadge(
                        label: 'Envio Urgente',
                        icon: Icons.bolt,
                        color: const Color(0xFF8B6914),
                        background: const Color(0xFFFFF4D6),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Forma de pagamento
        const Text(
          'Forma de Pagamento',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _PaymentOption(
          icon: Icons.credit_card_outlined,
          label: 'Cartão de Crédito',
          selected: _pagamento == FormaPagamentoNovo.cartao,
          onTap: () => setState(() => _pagamento = FormaPagamentoNovo.cartao),
        ),
        const SizedBox(height: 8),
        _PaymentOption(
          icon: Icons.pix,
          label: 'Pix',
          selected: _pagamento == FormaPagamentoNovo.pix,
          onTap: () => setState(() => _pagamento = FormaPagamentoNovo.pix),
        ),
        const SizedBox(height: 8),
        _PaymentOption(
          icon: Icons.receipt_long_outlined,
          label: 'Boleto Bancário',
          selected: _pagamento == FormaPagamentoNovo.boleto,
          onTap: () => setState(() => _pagamento = FormaPagamentoNovo.boleto),
        ),
        const SizedBox(height: 20),

        // Valor total
        Container(
          width: double.infinity,
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
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(_valorFrete),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _notifyEdit(BuildContext context, int step) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar passo ${step + 1}')),
    );
  }

  String _buildEndereco(
      String logradouro, String numero, String cidade, String uf) {
    final parts = [
      if (logradouro.isNotEmpty) '$logradouro${numero.isNotEmpty ? ", $numero" : ""}',
      if (cidade.isNotEmpty) '$cidade${uf.isNotEmpty ? " - $uf" : ""}',
    ];
    return parts.isEmpty ? 'Endereço não informado' : parts.join(' · ');
  }

  String _buildDimensoes(String l, String a, String c) {
    if (l.isEmpty && a.isEmpty && c.isEmpty) return '';
    return '${l.isEmpty ? "?" : l} × ${a.isEmpty ? "?" : a} × ${c.isEmpty ? "?" : c} cm';
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.child,
    this.onEdit,
  });

  final String title;
  final Widget child;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ReviewSectionContent extends StatelessWidget {
  const _ReviewSectionContent({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _InfoPair extends StatelessWidget {
  const _InfoPair({required this.label, required this.value});

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
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
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

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: selected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
