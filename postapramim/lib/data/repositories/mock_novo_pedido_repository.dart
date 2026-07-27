import 'package:posta_pra_mim/domain/entities/novo_pedido.dart';
import 'package:posta_pra_mim/domain/repositories/novo_pedido_repository.dart';

/// Implementação MOCK — sem chamadas HTTP.
///
/// CEP: retorna endereço fixo para qualquer CEP de 8 dígitos,
/// simulando ViaCEP. Em produção, crie `NovoPedidoRemoteDataSource`
/// que chame `https://viacep.com.br/ws/{cep}/json/` e troque esta
/// classe, mantendo a mesma interface [NovoPedidoRepository].
final class MockNovoPedidoRepository implements NovoPedidoRepository {
  static int _contador = 90240;

  @override
  Future<DadosEnderecoCep?> buscarEnderecoPorCep(String cep) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;

    // Retorna endereço diferente conforme o primeiro dígito para tornar
    // remetente e destinatário mais realistas no protótipo.
    if (digits.startsWith('0') || digits.startsWith('1')) {
      return const DadosEnderecoCep(
        logradouro: 'Av. Paulista',
        bairro: 'Bela Vista',
        cidade: 'São Paulo',
        uf: 'SP',
      );
    }
    if (digits.startsWith('2')) {
      return const DadosEnderecoCep(
        logradouro: 'Rua Riachuelo',
        bairro: 'Centro',
        cidade: 'Rio de Janeiro',
        uf: 'RJ',
      );
    }
    return const DadosEnderecoCep(
      logradouro: 'Av. das Nações Unidas',
      bairro: 'Pinheiros',
      cidade: 'São Paulo',
      uf: 'SP',
    );
  }

  @override
  Future<PedidoCriadoResultado> criarPedido({
    required RascunhoRemetente remetente,
    required RascunhoDestinatario destinatario,
    required RascunhoCarga carga,
    required FormaPagamentoNovoPedido formaPagamento,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));

    _contador++;
    final codigo = 'FORD-$_contador';
    final valor = calcularValorEstimado(carga);

    final pix = formaPagamento == FormaPagamentoNovoPedido.pix
        ? PagamentoPix(
            codigoCopiaCola:
                '00020101021226840014br.gov.bcb.pix2562pix.postapramim'
                '.com.br/v2/${codigo.toLowerCase()}'
                '5204000053039865406${(valor * 100).toInt()}'
                '5802BR5925Posta Pra Mim Logistica6009SAO PAULO'
                '62290525${codigo}63041F3A',
            valor: valor,
            expiracao: DateTime.now().add(const Duration(minutes: 30)),
            codigoPedido: codigo,
            descricaoEnvio: 'Envio #BR${_contador ~/ 10} '
                '- ${destinatario.endereco.cidade}',
          )
        : null;

    return PedidoCriadoResultado(
      pedidoId: 'mock-$_contador',
      codigo: codigo,
      valorTotal: valor,
      formaPagamento: formaPagamento,
      pix: pix,
    );
  }

  /// Fórmula simplificada: base fixa + custo por kg + volume +
  /// extras de fragilidade e urgência.
  @override
  double calcularValorEstimado(RascunhoCarga carga) {
    final volumeCm3 = carga.comprimentoCm * carga.larguraCm * carga.alturaCm;
    final base = 15.90 + (carga.pesoKg * 8.50) + (volumeCm3 / 5000);
    final extra = (carga.fragil ? 5.0 : 0.0) + (carga.urgente ? 12.0 : 0.0);
    return double.parse((base + extra).toStringAsFixed(2));
  }
}
