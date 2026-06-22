/// Formatação de datas em pt-BR sem depender do pacote `intl` (mesmo
/// raciocínio de `currency_formatter.dart`: evitar dependência extra
/// só para isso).
abstract final class DateFormatter {
  /// Formata como "15/10/2023 - 14:30".
  static String formatDateTime(DateTime value) {
    final date = '${_two(value.day)}/${_two(value.month)}/${value.year}';
    final time = '${_two(value.hour)}:${_two(value.minute)}';
    return '$date - $time';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
