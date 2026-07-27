import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/utils/validators.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/shared/widgets/app_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cpfCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarSenhaCtrl = TextEditingController();

  bool _obscureSenha = true;
  bool _obscureConfirmar = true;

  // Perfil padrão do cadastro público (a tela não expõe seleção de perfil,
  // seguindo o mockup fornecido). Ajuste aqui caso deseje reintroduzir a
  // escolha entre "cliente" e "coletador".
  final String _perfil = 'cliente';

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cpfCtrl.dispose();
    _emailCtrl.dispose();
    _celularCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarSenhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .cadastrar(
          nome: _nomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          senha: _senhaCtrl.text,
          perfil: _perfil,
          cpf: _cpfCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
          celular: _celularCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
        );
  }

  Future<void> _cadastrarComGoogle() async {
    await ref.read(authControllerProvider.notifier).loginComGoogle();
  }

  void _irParaLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RoutePaths.login);
    }
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
                      'assets/images/cria_conta.png',
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      'Criar sua conta',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titulo.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preencha os dados abaixo para criar sua conta\ne acompanhar suas devoluções.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.corpo.copyWith(
                        fontSize: 14,
                        color: AppColors.cinzaTexto,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _CampoComIcone(
                      label: 'Nome completo',
                      controller: _nomeCtrl,
                      hint: 'Digite seu nome completo',
                      icone: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          Validators.obrigatorio(v, campo: 'Nome'),
                    ),
                    const SizedBox(height: 20),
                    _CampoComIcone(
                      label: 'CPF',
                      controller: _cpfCtrl,
                      hint: '000.000.000-00',
                      icone: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_CpfInputFormatter()],
                      validator: _validarCpf,
                    ),
                    const SizedBox(height: 20),
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
                      label: 'Celular',
                      controller: _celularCtrl,
                      hint: '(00) 00000-0000',
                      icone: Icons.smartphone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_CelularInputFormatter()],
                      validator: _validarCelular,
                    ),
                    const SizedBox(height: 20),
                    _CampoComIcone(
                      label: 'Senha',
                      controller: _senhaCtrl,
                      hint: 'Digite sua senha',
                      icone: Icons.lock_outline,
                      obscureText: _obscureSenha,
                      validator: Validators.senha,
                      suffixIcon: IconButton(
                        tooltip: _obscureSenha
                            ? 'Mostrar senha'
                            : 'Ocultar senha',
                        icon: Icon(
                          _obscureSenha
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.cinzaTexto,
                        ),
                        onPressed: () =>
                            setState(() => _obscureSenha = !_obscureSenha),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CampoComIcone(
                      label: 'Confirmar senha',
                      controller: _confirmarSenhaCtrl,
                      hint: 'Digite sua senha novamente',
                      icone: Icons.lock_outline,
                      obscureText: _obscureConfirmar,
                      validator: (v) {
                        final erroSenha = Validators.senha(v);
                        if (erroSenha != null) return erroSenha;
                        if (v != _senhaCtrl.text)
                          return 'As senhas não coincidem';
                        return null;
                      },
                      suffixIcon: IconButton(
                        tooltip: _obscureConfirmar
                            ? 'Mostrar senha'
                            : 'Ocultar senha',
                        icon: Icon(
                          _obscureConfirmar
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.cinzaTexto,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmar = !_obscureConfirmar,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.azulInstitucional.withValues(
                          alpha: .08,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 20,
                            color: AppColors.azulInstitucional,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Seus dados estão protegidos e utilizamos as '
                              'melhores práticas de segurança.',
                              style: AppTextStyles.legenda,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Criar conta',
                      carregando: authState.carregando,
                      onPressed: _cadastrar,
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
                            : _cadastrarComGoogle,
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
                              'Cadastrar com Google',
                              style: AppTextStyles.botao,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Já tem uma conta? ',
                            style: AppTextStyles.legenda,
                          ),
                          GestureDetector(
                            onTap: authState.carregando ? null : _irParaLogin,
                            child: Text(
                              'Fazer login',
                              style: AppTextStyles.legenda.copyWith(
                                color: AppColors.azulInstitucional,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

String? _validarCpf(String? value) {
  if (value == null || value.trim().isEmpty) return 'Informe seu CPF';
  final cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (cpf.length != 11) return 'CPF inválido';
  if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return 'CPF inválido';

  final numeros = cpf.split('').map(int.parse).toList();

  int calcularDigito(List<int> base) {
    var soma = 0;
    var peso = base.length + 1;
    for (final n in base) {
      soma += n * peso;
      peso--;
    }
    final resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }

  final digito1 = calcularDigito(numeros.sublist(0, 9));
  final digito2 = calcularDigito(numeros.sublist(0, 10));

  if (digito1 != numeros[9] || digito2 != numeros[10]) return 'CPF inválido';
  return null;
}

String? _validarCelular(String? value) {
  if (value == null || value.trim().isEmpty) return 'Informe seu celular';
  final digitos = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitos.length < 10 || digitos.length > 11) return 'Celular inválido';
  return null;
}

/// Formata o CPF no padrão 000.000.000-00 enquanto o usuário digita.
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length > 11) digitos = digitos.substring(0, 11);

    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      buffer.write(digitos[i]);
      if (i == 2 || i == 5) buffer.write('.');
      if (i == 8) buffer.write('-');
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Formata o celular no padrão (00) 00000-0000 (ou (00) 0000-0000 para fixo)
/// enquanto o usuário digita.
class _CelularInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length > 11) digitos = digitos.substring(0, 11);

    final buffer = StringBuffer();
    if (digitos.isNotEmpty) {
      buffer.write('(');
      buffer.write(
        digitos.substring(0, digitos.length >= 2 ? 2 : digitos.length),
      );
      if (digitos.length >= 2) buffer.write(') ');
    }

    if (digitos.length > 2) {
      final restante = digitos.substring(2);
      final tamanhoParte1 = digitos.length > 10 ? 5 : 4;
      final parte1 = restante.substring(
        0,
        restante.length > tamanhoParte1 ? tamanhoParte1 : restante.length,
      );
      buffer.write(parte1);
      if (restante.length > tamanhoParte1) {
        buffer.write('-');
        buffer.write(restante.substring(tamanhoParte1));
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
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
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _CampoComIcone({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icone,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
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
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
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
