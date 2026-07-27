import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/utils/validators.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/shared/widgets/app_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(email: _emailCtrl.text.trim(), senha: _senhaCtrl.text);
  }

  Future<void> _loginComGoogle() async {
    await ref.read(authControllerProvider.notifier).loginComGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (!mounted || next.erro == null || next.erro == previous?.erro) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(next.erro!)));
    });

    return Scaffold(
      backgroundColor: AppColors.branco,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset('assets/images/logo.png', height: 56),
                    ),
                    Image.asset(
                      'assets/images/login.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    // const SizedBox(height: 4),
                    Text(
                      'Que bom te ver de novo!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titulo.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Faça login para acompanhar suas devoluções\ne histórico de solicitações.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.corpo.copyWith(
                        fontSize: 14,
                        color: AppColors.cinzaTexto,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _CampoComIcone(
                      label: 'E-mail',
                      controller: _emailCtrl,
                      hint: 'Digite seu e-mail',
                      icone: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 20),
                    _CampoComIcone(
                      label: 'Senha',
                      controller: _senhaCtrl,
                      hint: 'Digite sua senha',
                      icone: Icons.lock_outline,
                      obscureText: _obscure,
                      validator: Validators.senha,
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.cinzaTexto,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authState.carregando
                            ? null
                            : () => context.push(RoutePaths.recuperarSenha),
                        child: Text(
                          'Esqueci minha senha',
                          style: AppTextStyles.corpo.copyWith(
                            color: AppColors.azulInstitucional,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Entrar',
                      carregando: authState.carregando,
                      onPressed: _entrar,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: AppColors.cinzaBorda),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('ou', style: AppTextStyles.legenda),
                        ),
                        const Expanded(
                          child: Divider(color: AppColors.cinzaBorda),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: authState.carregando
                            ? null
                            : _loginComGoogle,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/google.png',
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Entrar com Google',
                              style: AppTextStyles.botao,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _CadastroCard(carregando: authState.carregando),
                    const SizedBox(height: 20),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Ao continuar, você concorda com nossos ',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.legenda,
                          ),
                          _LinkTexto(texto: 'Termos de Uso', onPressed: () {}),
                          Text(' e ', style: AppTextStyles.legenda),
                          _LinkTexto(
                            texto: 'Política de Privacidade',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 8,
              child: IconButton(
                tooltip: 'Voltar',
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.azulInstitucional,
                ),
                onPressed: () => context.pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoComIcone extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icone;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _CampoComIcone({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icone,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.subtitulo.copyWith(fontSize: 15)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.corpo,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.corpo.copyWith(
              color: AppColors.cinzaTexto,
            ),
            prefixIcon: Icon(icone, color: AppColors.cinzaTexto),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.branco,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cinzaBorda),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cinzaBorda),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.azulInstitucional,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.erro),
            ),
          ),
        ),
      ],
    );
  }
}

class _CadastroCard extends StatelessWidget {
  final bool carregando;

  const _CadastroCard({required this.carregando});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: carregando ? null : () => context.push(RoutePaths.cadastro),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.amarelo.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.amarelo.withValues(alpha: .25),
                child: Image.asset(
                  'assets/icons/icone_solicitar_sem_cadastro.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ainda não tem uma conta?',
                      style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Crie sua conta e tenha acesso\nao histórico das suas devoluções.',
                      style: AppTextStyles.legenda,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.darkFundo),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkTexto extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const _LinkTexto({required this.texto, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        texto,
        style: AppTextStyles.legenda.copyWith(
          color: AppColors.azulInstitucional,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
