import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Cartão branco com CTA principal e link secundário de login.
/// Widget puramente apresentacional — toda navegação é delegada
/// via callbacks, nunca chamada diretamente daqui.
class SplashActionCard extends StatelessWidget {
  const SplashActionCard({
    required this.onGetStarted,
    required this.onLogin,
    super.key,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGetStarted,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Começar agora'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Já possui uma conta?',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onLogin,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Fazer login'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
