import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/domain/entities/user.dart';
import 'package:posta_pra_mim/domain/entities/user_role.dart';
import 'package:posta_pra_mim/domain/repositories/auth_repository.dart';
import 'package:posta_pra_mim/domain/usecases/auth_usecases.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late SignInWithGoogleUseCase signInWithGoogleUseCase;
  late GetCurrentUserUseCase getCurrentUserUseCase;
  late AuthController controller;

  const tUser = User(
    id: '1',
    name: 'Maria',
    email: 'maria@example.com',
    role: UserRole.customer,
  );

  setUp(() {
    repository = _MockAuthRepository();
    loginUseCase = LoginUseCase(repository);
    registerUseCase = RegisterUseCase(repository);
    signInWithGoogleUseCase = SignInWithGoogleUseCase(repository);
    getCurrentUserUseCase = GetCurrentUserUseCase(repository);
    controller = AuthController(
      loginUseCase: loginUseCase,
      registerUseCase: registerUseCase,
      signInWithGoogleUseCase: signInWithGoogleUseCase,
      getCurrentUserUseCase: getCurrentUserUseCase,
      authRepository: repository,
    );
  });

  group('AuthController.checkSession', () {
    test('emite AuthAuthenticated quando há sessão salva', () async {
      when(() => repository.currentUser()).thenAnswer((_) async => tUser);

      final states = <AuthState>[];
      controller.addListener(() => states.add(controller.state));

      await controller.checkSession();

      expect(states, [const AuthLoading(), const AuthAuthenticated(tUser)]);
    });

    test('emite AuthUnauthenticated quando não há sessão', () async {
      when(() => repository.currentUser()).thenAnswer((_) async => null);

      final states = <AuthState>[];
      controller.addListener(() => states.add(controller.state));

      await controller.checkSession();

      expect(states, [const AuthLoading(), const AuthUnauthenticated()]);
    });
  });

  group('AuthController.login', () {
    test('emite AuthAuthenticated em caso de sucesso', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tUser);

      final states = <AuthState>[];
      controller.addListener(() => states.add(controller.state));

      await controller.login(email: 'maria@example.com', password: '123456');

      expect(states, [const AuthLoading(), const AuthAuthenticated(tUser)]);
    });

    test('emite AuthError quando credenciais são inválidas', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthFailure('E-mail ou senha inválidos.'));

      final states = <AuthState>[];
      controller.addListener(() => states.add(controller.state));

      await controller.login(email: 'maria@example.com', password: 'wrong');

      expect(states, [
        const AuthLoading(),
        const AuthError(AuthFailure('E-mail ou senha inválidos.')),
      ]);
    });

    test('emite AuthError em falha de rede', () async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NetworkFailure());

      await controller.login(email: 'maria@example.com', password: '123456');

      expect(controller.state, isA<AuthError>());
      expect(
        (controller.state as AuthError).failure,
        isA<NetworkFailure>(),
      );
    });
  });

  group('AuthController.register', () {
    test('emite AuthAuthenticated em caso de sucesso', () async {
      when(
        () => repository.registerWithEmail(
          name: any(named: 'name'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tUser);

      final states = <AuthState>[];
      controller.addListener(() => states.add(controller.state));

      await controller.register(
        name: 'Maria',
        email: 'maria@example.com',
        phone: '11999999999',
        password: '123456',
      );

      expect(states, [const AuthLoading(), const AuthAuthenticated(tUser)]);
    });

    test('emite AuthError quando e-mail já está cadastrado', () async {
      when(
        () => repository.registerWithEmail(
          name: any(named: 'name'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const AuthFailure('Este e-mail já está cadastrado.'));

      await controller.register(
        name: 'Maria',
        email: 'maria@example.com',
        phone: '11999999999',
        password: '123456',
      );

      expect(controller.state, isA<AuthError>());
    });
  });

  group('AuthController.signInWithGoogle', () {
    test('emite AuthAuthenticated em caso de sucesso', () async {
      when(() => repository.signInWithGoogle()).thenAnswer((_) async => tUser);

      final states = <AuthState>[];
      controller.addListener(() => states.add(controller.state));

      await controller.signInWithGoogle();

      expect(states, [const AuthLoading(), const AuthAuthenticated(tUser)]);
    });

    test('emite AuthError quando o fluxo não está configurado', () async {
      when(() => repository.signInWithGoogle())
          .thenThrow(const AuthFailure('Login com Google ainda não foi configurado.'));

      await controller.signInWithGoogle();

      expect(controller.state, isA<AuthError>());
    });
  });

  group('AuthController.logout', () {
    test('chama repository.logout e emite AuthUnauthenticated', () async {
      when(() => repository.logout()).thenAnswer((_) async {});

      await controller.logout();

      verify(() => repository.logout()).called(1);
      expect(controller.state, const AuthUnauthenticated());
    });
  });
}
