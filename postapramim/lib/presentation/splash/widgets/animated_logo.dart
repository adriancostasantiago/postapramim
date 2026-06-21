import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Logo com duas animações compostas, replicando o CSS original:
/// - `logo-entrance`: fade-in + scale 0.9→1, 1.2s, easing customizado
/// - `float`: translateY contínuo, 4s, ida-e-volta infinita
///
/// Extraído como widget próprio (não método `_build*`) para isolar
/// o rebuild boundary das animações do resto da splash.
class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({required this.imageUrl, super.key});

  final String imageUrl;

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

    // logo-entrance: 1.2s, cubic-bezier(0.22, 1, 0.36, 1) ~ easeOutExpo-like
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
        width: 256,
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => const SizedBox(
            height: 96,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.local_shipping_outlined,
            size: 96,
          ),
        ),
      ),
    );
  }
}
