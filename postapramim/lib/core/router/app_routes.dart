import 'package:posta_pra_mim/domain/entities/user_role.dart';

/// Caminhos de rota como constantes — nunca strings mágicas
/// espalhadas pelo código.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  /// Mantida como fallback genérico (cliente final/despachador ainda
  /// não têm dashboard próprio — ver [homeForRole]).
  static const String home = '/home';

  static const String managerDashboard = '/manager/dashboard';

  /// Resolve a rota inicial pós-login com base na role do usuário.
  /// Cliente final e despachador ainda usam [home] como placeholder
  /// até suas telas dedicadas serem implementadas.
  static String homeForRole(UserRole role) {
    return switch (role) {
      UserRole.manager => managerDashboard,
      UserRole.customer => home,
      UserRole.dispatcher => home,
    };
  }
}
