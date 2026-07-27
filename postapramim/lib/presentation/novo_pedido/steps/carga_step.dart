import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/domain/entities/novo_pedido.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/widgets/novo_pedido_text_field.dart';
import 'package:posta_pra_mim/presentation/shared/state/novo_pedido_controller.dart';

/// Etapa 3: tipo de carga, dimensões, flags de fragilidade/urgência
/// e observações opcionais.
class CargaStep extends StatefulWidget {
  const CargaStep({required this.formKey, this.dadosIniciais, super.key});

  final GlobalKey<FormState> formKey;
  final RascunhoCarga? dadosIniciais;

  @override
  State<CargaStep> createState() => CargaStepState();
}

class CargaStepState extends State<CargaStep> {
  TipoCarga _tipo = TipoCarga.caixa;
  late final TextEditingController _peso;
  late final TextEditingController _largura;
  late final TextEditingController _altura;
  late final TextEditingController _comprimento;
  bool _fragil = false;
  bool _urgente = false;
  late final TextEditingController _observacoes;

  @override
  void initState() {
    super.initState();
    final d = widget.dadosIniciais;
    _tipo = d?.tipo ?? TipoCarga.caixa;
    _peso = TextEditingController(text: d != null ? d.pesoKg.toString() : '');
    _largura =
        TextEditingController(text: d != null ? d.larguraCm.toString() : '');
    _altura =
        TextEditingController(text: d != null ? d.alturaCm.toString() : '');
    _comprimento = TextEditingController(
        text: d != null ? d.comprimentoCm.toString() : '');
    _fragil = d?.fragil ?? false;
    _urgente = d?.urgente ?? false;
    _observacoes = TextEditingController(text: d?.observacoes ?? '');
  }

  @override
  void dispose() {
    for (final c in [_peso, _largura, _altura, _comprimento, _observacoes]) {
      c.dispose();
    }
    super.dispose();
  }

  bool confirmarEAvancar() {
    if (!(widget.formKey.currentState?.validate() ?? false)) return false;
    context.read<NovoPedidoController>().confirmarCarga(
          RascunhoCarga(
            tipo: _tipo,
            pesoKg: double.parse(_peso.text.replaceAll(',', '.')),
            larguraCm: double.parse(_largura.text.replaceAll(',', '.')),
            alturaCm: double.parse(_altura.text.replaceAll(',', '.')),
            comprimentoCm: double.parse(_comprimento.text.replaceAll(',', '.')),
            fragil: _fragil,
            urgente: _urgente,
            observacoes: _observacoes.text.trim(),
          ),
        );
    return true;
  }

  String? _validarNumero(String? v) {
    if (v == null || v.trim().isEmpty) return 'Obrigatório';
    final parsed = double.tryParse(v.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return 'Valor inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          const Text(
            'O que você vai enviar?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          // Seletor de tipo
          Row(
            children: TipoCarga.values
                .map(
                  (tipo) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: tipo != TipoCarga.values.last ? 10 : 0,
                      ),
                      child: _TipoCard(
                        tipo: tipo,
                        isSelected: _tipo == tipo,
                        onTap: () => setState(() => _tipo = tipo),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Peso e Dimensões',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          NovoPedidoTextField(
            controller: _peso,
            hint: 'Peso (kg)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
            ],
            validator: _validarNumero,
          ),
          const SizedBox(height: 10),
          NovoPedidoTextField(
            controller: _largura,
            hint: 'Largura (cm)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
            ],
            validator: _validarNumero,
          ),
          const SizedBox(height: 10),
          NovoPedidoTextField(
            controller: _altura,
            hint: 'Altura (cm)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
            ],
            validator: _validarNumero,
          ),
          const SizedBox(height: 10),
          NovoPedidoTextField(
            controller: _comprimento,
            hint: 'Comprimento (cm)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
            ],
            validator: _validarNumero,
          ),
          const SizedBox(height: 20),
          _ToggleRow(
            icon: Icons.favorite_border,
            iconColor: AppColors.error,
            label: 'Carga Frágil',
            descricao: 'Requer manuseio especial',
            value: _fragil,
            onChanged: (v) => setState(() => _fragil = v),
          ),
          const SizedBox(height: 12),
          _ToggleRow(
            icon: Icons.bolt,
            iconColor: AppColors.primaryYellow,
            label: 'Envio Urgente',
            descricao: 'Prioridade na entrega',
            value: _urgente,
            onChanged: (v) => setState(() => _urgente = v),
          ),
          const SizedBox(height: 24),
          const Text(
            'Informações Adicionais (Opcional)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          NovoPedidoTextField(
            controller: _observacoes,
            hint: 'Observações sobre a carga, valor declarado, conteúdo, etc.',
            maxLines: 4,
            minLines: 4,
            keyboardType: TextInputType.multiline,
          ),
        ],
      ),
    );
  }
}

class _TipoCard extends StatelessWidget {
  const _TipoCard({
    required this.tipo,
    required this.isSelected,
    required this.onTap,
  });

  final TipoCarga tipo;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon => switch (tipo) {
        TipoCarga.caixa => Icons.inventory_2_outlined,
        TipoCarga.envelope => Icons.mail_outline,
        TipoCarga.pallet => Icons.view_module_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icon,
              size: 28,
              color:
                  isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              tipo.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.descricao,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String descricao;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
