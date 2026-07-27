import 'package:flutter/material.dart';

/// Logo com duas animações compostas:
/// - `entrance`: fade-in + scale 0.9→1, 1.2s, easing customizado
/// - `float`: translateY contínuo, 4s, ida-e-volta infinita
///
/// Adaptado para usar um asset local (`Image.asset`) em vez de imagem de
/// rede, já que o projeto guarda o logo em `assets/images/logo.png`.
class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({required this.imagePath, this.width = 180, super.key});

  final String imagePath;
  final double width;

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _entranceOpacity;
  late final Animation<double> _entranceScale;

  late final AnimationController _floatController;
  late final Animation<double> _floatOffset;

  @override
  void initState() {
    super.initState();

    // entrance: 1.2s, cubic-bezier(0.22, 1, 0.36, 1)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    final entranceCurve = CurvedAnimation(
      parent: _entranceController,
      curve: const Cubic(0.22, 1, 0.36, 1),
    );
    _entranceOpacity = Tween<double>(begin: 0, end: 1).animate(entranceCurve);
    _entranceScale = Tween<double>(begin: 0.9, end: 1).animate(entranceCurve);

    // float: 4s ease-in-out, infinito, ida-e-volta (translateY 0 → -8 → 0)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _floatOffset = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _floatController]),
      builder: (context, child) {
        return Opacity(
          opacity: _entranceOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _floatOffset.value),
            child: Transform.scale(
              scale: _entranceScale.value,
              child: child,
            ),
          ),
        );
      },
      child: SizedBox(
        width: widget.width,
        child: Image.asset(widget.imagePath, fit: BoxFit.contain),
      ),
    );
  }
}
