import 'package:equatable/equatable.dart';

/// Tipo de embalagem selecionado na etapa "Carga".
enum TipoCarga {
  caixa,
  envelope,
  pallet;

  String get label => switch (this) {
        TipoCarga.caixa => 'Caixa',
        TipoCarga.envelope => 'Envelope',
        TipoCarga.pallet => 'Pallet',
      };
}

/// Forma de pagamento escolhida na etapa "Revisão".
enum FormaPagamentoNovoPedido {
  cartaoCredito,
  pix,
  boleto;

  String get label => switch (this) {
        FormaPagamentoNovoPedido.cartaoCredito => 'Cartão de Crédito',
        FormaPagamentoNovoPedido.pix => 'Pix',
        FormaPagamentoNovoPedido.boleto => 'Boleto Bancário',
      };
}

/// Endereço retornado por consulta de CEP (ex: ViaCEP). Apenas os
/// campos preenchíveis automaticamente — nº e complemento são sempre
/// digitados pelo usuário.
final class DadosEnderecoCep extends Equatable {
  const DadosEnderecoCep({
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  final String logradouro;
  final String bairro;
  final String cidade;
  final String uf;

  @override
  List<Object?> get props => [logradouro, bairro, cidade, uf];
}

/// Endereço completo informado pelo usuário em uma das etapas.
final class RascunhoEndereco extends Equatable {
  const RascunhoEndereco({
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento = '',
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  final String cep;
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;

  /// Linha completa para exibição no card de revisão.
  String get resumo => '$logradouro, $numero'
      '${complemento.isNotEmpty ? ' - $complemento' : ''}'
      ' - $bairro, $cidade - $uf';

  @override
  List<Object?> get props =>
      [cep, logradouro, numero, complemento, bairro, cidade, uf];
}

/// Dados do remetente coletados na etapa 1.
final class RascunhoRemetente extends Equatable {
  const RascunhoRemetente({
    required this.nomeCompleto,
    required this.cpfOuCnpj,
    required this.telefone,
    required this.endereco,
  });

  final String nomeCompleto;
  final String cpfOuCnpj;
  final String telefone;
  final RascunhoEndereco endereco;

  @override
  List<Object?> get props => [nomeCompleto, cpfOuCnpj, telefone, endereco];
}

/// Dados do destinatário coletados na etapa 2.
final class RascunhoDestinatario extends Equatable {
  const RascunhoDestinatario({
    required this.nomeCompleto,
    required this.cpfOuCnpj,
    required this.telefone,
    required this.endereco,
  });

  final String nomeCompleto;
  final String cpfOuCnpj;
  final String telefone;
  final RascunhoEndereco endereco;

  @override
  List<Object?> get props => [nomeCompleto, cpfOuCnpj, telefone, endereco];
}

/// Dados da carga coletados na etapa 3.
final class RascunhoCarga extends Equatable {
  const RascunhoCarga({
    required this.tipo,
    required this.pesoKg,
    required this.larguraCm,
    required this.alturaCm,
    required this.comprimentoCm,
    required this.fragil,
    required this.urgente,
    this.observacoes = '',
  });

  final TipoCarga tipo;
  final double pesoKg;
  final double larguraCm;
  final double alturaCm;
  final double comprimentoCm;
  final bool fragil;
  final bool urgente;
  final String observacoes;

  /// Ex: "40 × 30 × 20 cm".
  String get dimensoesLabel => '${comprimentoCm.toStringAsFixed(0)} × '
      '${larguraCm.toStringAsFixed(0)} × '
      '${alturaCm.toStringAsFixed(0)} cm';

  @override
  List<Object?> get props => [
        tipo,
        pesoKg,
        larguraCm,
        alturaCm,
        comprimentoCm,
        fragil,
        urgente,
        observacoes
      ];
}

/// Dados para pagamento via Pix retornados após criação do pedido.
final class PagamentoPix extends Equatable {
  const PagamentoPix({
    required this.codigoCopiaCola,
    required this.valor,
    required this.expiracao,
    required this.codigoPedido,
    required this.descricaoEnvio,
  });

  final String codigoCopiaCola;
  final double valor;
  final DateTime expiracao;
  final String codigoPedido;
  final String descricaoEnvio;

  @override
  List<Object?> get props =>
      [codigoCopiaCola, valor, expiracao, codigoPedido, descricaoEnvio];
}

/// Resultado retornado após a criação bem-sucedida de um pedido.
final class PedidoCriadoResultado extends Equatable {
  const PedidoCriadoResultado({
    required this.pedidoId,
    required this.codigo,
    required this.valorTotal,
    required this.formaPagamento,
    this.pix,
  });

  final String pedidoId;
  final String codigo;
  final double valorTotal;
  final FormaPagamentoNovoPedido formaPagamento;

  /// Não-nulo apenas quando [formaPagamento] é `pix`.
  final PagamentoPix? pix;

  @override
  List<Object?> get props =>
      [pedidoId, codigo, valorTotal, formaPagamento, pix];
}
