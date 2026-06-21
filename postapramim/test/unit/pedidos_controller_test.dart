import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/domain/entities/pedido.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';
import 'package:posta_pra_mim/domain/repositories/pedido_repository.dart';
import 'package:posta_pra_mim/domain/usecases/pedido_usecases.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedidos_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedidos_state.dart';

class _MockPedidoRepository extends Mock implements PedidoRepository {}

void main() {
  late _MockPedidoRepository repository;
  late PedidosController controller;

  const tResumo = PedidosResumo(
    totalPedidos: 1284,
    solicitados: 42,
    aceitos: 0,
    despachados: 1086,
    valorTotal: 15400,
  );

  final tPedido = Pedido(
    id: '1',
    codigo: 'FORD-90234',
    clienteNome: 'João Silva',
    status: PedidoStatus.solicitado,
    prioridade: PedidoPrioridade.urgente,
    formaPagamento: FormaPagamento.pendente,
    endereco: 'Bairro Centro, Nº 123',
    valor: 145.90,
    criadoEm: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(PedidoStatus.aprovado);
  });

  setUp(() {
    repository = _MockPedidoRepository();
    controller = PedidosController(
      getPedidosResumoUseCase: GetPedidosResumoUseCase(repository),
      getPedidosRecentesUseCase: GetPedidosRecentesUseCase(repository),
      atualizarStatusPedidoUseCase: AtualizarStatusPedidoUseCase(repository),
    );
  });

  group('PedidosController.load', () {
    test('emite PedidosLoading depois PedidosLoaded em caso de sucesso',
        () async {
      when(() => repository.getResumo()).thenAnswer((_) async => tResumo);
      when(
        () => repository.getPedidosRecentes(
          query: any(named: 'query'),
          statusFiltro: any(named: 'statusFiltro'),
        ),
      ).thenAnswer((_) async => [tPedido]);

      final states = <PedidosState>[];
      controller.addListener(() => states.add(controller.state));

      await controller.load();

      expect(states, [
        const PedidosLoading(),
        PedidosLoaded(resumo: tResumo, pedidos: [tPedido]),
      ]);
    });

    test('emite PedidosError quando o repositório lança Failure', () async {
      when(() => repository.getResumo())
          .thenThrow(const ServerFailure('Erro ao buscar resumo.'));

      await controller.load();

      expect(controller.state, isA<PedidosError>());
      expect(
        (controller.state as PedidosError).failure.message,
        'Erro ao buscar resumo.',
      );
    });
  });

  group('PedidosController.updateQuery', () {
    test('refiltra a lista após o debounce de 400ms', () async {
      when(() => repository.getResumo()).thenAnswer((_) async => tResumo);
      when(
        () => repository.getPedidosRecentes(
          query: any(named: 'query'),
          statusFiltro: any(named: 'statusFiltro'),
        ),
      ).thenAnswer((_) async => [tPedido]);

      await controller.load();

      when(
        () => repository.getPedidosRecentes(
          query: 'João',
          statusFiltro: any(named: 'statusFiltro'),
        ),
      ).thenAnswer((_) async => [tPedido]);

      controller.updateQuery('João');
      expect(controller.query, 'João');

      // Antes do debounce expirar, a busca ainda não foi refeita.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      verifyNever(
        () => repository.getPedidosRecentes(
          query: 'João',
          statusFiltro: any(named: 'statusFiltro'),
        ),
      );

      // Após o debounce, a busca é refeita com o novo termo.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      verify(
        () => repository.getPedidosRecentes(
          query: 'João',
          statusFiltro: any(named: 'statusFiltro'),
        ),
      ).called(1);
    });
  });

  group('PedidosController.updateStatusFiltro', () {
    test('refiltra a lista pelo status selecionado', () async {
      when(() => repository.getResumo()).thenAnswer((_) async => tResumo);
      when(
        () => repository.getPedidosRecentes(
          query: any(named: 'query'),
          statusFiltro: any(named: 'statusFiltro'),
        ),
      ).thenAnswer((_) async => [tPedido]);

      await controller.load();
      await controller.updateStatusFiltro(PedidoStatus.despachado);

      expect(controller.statusFiltro, PedidoStatus.despachado);
      verify(
        () => repository.getPedidosRecentes(
          query: any(named: 'query'),
          statusFiltro: PedidoStatus.despachado,
        ),
      ).called(1);
    });
  });

  group('PedidosController.avancarStatus', () {
    test('atualiza o pedido na lista mantendo o resumo', () async {
      when(() => repository.getResumo()).thenAnswer((_) async => tResumo);
      when(
        () => repository.getPedidosRecentes(
          query: any(named: 'query'),
          statusFiltro: any(named: 'statusFiltro'),
        ),
      ).thenAnswer((_) async => [tPedido]);

      await controller.load();

      final pedidoAprovado = Pedido(
        id: tPedido.id,
        codigo: tPedido.codigo,
        clienteNome: tPedido.clienteNome,
        status: PedidoStatus.aprovado,
        prioridade: tPedido.prioridade,
        formaPagamento: tPedido.formaPagamento,
        endereco: tPedido.endereco,
        valor: tPedido.valor,
        criadoEm: tPedido.criadoEm,
      );

      when(
        () => repository.atualizarStatus(
          pedidoId: tPedido.id,
          novoStatus: PedidoStatus.aprovado,
        ),
      ).thenAnswer((_) async => pedidoAprovado);

      await controller.avancarStatus(
        pedidoId: tPedido.id,
        novoStatus: PedidoStatus.aprovado,
      );

      final state = controller.state as PedidosLoaded;
      expect(state.pedidos.single.status, PedidoStatus.aprovado);
      expect(state.resumo, tResumo);
    });

    test('emite PedidosError quando a atualização falha', () async {
      when(() => repository.getResumo()).thenAnswer((_) async => tResumo);
      when(
        () => repository.getPedidosRecentes(
          query: any(named: 'query'),
          statusFiltro: any(named: 'statusFiltro'),
        ),
      ).thenAnswer((_) async => [tPedido]);

      await controller.load();

      when(
        () => repository.atualizarStatus(
          pedidoId: any(named: 'pedidoId'),
          novoStatus: any(named: 'novoStatus'),
        ),
      ).thenThrow(const UnknownFailure('Pedido não encontrado.'));

      await controller.avancarStatus(
        pedidoId: tPedido.id,
        novoStatus: PedidoStatus.aprovado,
      );

      expect(controller.state, isA<PedidosError>());
    });
  });
}
