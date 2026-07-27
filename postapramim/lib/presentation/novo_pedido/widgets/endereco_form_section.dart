import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/widgets/novo_pedido_text_field.dart';

/// Seção de endereço reutilizada nos passos de Remetente e Destinatário.
/// CEP com botão de busca, grid de campos e prévia de mapa.
/// A busca é delegada ao callback [onBuscarCep] — sem acoplamento ao
/// repositório ou controller.
class EnderecoFormSection extends StatelessWidget {
  const EnderecoFormSection({
    required this.titulo,
    required this.cepController,
    required this.logradouroController,
    required this.numeroController,
    required this.complementoController,
    required this.bairroController,
    required this.cidadeController,
    required this.ufController,
    required this.onBuscarCep,
    this.isBuscandoCep = false,
    super.key,
  });

  final String titulo;
  final TextEditingController cepController;
  final TextEditingController logradouroController;
  final TextEditingController numeroController;
  final TextEditingController complementoController;
  final TextEditingController bairroController;
  final TextEditingController cidadeController;
  final TextEditingController ufController;
  final VoidCallback onBuscarCep;
  final bool isBuscandoCep;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        // CEP + botão busca
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NovoPedidoTextField(
                controller: cepController,
                hint: 'CEP',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                validator: (v) {
                  final d = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                  return d.length != 8 ? 'CEP inválido' : null;
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isBuscandoCep ? null : onBuscarCep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: isBuscandoCep
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onSurface,
                        ),
                      )
                    : const Icon(Icons.search, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Logradouro + Nº
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: NovoPedidoTextField(
                controller: logradouroController,
                hint: 'Logradouro',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NovoPedidoTextField(
                controller: numeroController,
                hint: 'Nº',
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.trim().isEmpty ? 'Obr.' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Comp. + Bairro
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: NovoPedidoTextField(
                controller: complementoController,
                hint: 'Comp.',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NovoPedidoTextField(
                controller: bairroController,
                hint: 'Bairro',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Obrigatório' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Cidade + UF
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: NovoPedidoTextField(
                controller: cidadeController,
                hint: 'Cidade',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Obrigatório' : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NovoPedidoTextField(
                controller: ufController,
                hint: 'UF',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: (v) =>
                    v == null || v.trim().length != 2 ? 'UF inv.' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
