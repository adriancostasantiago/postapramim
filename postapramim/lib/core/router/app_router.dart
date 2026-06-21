import 'package:go_router/go_router.dart';
import 'package:posta_pra_mim/core/router/app_routes.dart';
import 'package:posta_pra_mim/presentation/home/home_page.dart';
import 'package:posta_pra_mim/presentation/login/login_page.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/manager_dashboard_page.dart';
import 'package:posta_pra_mim/presentation/register/register_page.dart';
import 'package:posta_pra_mim/presentation/splash/splash_page.dart';

/// Router único do app (declarativo). Nenhuma tela deve usar
/// `Navigator.push` imperativo em paralelo a este router.
///
/// Guards de autenticação ficam centralizados nas próprias telas
/// via `AuthController` (splash decide o destino), evitando duplicar
/// lógica de redirect em cada rota individualmente.
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
    ],
  );
}
