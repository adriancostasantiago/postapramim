import 'package:flutter/material.dart';

/// Logo oficial do Google desenhado via `CustomPainter`, evitando
/// depender de um asset de imagem só para este ícone de 18x18.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({this.size = 18, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48;
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF4285F4);
    canvas.drawPath(
      Path()
        ..moveTo(45.12 * s, 24.5 * s)
        ..cubicTo(45.12 * s, 22.82 * s, 44.96 * s, 21.21 * s, 44.68 * s, 19.65 * s)
        ..lineTo(24 * s, 19.65 * s)
        ..lineTo(24 * s, 28.81 * s)
        ..lineTo(35.94 * s, 28.81 * s)
        ..cubicTo(35.41 * s, 31.55 * s, 33.85 * s, 33.87 * s, 31.52 * s, 35.45 * s)
        ..lineTo(31.52 * s, 41.05 * s)
        ..lineTo(38.62 * s, 41.05 * s)
        ..cubicTo(42.78 * s, 37.22 * s, 45.12 * s, 31.39 * s, 45.12 * s, 24.5 * s)
        ..close(),
      paint,
    );

    paint.color = const Color(0xFF34A853);
    canvas.drawPath(
      Path()
        ..moveTo(24 * s, 46 * s)
        ..cubicTo(29.78 * s, 46 * s, 34.62 * s, 44.1 * s, 38.62 * s, 41.05 * s)
        ..lineTo(31.52 * s, 35.45 * s)
        ..cubicTo(29.6 * s, 36.74 * s, 27.14 * s, 37.5 * s, 24 * s, 37.5 * s)
        ..cubicTo(18.45 * s, 37.5 * s, 13.75 * s, 33.74 * s, 12.06 * s, 28.69 * s)
        ..lineTo(4.73 * s, 28.69 * s)
        ..lineTo(4.73 * s, 34.46 * s)
        ..cubicTo(8.71 * s, 42.31 * s, 15.83 * s, 46 * s, 24 * s, 46 * s)
        ..close(),
      paint,
    );

    paint.color = const Color(0xFFFBBC05);
    canvas.drawPath(
      Path()
        ..moveTo(12.06 * s, 28.69 * s)
        ..cubicTo(11.66 * s, 27.4 * s, 11.43 * s, 26.03 * s, 11.43 * s, 24.6 * s)
        ..cubicTo(11.43 * s, 23.18 * s, 11.66 * s, 21.81 * s, 12.06 * s, 20.52 * s)
        ..lineTo(12.06 * s, 14.75 * s)
        ..lineTo(4.73 * s, 14.75 * s)
        ..cubicTo(3.21 * s, 17.66 * s, 2.36 * s, 21.03 * s, 2.36 * s, 24.6 * s)
        ..cubicTo(2.36 * s, 28.17 * s, 3.21 * s, 31.55 * s, 4.73 * s, 34.46 * s)
        ..lineTo(12.06 * s, 28.69 * s)
        ..close(),
      paint,
    );

    paint.color = const Color(0xFFEA4335);
    canvas.drawPath(
      Path()
        ..moveTo(24 * s, 11.7 * s)
        ..cubicTo(27.42 * s, 11.7 * s, 30.39 * s, 12.86 * s, 32.78 * s, 15.04 * s)
        ..lineTo(38.79 * s, 9.03 * s)
        ..cubicTo(34.61 * s, 5.14 * s, 29.78 * s, 2.6 * s, 24 * s, 2.6 * s)
        ..cubicTo(15.83 * s, 2.6 * s, 8.71 * s, 6.3 * s, 4.73 * s, 14.75 * s)
        ..lineTo(12.06 * s, 20.52 * s)
        ..cubicTo(13.75 * s, 15.46 * s, 18.45 * s, 11.7 * s, 24 * s, 11.7 * s)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GoogleLogoPainter oldDelegate) => false;
}
