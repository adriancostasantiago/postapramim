import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/utils/validators.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/presentation/enderecos/providers/enderecos_providers.dart';
import 'package:postapramim/presentation/perfil/providers/perfil_providers.dart';
import 'package:postapramim/shared/widgets/app_button.dart';
import 'package:postapramim/shared/widgets/app_text_field.dart';

class EditarPerfilPage extends ConsumerStatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  ConsumerState<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends ConsumerState<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _telefoneCtrl;

  @override
  void initState() {
    super.initState();
    final usuario = ref.read(authControllerProvider).usuario;
    _nomeCtrl = TextEditingController(text: usuario?.nome);
    _telefoneCtrl = TextEditingController(text: usuario?.telefone);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final usuario = ref.read(authControllerProvider).usuario;
    if (usuario == null) return;

    final ok = await ref
        .read(perfilFormControllerProvider.notifier)
        .salvar(
          usuarioId: usuario.id,
          nome: _nomeCtrl.text.trim(),
          telefone: _telefoneCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(perfilFormControllerProvider);
    final usuario = ref.watch(authControllerProvider).usuario;
    final enderecoAsync = usuario == null
        ? null
        : ref.watch(enderecoPrincipalClienteProvider(usuario.id));

    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.preto),
        title: Text(
          'Editar perfil',
          style: AppTextStyles.titulo.copyWith(color: AppColors.preto),
        ),
        backgroundColor: AppColors.branco,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Nome',
                controller: _nomeCtrl,
                validator: (v) => Validators.obrigatorio(v, campo: 'Nome'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Telefone',
                controller: _telefoneCtrl,
                keyboardType: TextInputType.phone,
                validator: Validators.telefone,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Salvar alterações',
                carregando: formState.carregando,
                onPressed: _salvar,
              ),
              if (formState.erro != null) ...[
                const SizedBox(height: 10),
                Text(
                  formState.erro!,
                  style: const TextStyle(color: AppColors.erro),
                ),
              ],
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Endereço', style: AppTextStyles.subtitulo),
              const SizedBox(height: 12),
              if (enderecoAsync != null)
                enderecoAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Erro ao carregar endereço'),
                  data: (endereco) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.darkFundo,
                    ),
                    title: Text(
                      endereco?.enderecoFormatado ??
                          'Nenhum endereço cadastrado',
                      style: AppTextStyles.corpo,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.darkFundo,
                    ),
                    onTap: () async {
                      final resultado = await context.push<bool>(
                        RoutePaths.clienteEnderecoForm,
                        extra: endereco,
                      );
                      if (resultado == true) {
                        ref.invalidate(
                          enderecoPrincipalClienteProvider(usuario!.id),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
