import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Prévia de mapa para confirmar endereço digitado.
///
/// STUB visual — mesmo padrão de `LocalizacaoPreview`. Para ativar um
/// mapa real, substitua o `CustomPaint` por `google_maps_flutter` ou
/// `flutter_map` centrado no endereço buscado.
class MapaPreviewStub extends StatelessWidget {
  const MapaPreviewStub({super.key});

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
            CustomPaint(painter: _MapGridPainter()),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 14, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'CONFIRME NO MAPA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.4,
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

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFD8E4F0),
    );

    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    final blockPaint = Paint()..color = const Color(0xFFC5D8E8);

    for (var y = 20.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), streetPaint);
    }
    for (var x = 30.0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), streetPaint);
    }
    for (var x = 0.0; x < size.width; x += 48) {
      for (var y = 0.0; y < size.height; y += 28) {
        canvas.drawRect(Rect.fromLTWH(x + 2, y + 2, 44, 24), blockPaint);
      }
    }

    // Pin
    final pinX = size.width * 0.55;
    final pinY = size.height * 0.38;
    canvas.drawCircle(
      Offset(pinX, pinY),
      9,
      Paint()..color = AppColors.primary,
    );
    canvas.drawCircle(
      Offset(pinX, pinY),
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter old) => false;
}
