/// Perfis de usuário suportados pelo app.
///
/// Cada role tem sua própria home/dashboard — o router decide o
/// destino pós-login com base nesse valor (ver `core/router/app_router.dart`).
enum UserRole {
  /// Gestor da operação: acompanha métricas, aprova e despacha pedidos.
  manager,

  /// Cliente final: acompanha o status dos próprios pedidos. (próxima etapa)
  customer,

  /// Entregador/despachador: executa as entregas em campo. (próxima etapa)
  dispatcher;

  static UserRole fromJson(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.customer,
    );
  }

  String toJson() => name;
}
