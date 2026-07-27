import 'package:postapramim/core/constants/app_constants.dart';

class SolicitacaoEntity {
  final String id;

  /// Null quando a solicitação é avulsa (feita sem cadastro/login).
  final String? clienteId;
  final String? coletadorId;
  final StatusSolicitacao status;

  /// Null quando a solicitação é avulsa — nesse caso o endereço vem dos
  /// campos `*Contato` abaixo, e não de um endereço cadastrado.
  final String? enderecoId;

  /// Null é permitido apenas no fluxo avulso (o schema hoje não obriga
  /// descrição do item nessa modalidade).
  final String? descricaoItem;
  final String? codigoDevolucao;
  final String? observacoes;
  final DateTime? janelaColetaInicio;
  final DateTime? janelaColetaFim;
  final DateTime criadoEm;
  final DateTime? atualizadoEm;

  // ---------------------------------------------------------------------
  // Solicitação avulsa (sem cadastro) — ver schema_patch_solicitacao_avulsa
  // ---------------------------------------------------------------------
  final bool avulsa;
  final String? nomeContato;
  final String? cpfContato;
  final String? telefoneContato;
  final String? cepContato;
  final String? logradouroContato;
  final String? numeroContato;
  final String? complementoContato;
  final String? bairroContato;
  final String? cidadeContato;
  final String? ufContato;

  const SolicitacaoEntity({
    required this.id,
    this.clienteId,
    this.coletadorId,
    required this.status,
    this.enderecoId,
    this.descricaoItem = "",
    this.codigoDevolucao,
    this.observacoes,
    this.janelaColetaInicio,
    this.janelaColetaFim,
    required this.criadoEm,
    this.atualizadoEm,
    this.avulsa = false,
    this.nomeContato,
    this.cpfContato,
    this.telefoneContato,
    this.cepContato,
    this.logradouroContato,
    this.numeroContato,
    this.complementoContato,
    this.bairroContato,
    this.cidadeContato,
    this.ufContato,
  });

  bool get finalizada =>
      status == StatusSolicitacao.concluida ||
      status == StatusSolicitacao.cancelada;

  /// Nome a exibir nas telas: sempre o snapshot tirado no momento da
  /// criação da solicitação (`nomeContato`). Preenchido tanto no fluxo
  /// avulso quanto no fluxo de cliente cadastrado (ver
  /// `NovaSolicitacaoPage._enviar`), para que a solicitação sempre mostre
  /// os dados de quando foi criada, mesmo que o cliente altere o perfil
  /// depois.
  String get nomeExibicao => nomeContato ?? 'Cliente';

  /// Telefone a exibir: idem, sempre o snapshot capturado na criação.
  String? get telefoneExibicao => telefoneContato;

  /// Monta um endereço legível a partir do snapshot tirado na criação da
  /// solicitação. Vale tanto para o fluxo avulso quanto para o de cliente
  /// cadastrado, já que ambos preenchem os campos `*Contato`.
  String? get enderecoResumo {
    final partes = <String>[
      if (logradouroContato != null && logradouroContato!.isNotEmpty)
        '$logradouroContato${numeroContato != null ? ', $numeroContato' : ''}',
      if (bairroContato != null && bairroContato!.isNotEmpty) bairroContato!,
      if (cidadeContato != null && ufContato != null)
        '$cidadeContato/$ufContato',
    ];
    if (partes.isEmpty) return null;
    return partes.join(' - ');
  }

  SolicitacaoEntity copyWith({StatusSolicitacao? status, String? coletadorId}) {
    return SolicitacaoEntity(
      id: id,
      clienteId: clienteId,
      coletadorId: coletadorId ?? this.coletadorId,
      status: status ?? this.status,
      enderecoId: enderecoId,
      descricaoItem: descricaoItem,
      codigoDevolucao: codigoDevolucao,
      observacoes: observacoes,
      janelaColetaInicio: janelaColetaInicio,
      janelaColetaFim: janelaColetaFim,
      criadoEm: criadoEm,
      atualizadoEm: DateTime.now(),
      avulsa: avulsa,
      nomeContato: nomeContato,
      cpfContato: cpfContato,
      telefoneContato: telefoneContato,
      cepContato: cepContato,
      logradouroContato: logradouroContato,
      numeroContato: numeroContato,
      complementoContato: complementoContato,
      bairroContato: bairroContato,
      cidadeContato: cidadeContato,
      ufContato: ufContato,
    );
  }
}
