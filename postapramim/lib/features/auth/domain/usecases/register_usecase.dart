import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/features/auth/domain/entities/user_entity.dart';
import 'package:postapramim/features/auth/domain/repositories/auth_repository.dart';

/// ATENÇÃO: você não me enviou o `register_usecase.dart` original — este
/// arquivo foi reconstruído a partir do padrão de repasse direto que o
/// `AuthController` já usa (`ref.read(registerUsecaseProvider)(nome:, ...)`
/// espelhando 1:1 `AuthRepository.cadastrar`). Se sua classe real tiver
/// alguma validação ou lógica extra, ajuste manualmente — só adicione os
/// dois parâmetros novos (`cpf`, `celular`) na assinatura do `call`.
class RegisterUsecase {
  final AuthRepository _repository;
  RegisterUsecase(this._repository);

  Future<Result<UserEntity>> call({
    required String nome,
    required String email,
    required String senha,
    required String perfil,
    required String cpf,
    required String celular,
  }) {
    return _repository.cadastrar(
      nome: nome,
      email: email,
      senha: senha,
      perfil: perfil,
      cpf: cpf,
      celular: celular,
    );
  }
}
