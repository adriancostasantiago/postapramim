import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/core/router/app_routes.dart';
import 'package:posta_pra_mim/domain/entities/user.dart';
import 'package:posta_pra_mim/domain/entities/user_role.dart';
import 'package:posta_pra_mim/domain/repositories/auth_repository.dart';
import 'package:posta_pra_mim/domain/usecases/auth_usecases.dart';
import 'package:posta_pra_mim/presentation/login/login_page.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_controller.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late AuthController controller;
  late GoRouter router;

  setUp(() {
    repository = _MockAuthRepository();
    controller = AuthController(
      loginUseCase: LoginUseCase(repository),
      registerUseCase: RegisterUseCase(repository),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(repository),
      getCurrentUserUseCase: GetCurrentUserUseCase(repository),
      authRepository: repository,
    );
    router = GoRouter(
      initialLocation: AppRoutes.login,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) =>
              const Scaffold(body: Text('Tela de Cadastro')),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) =>
              const Scaffold(body: Text('Tela Home')),
        ),
      ],
    );
  });

  Widget buildSubject() {
    return ChangeNotifierProvider<AuthController>.value(
      value: controller,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('LoginPage', () {
    testWidgets('renderiza campos e botões principais', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Posta Pra Mim'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Entrar com Google'), findsOneWidget);
      expect(find.text('Criar Conta'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
    });

    testWidgets('mostra erros de validação com campos vazios',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu e-mail.'), findsOneWidget);
      expect(find.text('Informe sua senha.'), findsOneWidget);
      verifyNever(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('navega para home após login bem-sucedido', (tester) async {
      when(
        () => repository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const User(
          id: '1',
          name: 'Maria',
          email: 'maria@example.com',
          role: UserRole.customer,
        ),
      );

      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'maria@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '123456',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Tela Home'), findsOneWidget);
    });

    testWidgets('navega para cadastro ao tocar em Criar Conta',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('Tela de Cadastro'), findsOneWidget);
    });
  });
}
