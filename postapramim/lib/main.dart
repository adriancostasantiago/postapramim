import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posta_pra_mim/app.dart';
import 'package:posta_pra_mim/core/config/app_config.dart';
import 'package:posta_pra_mim/core/di/app_providers.dart';
import 'package:posta_pra_mim/core/utils/app_logger.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppLogger.init();

      final log = AppLogger.of('main');

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        log.severe('FlutterError', details.exception, details.stack);
      };

      PlatformDispatcher.instance.onError = (error, stackTrace) {
        log.severe('Uncaught platform error', error, stackTrace);
        return true;
      };

      // Inicializa o Supabase antes de qualquer acesso ao cliente.
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,

        publishableKey: AppConfig.supabaseAnonKey,
        // authOptions: desabilita deep-link automático — app ainda não
        // tem URL scheme configurado.
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      log.info('Supabase inicializado: ${AppConfig.supabaseUrl}');

      // API_BASE_URL mantida como fallback para outros endpoints HTTP
      // que possam existir fora do Supabase.
      const baseUrl = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://api.postapramim.com.br',
      );

      runApp(
        AppProviders(
          baseUrl: Uri.parse(baseUrl),
          child: const App(),
        ),
      );
    },
    (error, stackTrace) {
      AppLogger.of('main').severe('Uncaught zone error', error, stackTrace);
    },
  );
}
