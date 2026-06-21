import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posta_pra_mim/presentation/splash/widgets/splash_action_card.dart';

void main() {
  group('SplashActionCard', () {
    testWidgets('renderiza textos principais', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SplashActionCard(onGetStarted: () {}, onLogin: () {}),
          ),
        ),
      );

      expect(find.text('Começar agora'), findsOneWidget);
      expect(find.text('Já possui uma conta?'), findsOneWidget);
      expect(find.text('Fazer login'), findsOneWidget);
    });

    testWidgets('chama onGetStarted ao tocar no botão principal',
        (tester) async {
      var getStartedTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SplashActionCard(
              onGetStarted: () => getStartedTapped = true,
              onLogin: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Começar agora'));
      await tester.pump();

      expect(getStartedTapped, isTrue);
    });

    testWidgets('chama onLogin ao tocar em Fazer login', (tester) async {
      var loginTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SplashActionCard(
              onGetStarted: () {},
              onLogin: () => loginTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Fazer login'));
      await tester.pump();

      expect(loginTapped, isTrue);
    });
  });
}
