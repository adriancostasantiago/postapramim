import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/features/auth/presentation/providers/auth_providers.dart';
import 'package:postapramim/shared/widgets/app_card.dart';

class PerfilPage extends ConsumerWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider).usuario;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: usuario?.avatarUrl != null
                ? NetworkImage(usuario!.avatarUrl!)
                : null,
            child: usuario?.avatarUrl == null
                ? const Icon(Icons.person, size: 40)
                : null,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              usuario?.nome ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Center(
            child: Text(
              usuario?.email ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            onTap: () => context.push(RoutePaths.editarPerfil),
            child: const Row(
              children: [
                Icon(Icons.edit_outlined),
                SizedBox(width: 12),
                Expanded(child: Text('Editar perfil')),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () => context.push(RoutePaths.configuracoes),
            child: const Row(
              children: [
                Icon(Icons.settings_outlined),
                SizedBox(width: 12),
                Expanded(child: Text('Configurações')),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () => context.push(RoutePaths.ajuda),
            child: const Row(
              children: [
                Icon(Icons.help_outline),
                SizedBox(width: 12),
                Expanded(child: Text('Ajuda')),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go(RoutePaths.login);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
