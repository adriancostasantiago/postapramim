import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/router/app_routes.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posta Pra Mim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await context.read<AuthController>().logout();
              if (context.mounted) context.go(AppRoutes.splash);
            },
          ),
        ],
      ),
      body: Consumer<AuthController>(
        builder: (context, controller, _) {
          final state = controller.state;
          final greeting = switch (state) {
            AuthAuthenticated(:final user) => 'Olá, ${user.name}!',
            _ => 'Bem-vindo!',
          };

          return Center(child: Text(greeting));
        },
      ),
    );
  }
}
