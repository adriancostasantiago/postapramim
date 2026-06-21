import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/router/app_routes.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_state.dart';
import 'package:posta_pra_mim/presentation/shared/widgets/app_text_field.dart';
import 'package:posta_pra_mim/presentation/shared/widgets/auth_header.dart';
import 'package:posta_pra_mim/presentation/shared/widgets/google_logo.dart';

/// Tela de login. Não chama rede/IO diretamente — delega autenticação
/// ao `AuthController` injetado via Provider.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    // if (!(_formKey.currentState?.validate() ?? false)) return;

    // final controller = context.read<AuthController>();
    // await controller.login(
    //   email: _emailController.text.trim(),
    //   password: _passwordController.text,
    // );

    // if (!mounted) return;
    // final state = controller.state;
    // if (state is AuthAuthenticated) {
    //   context.go(AppRoutes.homeForRole(state.user.role));
    // }
    context.go(AppRoutes.managerDashboard);
  }

  Future<void> _submitGoogleSignIn() async {
    final controller = context.read<AuthController>();
    await controller.signInWithGoogle();

    if (!mounted) return;
    final state = controller.state;
    if (state is AuthAuthenticated) {
      context.go(AppRoutes.homeForRole(state.user.role));
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu e-mail.';
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe sua senha.';
    }
    return null;
  }

  void _goToForgotPassword() {
    // TODO: implementar fluxo de recuperação de senha quando o
    // endpoint correspondente estiver disponível no backend.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recuperação de senha em breve.')),
    );
  }

  void _goToRegister() => context.push(AppRoutes.register);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Consumer<AuthController>(
          builder: (context, controller, _) {
            final state = controller.state;
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        title: 'Posta Pra Mim',
                        subtitle: 'Logística eficiente para um mundo conectado',
                      ),
                      const SizedBox(height: 32),
                      AppTextField(
                        controller: _emailController,
                        icon: Icons.mail_outline,
                        hintText: 'E-mail',
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        hintText: 'Senha',
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        validator: _validatePassword,
                        onFieldSubmitted: (_) => _submitLogin(),
                        suffixIcon: PasswordVisibilityToggle(
                          onChanged: (visible) {
                            setState(() => _obscurePassword = !visible);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _goToForgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(48, 36),
                          ),
                          child: const Text(
                            'Esqueci minha senha',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      if (state is AuthError) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.failure.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isLoading ? null : _submitLogin,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('Entrar'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                      const SizedBox(height: 20),
                      const _OrDivider(),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: isLoading ? null : _submitGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.outlineVariant),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            GoogleLogo(size: 18),
                            SizedBox(width: 10),
                            Text(
                              'Entrar com Google',
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _goToRegister,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Criar Conta',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const _LoginFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ou',
            style: TextStyle(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.outlineVariant)),
      ],
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 32, height: 1, color: AppColors.outlineVariant),
            const SizedBox(width: 8),
            Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 32, height: 1, color: AppColors.outlineVariant),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '© 2024 POSTA PRA MIM LOGÍSTICA',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
