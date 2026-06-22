import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Seção de endereço reutilizada nos passos Remetente e Destinatário.
/// Inclui campo CEP com botão de busca e mini-preview de mapa stub.
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
    this.onBuscarCep,
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
  final VoidCallback? onBuscarCep;

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

        // CEP + busca
        Row(
          children: [
            Expanded(
              child: _FormField(
                hint: 'CEP',
                controller: cepController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            _CepSearchButton(onTap: onBuscarCep),
          ],
        ),
        const SizedBox(height: 10),

        // Logradouro + Número
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _FormField(
                hint: 'Logradouro',
                controller: logradouroController,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FormField(
                hint: 'Nº',
                controller: numeroController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Complemento + Bairro
        Row(
          children: [
            Expanded(
              child: _FormField(
                hint: 'Comp.',
                controller: complementoController,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FormField(
                hint: 'Bairro',
                controller: bairroController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Cidade + UF
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _FormField(
                hint: 'Cidade',
                controller: cidadeController,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _FormField(
                hint: 'UF',
                controller: ufController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Mini-mapa stub
        _MapPreviewStub(),
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

class _CepSearchButton extends StatelessWidget {
  const _CepSearchButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryYellow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.search, color: AppColors.onSurface, size: 22),
      ),
    );
  }
}

/// Placeholder de mapa (mesmo padrão do `LocalizacaoPreview`).
class _MapPreviewStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 110,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _MapPainter()),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.white.withValues(alpha: 0.92),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.location_on, size: 14, color: AppColors.error),
                    SizedBox(width: 4),
                    Text(
                      'CONFIRME NO MAPA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE3E8F0),
    );
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;
    const step = 20.0;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.4),
      7,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
}
