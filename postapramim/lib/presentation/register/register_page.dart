import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/router/app_routes.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_state.dart';
import 'package:posta_pra_mim/presentation/shared/widgets/app_text_field.dart';
import 'package:posta_pra_mim/presentation/shared/widgets/auth_header.dart';

/// Máscara simples de telefone brasileiro: (00) 00000-0000.
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7 && limited.length > 10) buffer.write('-');
      if (i == 6 && limited.length <= 10) buffer.write('-');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Tela de cadastro. Não chama rede/IO diretamente — delega ao
/// `AuthController` injetado via Provider.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = context.read<AuthController>();
    await controller.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    final state = controller.state;
    if (state is AuthAuthenticated) {
      context.go(AppRoutes.homeForRole(state.user.role));
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu nome completo.';
    }
    if (!value.trim().contains(' ')) {
      return 'Informe nome e sobrenome.';
    }
    return null;
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

  String? _validatePhone(String? value) {
    final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.length < 10) {
      return 'Informe um telefone válido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Crie uma senha.';
    }
    if (value.length < 8) {
      return 'Mínimo de 8 caracteres.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Repita sua senha.';
    }
    if (value != _passwordController.text) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  void _goToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(
          color: AppColors.onSurface,
          onPressed: _goToLogin,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Consumer<AuthController>(
          builder: (context, controller, _) {
            final state = controller.state;
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthHeader(
                        title: 'Criar Conta',
                        subtitle: 'Preencha os dados abaixo para começar',
                        subtitleColor: AppColors.error,
                        logoWidth: 130,
                      ),
                      const SizedBox(height: 28),
                      AppTextField(
                        controller: _nameController,
                        label: 'Nome Completo',
                        icon: Icons.person_outline,
                        hintText: 'Ex: João Silva',
                        keyboardType: TextInputType.name,
                        autofillHints: const [AutofillHints.name],
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: 'E-mail',
                        icon: Icons.mail_outline,
                        hintText: 'nome@email.com',
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Telefone',
                        icon: Icons.phone_outlined,
                        hintText: '(00) 00000-0000',
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        inputFormatters: [_PhoneInputFormatter()],
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        icon: Icons.lock_outline,
                        hintText: 'Mínimo 8 caracteres',
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: _validatePassword,
                        suffixIcon: PasswordVisibilityToggle(
                          onChanged: (visible) {
                            setState(() => _obscurePassword = !visible);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar Senha',
                        icon: Icons.lock_reset_outlined,
                        hintText: 'Repita sua senha',
                        obscureText: _obscureConfirmPassword,
                        autofillHints: const [AutofillHints.newPassword],
                        validator: _validateConfirmPassword,
                        onFieldSubmitted: (_) => _submit(),
                        suffixIcon: PasswordVisibilityToggle(
                          onChanged: (visible) {
                            setState(() => _obscureConfirmPassword = !visible);
                          },
                        ),
                      ),
                      if (state is AuthError) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.failure.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
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
                                  Text('Cadastrar'),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Já tem uma conta? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: _goToLogin,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(48, 36),
                            ),
                            child: const Text(
                              'Fazer login',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
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
