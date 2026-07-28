import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';
import 'package:postapramim/shared/widgets/app_card.dart';

class PerfilPage extends ConsumerWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider).usuario;

    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.preto),
        title: Text(
          'Perfil',
          style: AppTextStyles.titulo.copyWith(color: AppColors.preto),
        ),
        backgroundColor: AppColors.branco,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.amarelo,
            // child: Icon(Icons.person, size: 30, color: AppColors.branco),
            backgroundImage: usuario?.avatarUrl != null
                ? NetworkImage(usuario!.avatarUrl!)
                : null,
            child: usuario?.avatarUrl == null
                ? const Icon(Icons.person, size: 40, color: AppColors.branco)
                : null,
          ),
          const SizedBox(height: 12),
          Center(child: Text(usuario?.nome ?? '', style: AppTextStyles.titulo)),
          Center(
            child: Text(usuario?.email ?? '', style: AppTextStyles.legenda),
          ),
          const SizedBox(height: 24),
          AppCard(
            onTap: () => context.push(RoutePaths.editarPerfil),
            child: Row(
              children: [
                const Icon(Icons.edit_outlined, color: AppColors.darkFundo),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Editar perfil',
                    style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.darkFundo),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () => context.push(RoutePaths.configuracoes),
            child: Row(
              children: [
                Icon(Icons.settings_outlined, color: AppColors.darkFundo),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Configurações',
                    style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.darkFundo),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            onTap: () => context.push(RoutePaths.ajuda),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: AppColors.darkFundo),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ajuda',
                    style: AppTextStyles.subtitulo.copyWith(fontSize: 15),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.darkFundo),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go(RoutePaths.login);
            },
            icon: const Icon(Icons.logout, color: AppColors.erro),
            label: Text(
              'Sair',
              style: AppTextStyles.corpo.copyWith(
                color: AppColors.erro,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: NavigationBar(
      //   backgroundColor: AppColors.branco,
      //   indicatorColor: AppColors.darkFundo,
      //   labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
      //     if (states.contains(WidgetState.selected)) {
      //       return AppTextStyles.legenda.copyWith(
      //         color: AppColors.darkFundo,
      //         fontWeight: FontWeight.bold,
      //       );
      //     }

      //     return AppTextStyles.legenda.copyWith(color: AppColors.darkFundo);
      //   }),
      //   selectedIndex: 3,
      //   onDestinationSelected: (i) {
      //     switch (i) {
      //       case 0:
      //         context.push(RoutePaths.coletadorDashboard);
      //         break;
      //       case 1:
      //         context.push(RoutePaths.coletadorMinhasColetas);
      //         break;
      //       // case 2:
      //       //   context.push(RoutePaths.coletadorMapaRota);
      //       //   break;
      //       case 2:
      //         context.push(RoutePaths.ajuda);
      //         break;
      //       // case 3:
      //       //   context.push(RoutePaths.perfil);
      //       // break;
      //     }
      //   },
      //   destinations: const [
      //     NavigationDestination(
      //       icon: Icon(Icons.home_outlined, color: AppColors.cinzaTexto),
      //       label: 'Início',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.inventory_2_outlined, color: AppColors.cinzaTexto),
      //       label: 'Solicitações',
      //     ),
      //     // NavigationDestination(
      //     //   icon: Icon(Icons.map_outlined, color: AppColors.cinzaTexto),
      //     //   label: 'Rotas',
      //     // ),
      //     NavigationDestination(
      //       icon: Icon(Icons.help_outline, color: AppColors.cinzaTexto),
      //       label: 'Ajuda',
      //     ),
      //     NavigationDestination(
      //       icon: Icon(Icons.person_outline, color: AppColors.branco),
      //       label: 'Conta',
      //     ),
      //   ],
      // ),
    );
  }
}
