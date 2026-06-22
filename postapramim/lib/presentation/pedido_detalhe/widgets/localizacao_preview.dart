import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/domain/entities/pedido_detalhe.dart';

/// Prévia estática da localização atual do pacote.
///
/// STUB visual — desenha um placeholder simples em vez de embutir um
/// SDK de mapas real (mesmo espírito de `GoogleAuthDataSourceStub`).
/// Para ativar de verdade: adicione `google_maps_flutter` (ou
/// equivalente) ao `pubspec.yaml` e troque o `CustomPaint` abaixo por
/// um `GoogleMap` centrado em [localizacao.latitude]/[longitude].
class LocalizacaoPreview extends StatelessWidget {
  const LocalizacaoPreview({required this.localizacao, super.key});

  final LocalizacaoPacote localizacao;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _MapPlaceholderPainter()),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        localizacao.descricao,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
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

/// Desenha um padrão simples de "quarteirões" para simular um mapa
/// sem depender de um SDK real (ver doc da classe acima).
class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE3E8F0),
    );

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5;

    const step = 24.0;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.45),
      6,
      Paint()..color = AppColors.primary,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPlaceholderPainter oldDelegate) => false;
}
