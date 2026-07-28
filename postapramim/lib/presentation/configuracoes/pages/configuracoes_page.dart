import 'package:flutter/material.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.darkFundo),
        title: Text(
          'Configurações',
          style: AppTextStyles.titulo.copyWith(color: AppColors.darkFundo),
        ),
        backgroundColor: AppColors.branco,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text(
              'Notificações push',
              style: AppTextStyles.subtitulo,
            ),
            value: true,
            onChanged: (_) {},
          ),
          SwitchListTile(
            title: const Text('Tema escuro', style: AppTextStyles.subtitulo),
            subtitle: const Text(
              'Segue o sistema por padrão',
              style: AppTextStyles.corpo,
            ),
            value: false,
            onChanged: (_) {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: AppColors.darkFundo,
            ),
            title: const Text('Termos de uso', style: AppTextStyles.subtitulo),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.darkFundo,
            ),
            title: const Text(
              'Política de privacidade',
              style: AppTextStyles.subtitulo,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
