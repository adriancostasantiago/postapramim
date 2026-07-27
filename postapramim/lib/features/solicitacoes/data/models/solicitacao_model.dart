import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/features/solicitacoes/domain/entities/solicitacao_entity.dart';

part 'solicitacao_model.freezed.dart';
part 'solicitacao_model.g.dart';

@freezed
abstract class SolicitacaoModel with _$SolicitacaoModel {
  const SolicitacaoModel._();

  const factory SolicitacaoModel({
    required String id,
    @JsonKey(name: 'cliente_id') String? clienteId,
    @JsonKey(name: 'coletador_id') String? coletadorId,
    required String status,
    @JsonKey(name: 'endereco_id') String? enderecoId,
    @JsonKey(name: 'descricao_item') String? descricaoItem,
    @JsonKey(name: 'codigo_devolucao') String? codigoDevolucao,
    String? observacoes,
    @JsonKey(name: 'janela_coleta_inicio') DateTime? janelaColetaInicio,
    @JsonKey(name: 'janela_coleta_fim') DateTime? janelaColetaFim,
    @JsonKey(name: 'criado_em') required DateTime criadoEm,
    @JsonKey(name: 'atualizado_em') DateTime? atualizadoEm,
    @Default(false) bool avulsa,
    @JsonKey(name: 'nome_contato') String? nomeContato,
    @JsonKey(name: 'cpf_contato') String? cpfContato,
    @JsonKey(name: 'telefone_contato') String? telefoneContato,
    @JsonKey(name: 'cep_contato') String? cepContato,
    @JsonKey(name: 'logradouro_contato') String? logradouroContato,
    @JsonKey(name: 'numero_contato') String? numeroContato,
    @JsonKey(name: 'complemento_contato') String? complementoContato,
    @JsonKey(name: 'bairro_contato') String? bairroContato,
    @JsonKey(name: 'cidade_contato') String? cidadeContato,
    @JsonKey(name: 'uf_contato') String? ufContato,
  }) = _SolicitacaoModel;

  factory SolicitacaoModel.fromJson(Map<String, dynamic> json) =>
      _$SolicitacaoModelFromJson(json);

  /// Constroi o model a partir da entidade de dominio. Cobre tanto o fluxo
  /// normal (cliente cadastrado) quanto o fluxo avulso, cujos campos extras
  /// (contato/endereco de contato) ficam null quando nao se aplicam.
  factory SolicitacaoModel.fromEntity(SolicitacaoEntity e) => SolicitacaoModel(
    id: e.id,
    clienteId: e.clienteId,
    coletadorId: e.coletadorId,
    status: e.status.valorBanco,
    enderecoId: e.enderecoId,
    descricaoItem: e.descricaoItem,
    codigoDevolucao: e.codigoDevolucao,
    observacoes: e.observacoes,
    janelaColetaInicio: e.janelaColetaInicio,
    janelaColetaFim: e.janelaColetaFim,
    criadoEm: e.criadoEm,
    atualizadoEm: e.atualizadoEm,
    avulsa: e.avulsa,
    nomeContato: e.nomeContato,
    cpfContato: e.cpfContato,
    telefoneContato: e.telefoneContato,
    cepContato: e.cepContato,
    logradouroContato: e.logradouroContato,
    numeroContato: e.numeroContato,
    complementoContato: e.complementoContato,
    bairroContato: e.bairroContato,
    cidadeContato: e.cidadeContato,
    ufContato: e.ufContato,
  );

  SolicitacaoEntity toEntity() => SolicitacaoEntity(
    id: id,
    clienteId: clienteId,
    coletadorId: coletadorId,
    status: StatusSolicitacaoX.fromBanco(status),
    enderecoId: enderecoId,
    descricaoItem: descricaoItem,
    codigoDevolucao: codigoDevolucao,
    observacoes: observacoes,
    janelaColetaInicio: janelaColetaInicio,
    janelaColetaFim: janelaColetaFim,
    criadoEm: criadoEm,
    atualizadoEm: atualizadoEm,
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
