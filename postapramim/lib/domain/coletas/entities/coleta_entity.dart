import 'package:postapramim/core/constants/app_constants.dart';

class ColetaEntity {
  final String id;
  final String solicitacaoId;
  final String coletadorId;
  final StatusSolicitacao status;
  final String? codigoEscaneado;
  final List<String> fotosColeta;
  final List<String> fotosEmbalagem;
  final String? comprovanteUrl;
  final double? latitudeColeta;
  final double? longitudeColeta;
  final DateTime? iniciadaEm;
  final DateTime? concluidaEm;

  const ColetaEntity({
    required this.id,
    required this.solicitacaoId,
    required this.coletadorId,
    required this.status,
    this.codigoEscaneado,
    this.fotosColeta = const [],
    this.fotosEmbalagem = const [],
    this.comprovanteUrl,
    this.latitudeColeta,
    this.longitudeColeta,
    this.iniciadaEm,
    this.concluidaEm,
  });
}
