import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/domain/entities/pedido.dart';
import 'package:posta_pra_mim/domain/entities/pedido_status.dart';
import 'package:posta_pra_mim/domain/repositories/auth_repository.dart';
import 'package:posta_pra_mim/domain/repositories/pedido_repository.dart';
import 'package:posta_pra_mim/domain/usecases/auth_usecases.dart';
import 'package:posta_pra_mim/domain/usecases/pedido_usecases.dart';
import 'package:posta_pra_mim/presentation/manager_dashboard/manager_dashboard_page.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedidos_controller.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockPedidoRepository extends Mock implements PedidoRepository {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockPedidoRepository pedidoRepository;
  late AuthController authController;
  late PedidosController pedidosController;

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
    endereco: 'Bairro Centro, Nº 123 (Próximo à Praça)',
    valor: 145.90,
    criadoEm: DateTime(2026, 1, 1),
  );

  setUp(() {
    authRepository = _MockAuthRepository();
    pedidoRepository = _MockPedidoRepository();

    authController = AuthController(
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      signInWithGoogleUseCase: SignInWithGoogleUseCase(authRepository),
      getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
      authRepository: authRepository,
    );

    pedidosController = PedidosController(
      getPedidosResumoUseCase: GetPedidosResumoUseCase(pedidoRepository),
      getPedidosRecentesUseCase: GetPedidosRecentesUseCase(pedidoRepository),
      atualizarStatusPedidoUseCase:
          AtualizarStatusPedidoUseCase(pedidoRepository),
    );
  });

  Widget buildSubject() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<PedidosController>.value(
          value: pedidosController,
        ),
      ],
      child: const MaterialApp(home: ManagerDashboardPage()),
    );
  }

  group('ManagerDashboardPage', () {
    testWidgets('mostra loading e depois o conteúdo carregado', (tester) async {
      when(() => pedidoRepository.getResumo()).thenAnswer((_) async => tResumo);
      when(
        () => pedidoRepository.getPedidosRecentes(
          query: any(named: 'query'),
          statusFiltro: any(named: 'statusFiltro'),
        ),
      ).thenAnswer((_) async => [tPedido]);

      await tester.pumpWidget(buildSubject());

      // Estado de loading aparece imediatamente após o primeiro frame.
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Despacho Correios'), findsOneWidget);
      expect(find.text('Total Pedidos'), findsOneWidget);
      expect(find.text('1284'), findsOneWidget);
      expect(find.text('Pedidos Recentes'), findsOneWidget);
      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('Aprovar Pedido'), findsOneWidget);
    });

    testWidgets('mostra estado vazio quando não há pedidos', (tester) async {
      when(() => pedidoRepository.getResumo()).thenAnswer((_) async => tResumo);
      when(
        () => pedidoRepository.getPedidosRecentes(
          query: any(named: 'query'),
          statusFiltro: any(named: 'statusFiltro'),
        ),
      ).thenAnswer((_) async => []);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text('Nenhum pedido encontrado para esse filtro.'),
        findsOneWidget,
      );
    });

    // testWidgets('mostra erro com botão de tentar novamente', (tester) async {
    //   when(() => pedidoRepository.getResumo())
    //       .thenThrow(const ServerFailure('Erro ao carregar.'));

    //   await tester.pumpWidget(buildSubject());
    //   await tester.pumpAndSettle();

    //   expect(find.text('Erro ao carregar.'), findsOneWidget);
    //   expect(find.text('Tentar novamente'), findsOneWidget);
    // });

    testWidgets('tocar em Aprovar Pedido avança o status e atualiza a UI',
        (tester) async {
      when(() => pedidoRepository.getResumo()).thenAnswer((_) async => tResumo);
      when(
        () => pedidoRepository.getPedidosRecentes(
          query: any(named: 'query'),
          statusFiltro: any(named: 'statusFiltro'),
        ),
      ).thenAnswer((_) async => [tPedido]);

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
        () => pedidoRepository.atualizarStatus(
          pedidoId: tPedido.id,
          novoStatus: PedidoStatus.aprovado,
        ),
      ).thenAnswer((_) async => pedidoAprovado);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Aprovar Pedido'));
      await tester.pumpAndSettle();

      expect(find.text('Aprovado'), findsOneWidget);
      expect(find.text('Despachar Pedido'), findsOneWidget);
    });
  });
}
