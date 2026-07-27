import 'package:go_router/go_router.dart';
import 'package:posta_pra_mim/core/router/app_routes.dart';
import 'package:posta_pra_mim/domain/entities/novo_pedido.dart';
import 'package:posta_pra_mim/presentation/home/home_page.dart';
import 'package:posta_pra_mim/presentation/login/login_page.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/manager_dashboard_page.dart';
import 'package:posta_pra_mim/presentation/novo_pedido/novo_pedido_page.dart';
import 'package:posta_pra_mim/presentation/pagamento_pix/pagamento_pix_page.dart';
import 'package:posta_pra_mim/presentation/pedido_detalhe/pedido_detalhe_page.dart';
import 'package:posta_pra_mim/presentation/register/register_page.dart';
import 'package:posta_pra_mim/presentation/splash/splash_page.dart';

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.managerDashboard,
        builder: (context, state) => const ManagerDashboardPage(),
      ),
      // novoPedido deve vir antes de pedidoDetalhe para que o segmento
      // literal "novo" não seja capturado pelo param `:id`.
      GoRoute(
        path: AppRoutes.novoPedido,
        builder: (context, state) => const NovoPedidoPage(),
      ),
      GoRoute(
        path: AppRoutes.pagamentoPix,
        builder: (context, state) {
          final pix = state.extra! as PagamentoPix;
          return PagamentoPixPage(pagamento: pix);
        },
      ),
      GoRoute(
        path: AppRoutes.pedidoDetalhe,
        builder: (context, state) {
          final pedidoId = state.pathParameters['id']!;
          return PedidoDetalhePage(pedidoId: pedidoId);
        },
      ),
    ],
  );
}
