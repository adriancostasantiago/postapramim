import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/presentation/auth/widgets/animated_logo.dart';
import 'package:postapramim/presentation/auth/widgets/speed_lines_background.dart';
import 'package:postapramim/presentation/auth/widgets/splash_loading_card.dart';

/// Tela de splash. Mantém a mesma lógica de decisão de rota da versão
/// anterior (via [authControllerProvider] + GoRouter), só que com o
/// visual novo: logo animado, speed lines de fundo e, no lugar do card
/// com botões de "Começar agora"/"Fazer login", um card de loading —
/// já que aqui a splash não pede nenhuma ação do usuário, apenas decide
/// para onde ele vai.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decidirRota());
  }

  Future<void> _decidirRota() async {
    // Um pouco mais longo que antes (era 800ms) para dar tempo da
    // animação de entrada do logo e do card de loading aparecerem bem.
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    final usuario = authState.usuario;

    if (usuario == null) {
      context.go(RoutePaths.boasVindas);
      return;
    }

    final destino = switch (usuario.perfil) {
      PerfilUsuario.cliente => RoutePaths.clienteHome,
      PerfilUsuario.coletador => RoutePaths.coletadorDashboard,
      PerfilUsuario.administrador => RoutePaths.adminDashboard,
    };
    context.go(destino);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.amarelo,
      body: Stack(
        children: [
          const Positioned.fill(child: SpeedLinesBackground()),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo e textos ficam mais acima
                    const AnimatedLogo(imagePath: 'assets/images/logo.png'),
                    const SizedBox(height: 32),
                    const _SplashHeadline(),

                    // Empurra o loading para baixo
                    const Spacer(flex: 3),

                    // Loading no final
                    const SplashLoadingCard(),

                    const SizedBox(height: 24),

                    // Footer colado no fim da página
                    const _SplashFooter(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashHeadline extends StatelessWidget {
  const _SplashHeadline();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const Icon(
          Icons.local_shipping_outlined,
          color: AppColors.amarelo,
          size: 56,
        ),
        const SizedBox(height: 12),
        Text(
          'Sua encomenda em boas mãos',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 25,
            color: AppColors.darkFundo,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Logística inteligente e simplificada para você focar no que realmente importa.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.darkFundo.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashFooter extends StatelessWidget {
  const _SplashFooter();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 1,
              color: AppColors.darkFundo.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 8),
            Text(
              'v${AppConstants.versaoApp}',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.darkFundo.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 1,
              color: AppColors.darkFundo.withValues(alpha: 0.2),
            ),
          ],
        ),
        Text(
          '© 2026 POSTA PRA MIM LOGÍSTICA',
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.darkFundo.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
