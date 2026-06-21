import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:posta_pra_mim/core/theme/app_assets.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';

/// Cabeçalho com logo, título e subtítulo — reutilizado nas telas
/// de login e cadastro para manter consistência visual.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    required this.title,
    required this.subtitle,
    this.subtitleColor,
    this.logoWidth = 140,
    super.key,
  });

  final String title;
  final String subtitle;
  final Color? subtitleColor;
  final double logoWidth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          width: logoWidth,
          child: CachedNetworkImage(
            imageUrl: AppAssets.logoUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => SizedBox(
              height: logoWidth * 0.4,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.local_shipping_outlined,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            fontSize: 13,
            color: subtitleColor ?? AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
