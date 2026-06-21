import 'package:logging/logging.dart';

/// Logger central do app. Nunca use `print()` — sempre `AppLogger.of(...)`.
///
/// Em produção, plugar um listener aqui (Crashlytics/Sentry) que escuta
/// `Logger.root.onRecord` e envia erros não-fatais com stack trace.
abstract final class AppLogger {
  static bool _initialized = false;

  static void init({Level level = Level.INFO}) {
    if (_initialized) return;
    _initialized = true;
    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      // ignore: avoid_print
      print('${record.level.name}: ${record.loggerName}: ${record.message}');
      // TODO: encaminhar record.error / record.stackTrace para
      // Crashlytics/Sentry quando o erro for não-fatal mas relevante.
    });
  }

  static Logger of(String name) => Logger(name);
}
