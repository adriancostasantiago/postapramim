import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/app/theme/app_colors.dart';
import 'package:postapramim/app/theme/app_text_styles.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/presentation/auth/providers/auth_providers.dart';

/// Drawer lateral compartilhado entre os dashboards de cliente e
/// coletador. Os itens mudam de acordo com o `PerfilUsuario` logado.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(authControllerProvider).usuario;
    final perfil = usuario?.perfil ?? PerfilUsuario.cliente;

    return Drawer(
      backgroundColor: AppColors.branco,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CabecalhoDrawer(
              nome: usuario?.nome ?? '',
              email: usuario?.email ?? '',
            ),
            const Divider(height: 1, color: AppColors.cinzaBorda),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _ItemDrawer(
                    icone: Icons.home_outlined,
                    label: 'Início',
                    onTap: () => _irPara(
                      context,
                      perfil == PerfilUsuario.coletador
                          ? RoutePaths.coletadorDashboard
                          : RoutePaths.clienteHome,
                    ),
                  ),
                  _ItemDrawer(
                    icone: Icons.inventory_2_outlined,
                    label: 'Solicitações',
                    onTap: () => _irPara(
                      context,
                      perfil == PerfilUsuario.coletador
                          ? RoutePaths.coletadorMinhasColetas
                          : RoutePaths.clienteHistorico,
                    ),
                  ),
                  if (perfil == PerfilUsuario.coletador)
                    _ItemDrawer(
                      icone: Icons.map_outlined,
                      label: 'Rotas',
                      onTap: () =>
                          _irPara(context, RoutePaths.coletadorMapaRota),
                    ),
                  _ItemDrawer(
                    icone: Icons.notifications_outlined,
                    label: 'Notificações',
                    onTap: () => _irPara(context, RoutePaths.notificacoes),
                  ),
                  _ItemDrawer(
                    icone: Icons.help_outline,
                    label: 'Ajuda',
                    onTap: () => _irPara(context, RoutePaths.ajuda),
                  ),
                  _ItemDrawer(
                    icone: Icons.person_outline,
                    label: 'Minha conta',
                    onTap: () => _irPara(context, RoutePaths.perfil),
                  ),
                  _ItemDrawer(
                    icone: Icons.settings_outlined,
                    label: 'Configurações',
                    onTap: () => _irPara(context, RoutePaths.configuracoes),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.cinzaBorda),
            _ItemDrawer(
              icone: Icons.logout,
              label: 'Sair',
              cor: AppColors.erro,
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go(RoutePaths.login);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _irPara(BuildContext context, String rota) {
    Navigator.of(context).pop();
    context.push(rota);
  }
}

class _CabecalhoDrawer extends StatelessWidget {
  final String nome;
  final String email;
  const _CabecalhoDrawer({required this.nome, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(color: AppColors.amareloClaro),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.branco,
            child: Icon(Icons.person, size: 30, color: AppColors.amarelo),
          ),
          const SizedBox(height: 12),
          Text(
            nome.isEmpty ? 'Usuário' : nome,
            style: AppTextStyles.subtitulo.copyWith(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: AppTextStyles.legenda,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ItemDrawer extends StatelessWidget {
  final IconData icone;
  final String label;
  final Color? cor;
  final VoidCallback onTap;

  const _ItemDrawer({
    required this.icone,
    required this.label,
    required this.onTap,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final corEfetiva = cor ?? AppColors.darkFundo;
    return ListTile(
      leading: Icon(icone, color: corEfetiva),
      title: Text(
        label,
        style: AppTextStyles.corpo.copyWith(
          color: corEfetiva,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
