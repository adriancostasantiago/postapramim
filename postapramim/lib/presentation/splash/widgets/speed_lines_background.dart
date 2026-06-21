import 'package:flutter/material.dart';

/// Recria as "speed lines" do fundo da splash original (SVG com
/// stroke-dasharray animado). Usa um `AnimationController` único e
/// um `CustomPainter`, evitando rebuilds de widgets — apenas repaint.
class SpeedLinesBackground extends StatefulWidget {
  const SpeedLinesBackground({super.key});

  @override
  State<SpeedLinesBackground> createState() => _SpeedLinesBackgroundState();
}

class _SpeedLinesBackgroundState extends State<SpeedLinesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpeedLinesPainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SpeedLinesPainter extends CustomPainter {
  const _SpeedLinesPainter({required this.progress});

  final double progress;

  // Replica as 4 curvas do SVG original (viewBox 400x800), cada uma
  // com seu próprio delay relativo de animação.
  static const _curves = [
    _SpeedLineSpec(
      start: Offset(-50, 200),
      control: Offset(150, 250),
      end: Offset(450, 150),
      delay: 0,
    ),
    _SpeedLineSpec(
      start: Offset(-100, 350),
      control: Offset(200, 400),
      end: Offset(500, 300),
      delay: 1.5,
    ),
    _SpeedLineSpec(
      start: Offset(-20, 500),
      control: Offset(180, 550),
      end: Offset(420, 450),
      delay: 0.7,
    ),
    _SpeedLineSpec(
      start: Offset(-80, 650),
      control: Offset(220, 700),
      end: Offset(520, 600),
      delay: 2.2,
    ),
  ];

  static const _durationSeconds = 3.0;
  static const _dashLength = 100.0;
  static const _gapLength = 400.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 400;
    final scaleY = size.height / 800;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (final spec in _curves) {
      final path = Path()
        ..moveTo(spec.start.dx * scaleX, spec.start.dy * scaleY)
        ..quadraticBezierTo(
          spec.control.dx * scaleX,
          spec.control.dy * scaleY,
          spec.end.dx * scaleX,
          spec.end.dy * scaleY,
        );

      final localProgress = ((progress * _durationSeconds + spec.delay) %
              _durationSeconds) /
          _durationSeconds;

      canvas.drawPath(
        _dashedSegment(path, localProgress),
        paint,
      );
    }
  }

  /// Extrai o segmento visível do path para simular `stroke-dashoffset`.
  Path _dashedSegment(Path source, double localProgress) {
    final metric = source.computeMetrics().first;
    final total = metric.length;
    final dashStart = (localProgress * total) % total;
    final dashEnd = (dashStart + _dashLength).clamp(0, total).toDouble();
    return metric.extractPath(dashStart, dashEnd);
  }

  @override
  bool shouldRepaint(covariant _SpeedLinesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _SpeedLineSpec {
  const _SpeedLineSpec({
    required this.start,
    required this.control,
    required this.end,
    required this.delay,
  });

  final Offset start;
  final Offset control;
  final Offset end;
  final double delay;
}
