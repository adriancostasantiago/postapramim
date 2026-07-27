import 'package:posta_pra_mim/domain/entities/user_role.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String managerDashboard = '/manager/dashboard';
  static const String pedidoDetalhe = '/manager/pedido/:id';
  static const String novoPedido = '/manager/pedido/novo';
  static const String pagamentoPix = '/manager/pedido/novo/pagamento-pix';

  static String pedidoDetalhePath(String pedidoId) =>
      '/manager/pedido/$pedidoId';

  static String homeForRole(UserRole role) => switch (role) {
        UserRole.manager => managerDashboard,
        UserRole.customer => home,
        UserRole.dispatcher => home,
      };
}
