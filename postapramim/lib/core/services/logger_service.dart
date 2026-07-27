import 'package:logger/logger.dart';

/// Wrapper único de log usado em toda a aplicação.
/// Nenhuma camada deve chamar `print` diretamente.
class LoggerService {
  LoggerService._();
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static void debug(String message) => _logger.d(message);
  static void info(String message) => _logger.i(message);
  static void warning(String message) => _logger.w(message);
  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
