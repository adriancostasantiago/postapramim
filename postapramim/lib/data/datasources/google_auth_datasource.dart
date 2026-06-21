import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/data/models/user_model.dart';

/// Abstrai o fluxo de login social com Google. Mantido separado do
/// [AuthRemoteDataSource] porque depende de um SDK nativo (account
/// picker) em vez de uma chamada HTTP simples.
abstract interface class GoogleAuthDataSource {
  /// Abre o seletor de conta nativo e retorna o usuário autenticado.
  /// Lança [AuthFailure] se o usuário cancelar o fluxo.
  Future<UserModel> signIn();
}

/// STUB — substituir pela integração real antes de ir para produção.
///
/// Para ativar de verdade:
/// 1. Adicione `google_sign_in: ^6.x` ao `pubspec.yaml` (dependência já
///    documentada, comentada por padrão).
/// 2. Configure `google-services.json` (Android) e o
///    `GIDClientID`/URL scheme (iOS) no projeto nativo.
/// 3. Troque o corpo de [signIn] por algo como:
///
/// ```dart
/// final googleUser = await GoogleSignIn().signIn();
/// if (googleUser == null) throw const AuthFailure('Login cancelado.');
/// final googleAuth = await googleUser.authentication;
/// // Envie googleAuth.idToken para seu backend trocar por sessão própria:
/// final response = await _client.post(
///   baseUrl.replace(path: '/auth/google'),
///   body: jsonEncode({'idToken': googleAuth.idToken}),
/// );
/// return UserModel.fromJson(jsonDecode(response.body));
/// ```
final class GoogleAuthDataSourceStub implements GoogleAuthDataSource {
  const GoogleAuthDataSourceStub();

  @override
  Future<UserModel> signIn() async {
    throw const AuthFailure(
      'Login com Google ainda não foi configurado neste app. '
      'Veja GoogleAuthDataSourceStub para instruções de integração.',
    );
  }
}
