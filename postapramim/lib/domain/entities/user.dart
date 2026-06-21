import 'package:equatable/equatable.dart';
import 'package:posta_pra_mim/domain/entities/user_role.dart';

/// Entidade de domínio — não conhece JSON, banco ou widgets.
final class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;

  @override
  List<Object?> get props => [id, name, email, role];
}
