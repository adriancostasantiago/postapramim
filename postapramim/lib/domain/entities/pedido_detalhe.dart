import 'package:equatable/equatable.dart';
import 'package:posta_pra_mim/domain/entities/pedido.dart';

/// Dados do destinatário, exibidos apenas na tela de detalhes do
/// pedido (a listagem usa só `Pedido.clienteNome`/`endereco` resumidos).
final class Destinatario extends Equatable {
  const Destinatario({
    required this.nomeCompleto,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.enderecoEntrega,
  });

  final String nomeCompleto;
  final String cpf;
  final String telefone;
  final String email;
  final String enderecoEntrega;

  @override
  List<Object?> get props =>
      [nomeCompleto, cpf, telefone, email, enderecoEntrega];
}

/// Dados de quem está enviando o pacote. Mesma estrutura de campos de
/// [Destinatario], mas mantida como entidade própria — semanticamente
/// representam papéis diferentes no pedido (origem x destino), mesmo
/// quando o formato dos dados coincide.
final class Remetente extends Equatable {
  const Remetente({
    required this.nomeCompleto,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.enderecoOrigem,
  });

  final String nomeCompleto;
  final String cpf;
  final String telefone;
  final String email;
  final String enderecoOrigem;

  @override
  List<Object?> get props =>
      [nomeCompleto, cpf, telefone, email, enderecoOrigem];
}

/// Características físicas da carga transportada.
final class InformacoesCarga extends Equatable {
  const InformacoesCarga({
    required this.tipo,
    required this.pesoKg,
    required this.comprimentoCm,
    required this.larguraCm,
    required this.alturaCm,
    required this.fragil,
  });

  final String tipo;
  final double pesoKg;
  final int comprimentoCm;
  final int larguraCm;
  final int alturaCm;
  final bool fragil;

  /// Ex: "20x20x20".
  String get dimensoesLabel => '${comprimentoCm}x${larguraCm}x$alturaCm';

  @override
  List<Object?> get props =>
      [tipo, pesoKg, comprimentoCm, larguraCm, alturaCm, fragil];
}

/// Documento anexado ao pedido (nota fiscal, declaração de conteúdo etc).
final class PedidoDocumento extends Equatable {
  const PedidoDocumento({
    required this.titulo,
    required this.nomeArquivo,
    required this.url,
  });

  final String titulo;
  final String nomeArquivo;
  final String url;

  @override
  List<Object?> get props => [titulo, nomeArquivo, url];
}

/// Localização atual do pacote, usada na prévia de mapa da tela de
/// detalhes. Mantém apenas o que a UI precisa — sem depender de SDK
/// de mapas no domínio.
final class LocalizacaoPacote extends Equatable {
  const LocalizacaoPacote({
    required this.descricao,
    required this.latitude,
    required this.longitude,
  });

  final String descricao;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [descricao, latitude, longitude];
}

/// Visão completa de um pedido, usada na tela de detalhes. Compõe a
/// entidade [Pedido] (já usada na listagem) com os dados adicionais
/// exibidos apenas nesta tela — evita duplicar campos já existentes
/// (código, status, prioridade, forma de pagamento, valor).
final class PedidoDetalhe extends Equatable {
  const PedidoDetalhe({
    required this.pedido,
    required this.mensagemStatus,
    required this.remetente,
    required this.destinatario,
    required this.carga,
    required this.documentos,
    this.dataPagamento,
    this.localizacaoAtual,
  });

  final Pedido pedido;

  /// Mensagem contextual exibida abaixo do stepper de status (ex:
  /// "Seu pacote saiu do centro de distribuição...").
  final String mensagemStatus;

  final Remetente remetente;
  final Destinatario destinatario;
  final InformacoesCarga carga;
  final List<PedidoDocumento> documentos;
  final DateTime? dataPagamento;
  final LocalizacaoPacote? localizacaoAtual;

  @override
  List<Object?> get props => [
        pedido,
        mensagemStatus,
        remetente,
        destinatario,
        carga,
        documentos,
        dataPagamento,
        localizacaoAtual,
      ];
}
