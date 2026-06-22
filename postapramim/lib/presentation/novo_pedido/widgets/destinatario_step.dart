import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'endereco_form_section.dart';

/// Passo 2: Identificação e endereço de entrega do destinatário.
/// Mesmo layout do `RemetenteStep`, mas com label "Endereço de Entrega".
class DestinatarioStep extends StatelessWidget {
  const DestinatarioStep({required this.data, super.key});

  final DestinatarioStepData data;

  @override
  Widget build(BuildContext context) {
    final d = data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Identificação do Destinatário',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _FormField(
          hint: 'Nome Completo / Razão Social',
          controller: d.nomeController,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 10),
        _FormField(
          hint: 'CPF ou CNPJ',
          controller: d.cpfCnpjController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 10),
        _FormField(
          hint: 'Telefone de Contato',
          controller: d.telefoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        EnderecoFormSection(
          titulo: 'Endereço de Entrega',
          cepController: d.cepController,
          logradouroController: d.logradouroController,
          numeroController: d.numeroController,
          complementoController: d.complementoController,
          bairroController: d.bairroController,
          cidadeController: d.cidadeController,
          ufController: d.ufController,
          onBuscarCep: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Busca por CEP em breve.')),
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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

class DestinatarioStepData {
  DestinatarioStepData();

  final nomeController = TextEditingController();
  final cpfCnpjController = TextEditingController();
  final telefoneController = TextEditingController();
  final cepController = TextEditingController();
  final logradouroController = TextEditingController();
  final numeroController = TextEditingController();
  final complementoController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final ufController = TextEditingController();

  void dispose() {
    nomeController.dispose();
    cpfCnpjController.dispose();
    telefoneController.dispose();
    cepController.dispose();
    logradouroController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    ufController.dispose();
  }
}
