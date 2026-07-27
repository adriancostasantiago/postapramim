import 'package:flutter/material.dart';

enum AppButtonVariant { primario, secundario, texto }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool carregando;
  final AppButtonVariant variant;
  final IconData? icone;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.carregando = false,
    this.variant = AppButtonVariant.primario,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final child = carregando
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icone != null) ...[Icon(icone, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final onTap = carregando ? null : onPressed;

    return switch (variant) {
      AppButtonVariant.primario => ElevatedButton(onPressed: onTap, child: child),
      AppButtonVariant.secundario => OutlinedButton(onPressed: onTap, child: child),
      AppButtonVariant.texto => TextButton(onPressed: onTap, child: child),
    };
  }
}
