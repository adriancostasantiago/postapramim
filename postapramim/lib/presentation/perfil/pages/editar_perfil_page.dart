import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/shared/widgets/app_button.dart';
import 'package:postapramim/shared/widgets/app_text_field.dart';

class EditarPerfilPage extends ConsumerStatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  ConsumerState<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends ConsumerState<EditarPerfilPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(label: 'Nome', controller: _nomeCtrl),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Telefone',
              controller: _telefoneCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            // Persistência via `perfil` feature: UpdateProfileUsecase ->
            // PerfilRepository -> update em `usuarios` + upload de avatar
            // no bucket `avatares` (Supabase Storage), mesmo padrão do auth.
            AppButton(label: 'Salvar alterações', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
