import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posta_pra_mim/core/router/app_router.dart';
import 'package:posta_pra_mim/core/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Posta Pra Mim',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
