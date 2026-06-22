import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/domain/entities/pedido.dart';
import 'package:posta_pra_mim/domain/entities/pedido_detalhe.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';
import 'package:posta_pra_mim/domain/repositories/pedido_repository.dart';

/// Implementação MOCK em memória — sem chamadas HTTP.
///
/// Para plugar a API real, crie um `PedidoRemoteDataSource` (mesmo
/// padrão de `AuthRemoteDataSource`) e troque esta classe por uma
/// `PedidoRepositoryImpl` que delegue a ele, mantendo a mesma
/// interface [PedidoRepository] — nenhum código de apresentação
/// precisa mudar.
final class MockPedidoRepository implements PedidoRepository {
  MockPedidoRepository() : _pedidos = _seedPedidos();

  final List<Pedido> _pedidos;

  /// Detalhes completos mockados, indexados por `pedido.id`. Avaliado
  /// sob demanda (`late`) a partir de [_pedidos] para reaproveitar os
  /// mesmos dados já exibidos na lista (código, valor, status etc.) —
  /// evita divergência entre o card e a tela de detalhes.
  late final Map<String, PedidoDetalhe> _detalhes = _seedDetalhes(_pedidos);

  static List<Pedido> _seedPedidos() {
    final now = DateTime.now();
    return [
      Pedido(
        id: '1',
        codigo: 'FORD-90234',
        clienteNome: 'João Silva',
        status: PedidoStatus.solicitado,
        prioridade: PedidoPrioridade.urgente,
        formaPagamento: FormaPagamento.pendente,
        endereco: 'Bairro Centro, Nº 123 (Próximo à Praça)',
        valor: 145.90,
        criadoEm: now.subtract(const Duration(minutes: 12)),
      ),
      Pedido(
        id: '2',
        codigo: 'FORD-90235',
        clienteNome: 'Ana Paula Martins',
        status: PedidoStatus.despachado,
        prioridade: PedidoPrioridade.urgente,
        formaPagamento: FormaPagamento.pix,
        endereco: 'Bairro Industrial, Nº 450 (Galpão B)',
        valor: 892.00,
        criadoEm: now.subtract(const Duration(hours: 1)),
      ),
      Pedido(
        id: '3',
        codigo: 'FORD-90236',
        clienteNome: 'Carlos Eduardo',
        status: PedidoStatus.emTransito,
        prioridade: PedidoPrioridade.normal,
        formaPagamento: FormaPagamento.cartao,
        endereco: 'Bairro Jardim, Nº 88 (Casa Verde)',
        valor: 56.20,
        criadoEm: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }

  static Map<String, PedidoDetalhe> _seedDetalhes(List<Pedido> pedidos) {
    Pedido byId(String id) => pedidos.firstWhere((p) => p.id == id);

    return {
      '1': PedidoDetalhe(
        pedido: byId('1'),
        mensagemStatus: 'Recebemos sua solicitação e em breve um de nossos '
            'atendentes irá analisá-la.',
        remetente: const Remetente(
          nomeCompleto: 'Posta Pra Mim Logística',
          cpf: '12.345.678/0001-90',
          telefone: '(11) 4002-8922',
          email: 'coleta@postapramim.com.br',
          enderecoOrigem: 'Av. Paulista, 1000 - Bela Vista, São Paulo - SP, '
              'CEP: 01310-100',
        ),
        destinatario: const Destinatario(
          nomeCompleto: 'João Silva',
          cpf: '123.***.***-00',
          telefone: '(11) 91234-5678',
          email: 'joao.silva@email.com',
          enderecoEntrega: 'Rua Eduardo Prado, 123 - Centro, São Paulo - SP, '
              'CEP: 01005-000',
        ),
        carga: const InformacoesCarga(
          tipo: 'Envelope',
          pesoKg: 0.5,
          comprimentoCm: 24,
          larguraCm: 16,
          alturaCm: 2,
          fragil: false,
        ),
        documentos: const [
          PedidoDocumento(
            titulo: 'Nota Fiscal',
            nomeArquivo: 'NF-e_2026_010.pdf',
            url: 'https://docs.postapramim.com.br/nf/2026_010.pdf',
          ),
        ],
      ),
      '2': PedidoDetalhe(
        pedido: byId('2'),
        mensagemStatus: 'Seu pedido foi coletado e está a caminho da '
            'transportadora.',
        remetente: const Remetente(
          nomeCompleto: 'TechSupply Distribuidora Ltda',
          cpf: '98.765.432/0001-11',
          telefone: '(11) 3456-7890',
          email: 'logistica@techsupply.com.br',
          enderecoOrigem: 'Rua dos Componentes, 200 - Distrito Industrial, '
              'São Paulo - SP, CEP: 04571-020',
        ),
        destinatario: const Destinatario(
          nomeCompleto: 'Ana Paula Martins',
          cpf: '456.***.***-21',
          telefone: '(11) 98765-1122',
          email: 'ana.martins@email.com',
          enderecoEntrega: 'Av. das Indústrias, 450 - Galpão B, Bairro '
              'Industrial, São Paulo - SP, CEP: 03950-000',
        ),
        carga: const InformacoesCarga(
          tipo: 'Pacote',
          pesoKg: 5.2,
          comprimentoCm: 40,
          larguraCm: 30,
          alturaCm: 20,
          fragil: true,
        ),
        dataPagamento: DateTime.now().subtract(const Duration(hours: 2)),
        documentos: const [
          PedidoDocumento(
            titulo: 'Nota Fiscal',
            nomeArquivo: 'NF-e_2026_002.pdf',
            url: 'https://docs.postapramim.com.br/nf/2026_002.pdf',
          ),
          PedidoDocumento(
            titulo: 'Declaração de Conteúdo',
            nomeArquivo: 'DEC_CON_00002.pdf',
            url: 'https://docs.postapramim.com.br/dec/00002.pdf',
          ),
        ],
        localizacaoAtual: const LocalizacaoPacote(
          descricao: 'Centro de Distribuição São Paulo - SP',
          latitude: -23.5505,
          longitude: -46.6333,
        ),
      ),
      '3': PedidoDetalhe(
        pedido: byId('3'),
        mensagemStatus: 'Seu pedido foi postado, '
            'aguarde o recebimento do comprovante.',
        remetente: const Remetente(
          nomeCompleto: 'Loja Variedades Bom Preço',
          cpf: '11.222.333/0001-44',
          telefone: '(11) 2233-4455',
          email: 'pedidos@bompreco.com.br',
          enderecoOrigem: 'Rua do Comércio, 88 - Centro, São Paulo - SP, '
              'CEP: 01001-000',
        ),
        destinatario: const Destinatario(
          nomeCompleto: 'Carlos Eduardo',
          cpf: '789.***.***-55',
          telefone: '(11) 98765-4321',
          email: 'carlos.eduardo@email.com',
          enderecoEntrega: 'Rua das Azaleias, 452 - Apt 12B, Vila Clementina, '
              'São Paulo - SP, CEP: 04026-000',
        ),
        carga: const InformacoesCarga(
          tipo: 'Caixa',
          pesoKg: 2.0,
          comprimentoCm: 20,
          larguraCm: 20,
          alturaCm: 20,
          fragil: true,
        ),
        dataPagamento: DateTime(2023, 10, 15, 14, 30),
        documentos: const [
          PedidoDocumento(
            titulo: 'Nota Fiscal',
            nomeArquivo: 'NF-e_2026_003.pdf',
            url: 'https://docs.postapramim.com.br/nf/2026_003.pdf',
          ),
          PedidoDocumento(
            titulo: 'Declaração de Conteúdo',
            nomeArquivo: 'DEC_CON_00003.pdf',
            url: 'https://docs.postapramim.com.br/dec/00003.pdf',
          ),
        ],
        localizacaoAtual: const LocalizacaoPacote(
          descricao: 'Centro de Distribuição São Paulo - SP',
          latitude: -23.5505,
          longitude: -46.6333,
        ),
      ),
    };
  }

  @override
  Future<PedidosResumo> getResumo() async {
    // Simula latência de rede para que estados de loading na UI
    // sejam exercitados mesmo com dados mockados.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final total = 1284;
    final solicitados = 42;
    final aceitos = 0; // exibido como "—" quando zero, ver widget
    final despachados = 1086;
    const valorTotal = 15400.0;

    return PedidosResumo(
      totalPedidos: total,
      solicitados: solicitados,
      aceitos: aceitos,
      despachados: despachados,
      valorTotal: valorTotal,
    );
  }

  @override
  Future<List<Pedido>> getPedidosRecentes({
    String? query,
    PedidoStatus? statusFiltro,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    var result = List<Pedido>.from(_pedidos);

    if (statusFiltro != null) {
      result = result.where((p) => p.status == statusFiltro).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final normalized = query.trim().toLowerCase();
      result = result
          .where(
            (p) =>
                p.codigo.toLowerCase().contains(normalized) ||
                p.clienteNome.toLowerCase().contains(normalized),
          )
          .toList();
    }

    return result;
  }

  @override
  Future<Pedido> atualizarStatus({
    required String pedidoId,
    required PedidoStatus novoStatus,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final index = _pedidos.indexWhere((p) => p.id == pedidoId);
    if (index == -1) {
      throw const UnknownFailure('Pedido não encontrado.');
    }

    final atualizado = Pedido(
      id: _pedidos[index].id,
      codigo: _pedidos[index].codigo,
      clienteNome: _pedidos[index].clienteNome,
      status: novoStatus,
      prioridade: _pedidos[index].prioridade,
      formaPagamento: _pedidos[index].formaPagamento,
      endereco: _pedidos[index].endereco,
      valor: _pedidos[index].valor,
      criadoEm: _pedidos[index].criadoEm,
    );
    _pedidos[index] = atualizado;
    return atualizado;
  }

  @override
  Future<PedidoDetalhe> getPedidoDetalhe(String pedidoId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final detalhe = _detalhes[pedidoId];
    if (detalhe == null) {
      throw const UnknownFailure('Pedido não encontrado.');
    }
    return detalhe;
  }
}
