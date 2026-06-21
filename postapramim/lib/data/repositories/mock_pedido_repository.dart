import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/domain/entities/pedido.dart';
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
}
