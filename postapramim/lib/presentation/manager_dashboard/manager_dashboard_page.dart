import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/theme/app_colors.dart';
import 'package:posta_pra_mim/domain/entities/pedido.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/widgets/filter_chip_button.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/widgets/manager_bottom_nav.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/widgets/manager_dashboard_app_bar.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/widgets/metrics_grid.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/widgets/pedido_card.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/widgets/pedido_search_field.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_state.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedidos_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedidos_state.dart';
import 'package:go_router/go_router.dart';
import 'package:posta_pra_mim/core/router/app_routes.dart';

/// Dashboard do gestor — métricas, busca, filtros e lista de pedidos
/// recentes. Não chama rede/IO diretamente: delega tudo ao
/// `PedidosController` injetado via Provider.
class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  int _bottomNavIndex = 2; // "Novo" como aba central, mas não navega por padrão

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PedidosController>().load();
    });
  }

  void _showPlaceholderSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthController>().state;
    final userInitial = switch (authState) {
      AuthAuthenticated(:final user) =>
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
      _ => '?',
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: ManagerDashboardAppBar(
        userInitial: userInitial,
        onMenuTap: () => _showPlaceholderSnackBar('Menu em breve.'),
        onNotificationsTap: () =>
            _showPlaceholderSnackBar('Notificações em breve.'),
        onProfileTap: () => _showPlaceholderSnackBar('Perfil em breve.'),
      ),
      body: SafeArea(
        top: false,
        child: Consumer<PedidosController>(
          builder: (context, controller, _) {
            final state = controller.state;

            return switch (state) {
              PedidosInitial() || PedidosLoading() => const _LoadingView(),
              PedidosError(:final failure) => _ErrorView(
                  message: failure.message,
                  onRetry: controller.load,
                ),
              PedidosLoaded(:final resumo, :final pedidos) => _DashboardContent(
                  resumo: resumo,
                  pedidos: pedidos,
                  onSearchChanged: controller.updateQuery,
                  onApprove: (pedido) => controller.avancarStatus(
                    pedidoId: pedido.id,
                    novoStatus: _nextStatus(pedido.status),
                  ),
                  onSecondaryAction: (pedido) => _showPlaceholderSnackBar(
                    'Ação "${pedido.codigo}" em breve.',
                  ),
                  onMoreOptions: (pedido) => _showPlaceholderSnackBar(
                    'Mais opções para ${pedido.codigo} em breve.',
                  ),
                  onFilterTap: () =>
                      _showPlaceholderSnackBar('Filtros avançados em breve.'),
                  onDateTap: () =>
                      _showPlaceholderSnackBar('Filtro de data em breve.'),
                  onCityTap: () =>
                      _showPlaceholderSnackBar('Filtro de cidade em breve.'),
                ),
            };
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.onSurface,
        onPressed: () => _showPlaceholderSnackBar('Novo pedido em breve.'),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: ManagerBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          _showPlaceholderSnackBar('Navegação em breve.');
        },
      ),
    );
  }

  /// Avanço de status simplificado para o protótipo: solicitado →
  /// aprovado → despachado. Pedidos em outros estados não têm ação
  /// de avanço automático (o botão vira "Detalhes").
  PedidoStatus _nextStatus(PedidoStatus current) {
    return switch (current) {
      PedidoStatus.solicitado => PedidoStatus.aprovado,
      PedidoStatus.aprovado => PedidoStatus.despachado,
      _ => current,
    };
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.resumo,
    required this.pedidos,
    required this.onSearchChanged,
    required this.onApprove,
    required this.onSecondaryAction,
    required this.onMoreOptions,
    required this.onFilterTap,
    required this.onDateTap,
    required this.onCityTap,
  });

  final PedidosResumo resumo;
  final List<Pedido> pedidos;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Pedido> onApprove;
  final ValueChanged<Pedido> onSecondaryAction;
  final ValueChanged<Pedido> onMoreOptions;
  final VoidCallback onFilterTap;
  final VoidCallback onDateTap;
  final VoidCallback onCityTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(child: MetricsGrid(resumo: resumo)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PedidoSearchField(onChanged: onSearchChanged),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilterChipButton(
                      icon: Icons.tune,
                      label: 'Filtros Avançados',
                      onTap: onFilterTap,
                    ),
                    const SizedBox(width: 8),
                    FilterChipButton(
                      icon: Icons.calendar_today_outlined,
                      label: 'Data',
                      onTap: onDateTap,
                    ),
                    const SizedBox(width: 8),
                    FilterChipButton(
                      icon: Icons.location_city_outlined,
                      label: 'Cidade',
                      onTap: onCityTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pedidos Recentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child:
                      const Text('Ver todos', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
        if (pedidos.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyOrdersView(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
            sliver: SliverList.separated(
              itemCount: pedidos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                return PedidoCard(
                  pedido: pedido,
                  onTap: () =>
                      context.push(AppRoutes.pedidoDetalhePath(pedido.id)),
                  onPrimaryAction: () => _handlePrimaryAction(pedido),
                  onMoreOptions: () => onMoreOptions(pedido),
                );
              },
            ),
          ),
      ],
    );
  }

  void _handlePrimaryAction(Pedido pedido) {
    switch (pedido.status) {
      case PedidoStatus.solicitado:
      case PedidoStatus.aprovado:
        onApprove(pedido);
      case PedidoStatus.despachado:
      case PedidoStatus.emTransito:
      case PedidoStatus.finalizado:
      case PedidoStatus.cancelado:
        onSecondaryAction(pedido);
    }
  }
}

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.outline),
            SizedBox(height: 12),
            Text(
              'Nenhum pedido encontrado para esse filtro.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
