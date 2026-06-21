import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:posta_pra_mim/app.dart';
import 'package:posta_pra_mim/core/di/app_providers.dart';
import 'package:posta_pra_mim/core/utils/app_logger.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppLogger.init();

      final log = AppLogger.of('main');

      // Captura erros do framework (build/layout/paint).
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        log.severe('FlutterError', details.exception, details.stack);
        // TODO: encaminhar para Crashlytics/Sentry em produção.
      };

      // Captura erros assíncronos não pegos pelo Flutter.
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        log.severe('Uncaught platform error', error, stackTrace);
        // TODO: encaminhar para Crashlytics/Sentry em produção.
        return true;
      };

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
      // TODO: encaminhar para Crashlytics/Sentry em produção.
    },
  );
}
