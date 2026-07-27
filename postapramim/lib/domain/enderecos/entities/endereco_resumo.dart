/// Representação enxuta de uma linha da tabela `enderecos`, usada onde só
/// precisamos exibir/selecionar um endereço já cadastrado (ex.: tela de
/// nova solicitação). Não é a entidade completa de uma futura feature
/// `enderecos` (CRUD) — se/quando essa feature existir, considere
/// substituir este arquivo pela entidade de lá.
class EnderecoResumo {
  final String id;
  final String? apelido;
  final String cep;
  final String logradouro;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String uf;
  final bool principal;

  const EnderecoResumo({
    required this.id,
    this.apelido,
    required this.cep,
    required this.logradouro,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
    this.principal = false,
  });

  factory EnderecoResumo.fromJson(Map<String, dynamic> json) {
    return EnderecoResumo(
      id: json['id'] as String,
      apelido: json['apelido'] as String?,
      cep: json['cep'] as String,
      logradouro: json['logradouro'] as String,
      numero: json['numero'] as String,
      complemento: json['complemento'] as String?,
      bairro: json['bairro'] as String,
      cidade: json['cidade'] as String,
      uf: json['uf'] as String,
      principal: json['principal'] as bool? ?? false,
    );
  }

  /// Endereço formatado em duas linhas, pronto para exibição.
  String get enderecoFormatado {
    final linha1 = complemento != null && complemento!.isNotEmpty
        ? '$logradouro, $numero - $complemento'
        : '$logradouro, $numero';
    return '$linha1\n$bairro, $cidade - $uf, $cep';
  }
}
