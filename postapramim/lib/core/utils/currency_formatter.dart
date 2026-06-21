/// Formatação de valores monetários em pt-BR sem depender do pacote
/// `intl` (evita uma dependência extra só para isso).
abstract final class CurrencyFormatter {
  /// Formata como "R$ 145,90".
  static String format(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = _withThousandsSeparator(parts[0]);
    return 'R\$ $intPart,${parts[1]}';
  }

  /// Formata valores grandes de forma compacta: "R$ 15,4k".
  static String formatCompact(double value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      final formatted = thousands.toStringAsFixed(1).replaceAll('.', ',');
      return 'R\$ ${formatted}k';
    }
    return format(value);
  }

  static String _withThousandsSeparator(String digits) {
    final buffer = StringBuffer();
    final reversed = digits.split('').reversed.toList();
    for (var i = 0; i < reversed.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write('.');
      buffer.write(reversed[i]);
    }
    return buffer.toString().split('').reversed.join();
  }
}
