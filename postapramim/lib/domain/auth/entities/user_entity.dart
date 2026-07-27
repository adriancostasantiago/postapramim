import 'package:postapramim/core/constants/app_constants.dart';

/// Entidade pura de domínio — sem dependência de Supabase, Freezed ou JSON.
/// É o que trafega entre UseCases, Controllers e a UI.
class UserEntity {
  final String id;
  final String nome;
  final String email;
  final String? telefone;
  final String? avatarUrl;
  final PerfilUsuario perfil;
  final bool emailVerificado;
  final DateTime criadoEm;

  const UserEntity({
    required this.id,
    required this.nome,
    required this.email,
    this.telefone,
    this.avatarUrl,
    required this.perfil,
    required this.emailVerificado,
    required this.criadoEm,
  });

  UserEntity copyWith({String? nome, String? telefone, String? avatarUrl}) {
    return UserEntity(
      id: id,
      nome: nome ?? this.nome,
      email: email,
      telefone: telefone ?? this.telefone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      perfil: perfil,
      emailVerificado: emailVerificado,
      criadoEm: criadoEm,
    );
  }
}
