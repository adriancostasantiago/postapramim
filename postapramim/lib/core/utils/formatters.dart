import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _dataHora = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  static final _data = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final _hora = DateFormat('HH:mm', 'pt_BR');

  static String dataHora(DateTime data) => _dataHora.format(data);
  static String data(DateTime data) => _data.format(data);
  static String hora(DateTime data) => _hora.format(data);

  static String distanciaKm(double metros) {
    final km = metros / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  static String duracaoMinutos(int segundos) {
    final minutos = (segundos / 60).round();
    if (minutos < 60) return '$minutos min';
    final horas = minutos ~/ 60;
    final resto = minutos % 60;
    return '${horas}h${resto > 0 ? ' ${resto}min' : ''}';
  }
}
