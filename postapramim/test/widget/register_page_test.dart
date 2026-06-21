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
import 'package:posta_pra_mim/presentation/register/register_page.dart';
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
      initialLocation: AppRoutes.register,
      routes: [
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) =>
              const Scaffold(body: Text('Tela de Login')),
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

  group('RegisterPage', () {
    testWidgets('renderiza todos os campos do formulário', (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Criar Conta'), findsOneWidget);
      expect(find.text('Nome Completo'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Telefone'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Confirmar Senha'), findsOneWidget);
      expect(find.text('Cadastrar'), findsOneWidget);
    });

    testWidgets('mostra erro quando senhas não coincidem', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex: João Silva'),
        'João Silva',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'nome@email.com'),
        'joao@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '(00) 00000-0000'),
        '11999999999',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mínimo 8 caracteres'),
        '12345678',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Repita sua senha'),
        'diferente',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('As senhas não coincidem.'), findsOneWidget);
      verifyNever(
        () => repository.registerWithEmail(
          name: any(named: 'name'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('cadastra com sucesso e navega para home', (tester) async {
      when(
        () => repository.registerWithEmail(
          name: any(named: 'name'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          password: any(named: 'password'),
        ),
      ).thenAnswer(
        (_) async => const User(
          id: '1',
          name: 'João Silva',
          email: 'joao@example.com',
          role: UserRole.customer,
        ),
      );

      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex: João Silva'),
        'João Silva',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'nome@email.com'),
        'joao@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '(00) 00000-0000'),
        '11999999999',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mínimo 8 caracteres'),
        '12345678',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Repita sua senha'),
        '12345678',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('Tela Home'), findsOneWidget);
    });

    testWidgets('navega para login ao tocar em Fazer login', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Fazer login'));
      await tester.pumpAndSettle();

      expect(find.text('Tela de Login'), findsOneWidget);
    });
  });
}
