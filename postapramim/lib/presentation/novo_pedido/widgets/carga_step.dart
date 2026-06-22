import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Tipos de carga selecionáveis no passo 3.
enum TipoCarga { caixa, envelope, pallet }

/// Passo 3: Tipo, dimensões, peso, opções e observações da carga.
class CargaStep extends StatefulWidget {
  const CargaStep({required this.data, super.key});

  final CargaStepData data;

  @override
  State<CargaStep> createState() => _CargaStepState();
}

class _CargaStepState extends State<CargaStep> {
  CargaStepData get d => widget.data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tipo de carga
        const Text(
          'O que você vai enviar?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _TipoCard(
              icon: Icons.inbox_outlined,
              label: 'Caixa',
              selected: d.tipoCarga == TipoCarga.caixa,
              onTap: () => setState(() => d.tipoCarga = TipoCarga.caixa),
            ),
            const SizedBox(width: 10),
            _TipoCard(
              icon: Icons.mail_outline,
              label: 'Envelope',
              selected: d.tipoCarga == TipoCarga.envelope,
              onTap: () => setState(() => d.tipoCarga = TipoCarga.envelope),
            ),
            const SizedBox(width: 10),
            _TipoCard(
              icon: Icons.inventory_2_outlined,
              label: 'Pallet',
              selected: d.tipoCarga == TipoCarga.pallet,
              onTap: () => setState(() => d.tipoCarga = TipoCarga.pallet),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Peso e Dimensões
        const Text(
          'Peso e Dimensões',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _NumField(hint: 'Peso (kg)', controller: d.pesoController),
        const SizedBox(height: 10),
        _NumField(hint: 'Largura (cm)', controller: d.larguraController),
        const SizedBox(height: 10),
        _NumField(hint: 'Altura (cm)', controller: d.alturaController),
        const SizedBox(height: 10),
        _NumField(hint: 'Comprimento (cm)', controller: d.comprimentoController),
        const SizedBox(height: 20),

        // Carga Frágil toggle
        _ToggleRow(
          icon: Icons.favorite_border,
          iconColor: AppColors.error,
          title: 'Carga Frágil',
          subtitle: 'Requer manuseio especial',
          value: d.fragil,
          onChanged: (v) => setState(() => d.fragil = v),
        ),
        const SizedBox(height: 1),
        const Divider(height: 1),
        const SizedBox(height: 1),

        // Envio Urgente toggle
        _ToggleRow(
          icon: Icons.bolt,
          iconColor: AppColors.primaryYellow,
          title: 'Envio Urgente',
          subtitle: 'Prioridade na entrega',
          value: d.urgente,
          onChanged: (v) => setState(() => d.urgente = v),
        ),
        const SizedBox(height: 20),

        // Informações adicionais
        const Text(
          'Informações Adicionais (Opcional)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: d.observacoesController,
          maxLines: 4,
          style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText:
                'Observações sobre a carga, valor declarado, conteúdo, etc.',
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _TipoCard extends StatelessWidget {
  const _TipoCard({
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumField extends StatelessWidget {
  const _NumField({required this.hint, required this.controller});

  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
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

class CargaStepData {
  CargaStepData();

  TipoCarga tipoCarga = TipoCarga.caixa;
  bool fragil = false;
  bool urgente = false;

  final pesoController = TextEditingController();
  final larguraController = TextEditingController();
  final alturaController = TextEditingController();
  final comprimentoController = TextEditingController();
  final observacoesController = TextEditingController();

  void dispose() {
    pesoController.dispose();
    larguraController.dispose();
    alturaController.dispose();
    comprimentoController.dispose();
    observacoesController.dispose();
  }
}
