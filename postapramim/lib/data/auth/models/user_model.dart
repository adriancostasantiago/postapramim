import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/domain/auth/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Model = representação exata da tabela `usuarios` no Supabase.
/// Nunca é usado diretamente na UI — sempre convertido para [UserEntity]
/// via [toEntity] dentro do Repository.
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String nome,
    required String email,
    String? telefone,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    required String perfil,
    @JsonKey(name: 'email_verificado') required bool emailVerificado,
    @JsonKey(name: 'fcm_token') String? fcmToken,
    @JsonKey(name: 'criado_em') required DateTime criadoEm,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      nome: nome,
      email: email,
      telefone: telefone,
      avatarUrl: avatarUrl,
      perfil: PerfilUsuario.values.firstWhere(
        (p) => p.name == perfil,
        orElse: () => PerfilUsuario.cliente,
      ),
      emailVerificado: emailVerificado,
      criadoEm: criadoEm,
    );
  }
}
