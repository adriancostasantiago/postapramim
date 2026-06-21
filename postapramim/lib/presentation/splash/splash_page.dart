import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/router/app_routes.dart';
import 'package:posta_pra_mim/core/theme/app_assets.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_state.dart';
import 'package:posta_pra_mim/presentation/splash/widgets/animated_logo.dart';
import 'package:posta_pra_mim/presentation/splash/widgets/speed_lines_background.dart';
import 'package:posta_pra_mim/presentation/splash/widgets/splash_action_card.dart';

/// Tela de splash. Não chama rede/IO diretamente — delega a checagem
/// de sessão ao `AuthController` injetado via Provider.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Sessão é checada uma única vez ao montar a tela — não no build().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthController>().checkSession();
    });
  }

  void _goToRegister() => context.go(AppRoutes.register);

  void _goToLogin() => context.go(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: Consumer<AuthController>(
        builder: (context, controller, _) {
          _handleAuthStateNavigation(context, controller.state);

          return Stack(
            children: [
              const Positioned.fill(child: SpeedLinesBackground()),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AnimatedLogo(imageUrl: AppAssets.logoUrl),
                          const SizedBox(height: 32),
                          _SplashHeadline(
                            isLoading: controller.state is AuthLoading,
                          ),
                          const SizedBox(height: 32),
                          SplashActionCard(
                            onGetStarted: _goToRegister,
                            onLogin: _goToLogin,
                          ),
                          const SizedBox(height: 24),
                          const _SplashFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Centraliza o redirect pós-checagem de sessão. Evita navegação
  /// duplicada usando `addPostFrameCallback` + guarda de estado.
  void _handleAuthStateNavigation(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      final destination = AppRoutes.homeForRole(state.user.role);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(destination);
      });
    } else if (state is AuthUnauthenticated || state is AuthError) {
      // Usuário sem sessão permanece na splash para escolher uma ação;
      // não força navegação automática para não surpreender o usuário.
    }
  }
}

class _SplashHeadline extends StatelessWidget {
  const _SplashHeadline({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          'Sua encomenda em boas mãos.',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Logística inteligente e simplificada para você focar no que '
            'realmente importa.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
            ),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 16),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
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
              color: AppColors.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 8),
            Text(
              'v1.2.0',
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 1,
              color: AppColors.onSurface.withValues(alpha: 0.2),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '© 2024 POSTA PRA MIM LOGÍSTICA',
          style: textTheme.labelMedium?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
