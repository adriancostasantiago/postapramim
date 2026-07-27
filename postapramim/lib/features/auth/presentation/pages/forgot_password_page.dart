import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postapramim/core/utils/validators.dart';
import 'package:postapramim/features/auth/presentation/providers/auth_providers.dart';
import 'package:postapramim/shared/widgets/app_button.dart';
import 'package:postapramim/shared/widgets/app_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _enviado = false;

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .recuperarSenha(_emailCtrl.text.trim());
    setState(() => _enviado = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _enviado
            ? const Center(
                child: Text(
                  'Se o e-mail existir, enviamos um link de recuperação.',
                ),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informe seu e-mail para receber o link de recuperação',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'E-mail',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Enviar link',
                      carregando: authState.carregando,
                      onPressed: _enviar,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
