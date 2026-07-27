import 'package:postapramim/domain/auth/entities/user_entity.dart';

/// Estado imutável exposto pela UI.
class AuthState {
  final UserEntity? usuario;
  final bool carregando;
  final String? erro;

  const AuthState({this.usuario, this.carregando = false, this.erro});

  AuthState copyWith({
    UserEntity? usuario,
    bool? carregando,
    String? erro,
    bool limparErro = false,
  }) {
    return AuthState(
      usuario: usuario ?? this.usuario,
      carregando: carregando ?? this.carregando,
      erro: limparErro ? null : (erro ?? this.erro),
    );
  }

  static const inicial = AuthState();
}
