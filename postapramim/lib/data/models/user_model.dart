import 'package:posta_pra_mim/domain/entities/user.dart';
import 'package:posta_pra_mim/domain/entities/user_role.dart';

/// DTO da camada de dados — conhece o formato JSON da API.
/// Convertido para [User] (entidade de domínio) antes de subir
/// para use cases/UI.
final class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.fromJson(json['role'] as String? ?? 'customer'),
    );
  }

  final String id;
  final String name;
  final String email;
  final UserRole role;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.toJson(),
      };

  User toEntity() => User(id: id, name: name, email: email, role: role);
}
