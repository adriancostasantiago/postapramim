import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:posta_pra_mim/data/datasources/auth_local_datasource.dart';
import 'package:posta_pra_mim/data/datasources/auth_remote_datasource.dart';
import 'package:posta_pra_mim/data/datasources/google_auth_datasource.dart';
import 'package:posta_pra_mim/data/repositories/auth_repository_impl.dart';
import 'package:posta_pra_mim/data/repositories/mock_pedido_repository.dart';
import 'package:posta_pra_mim/domain/repositories/auth_repository.dart';
import 'package:posta_pra_mim/domain/repositories/pedido_repository.dart';
import 'package:posta_pra_mim/domain/usecases/auth_usecases.dart';
import 'package:posta_pra_mim/domain/usecases/pedido_usecases.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedidos_controller.dart';

/// Composição de dependências do app. Único lugar onde implementações
/// concretas são construídas — o resto do app depende de abstrações.
///
/// Ambientes diferentes (dev/staging/prod) passam `baseUrl` distintas
/// via configuração (ex: `--dart-define=API_BASE_URL=...`), nunca via
/// `if` em runtime.
final class AppProviders extends StatelessWidget {
  const AppProviders({
    required this.baseUrl,
    required this.child,
    super.key,
  });

  final Uri baseUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- Infra (singletons) ---
        Provider<http.Client>(
          create: (_) => http.Client(),
          dispose: (_, client) => client.close(),
        ),

        // --- Data sources ---
        Provider<AuthRemoteDataSource>(
          create: (ctx) => AuthRemoteDataSourceImpl(
            client: ctx.read<http.Client>(),
            baseUrl: baseUrl,
          ),
        ),
        Provider<AuthLocalDataSource>(
          create: (_) => AuthLocalDataSourceImpl(),
        ),
        // STUB: troque por GoogleAuthDataSourceImpl quando o
        // google_sign_in for configurado (ver datasource para detalhes).
        Provider<GoogleAuthDataSource>(
          create: (_) => const GoogleAuthDataSourceStub(),
        ),

        // --- Repositories (dependem de abstrações) ---
        Provider<AuthRepository>(
          create: (ctx) => AuthRepositoryImpl(
            remoteDataSource: ctx.read<AuthRemoteDataSource>(),
            localDataSource: ctx.read<AuthLocalDataSource>(),
            googleAuthDataSource: ctx.read<GoogleAuthDataSource>(),
          ),
        ),

        // --- Use cases ---
        Provider<LoginUseCase>(
          create: (ctx) => LoginUseCase(ctx.read<AuthRepository>()),
        ),
        Provider<RegisterUseCase>(
          create: (ctx) => RegisterUseCase(ctx.read<AuthRepository>()),
        ),
        Provider<SignInWithGoogleUseCase>(
          create: (ctx) => SignInWithGoogleUseCase(ctx.read<AuthRepository>()),
        ),
        Provider<GetCurrentUserUseCase>(
          create: (ctx) => GetCurrentUserUseCase(ctx.read<AuthRepository>()),
        ),

        // --- Controllers (estado de apresentação) ---
        ChangeNotifierProvider<AuthController>(
          create: (ctx) => AuthController(
            loginUseCase: ctx.read<LoginUseCase>(),
            registerUseCase: ctx.read<RegisterUseCase>(),
            signInWithGoogleUseCase: ctx.read<SignInWithGoogleUseCase>(),
            getCurrentUserUseCase: ctx.read<GetCurrentUserUseCase>(),
            authRepository: ctx.read<AuthRepository>(),
          ),
        ),

        // --- Pedidos (dashboard do gestor) ---
        // MOCK: troque por uma implementação HTTP quando o endpoint
        // de pedidos existir — interface PedidoRepository não muda.
        Provider<PedidoRepository>(
          create: (_) => MockPedidoRepository(),
        ),
        Provider<GetPedidosResumoUseCase>(
          create: (ctx) =>
              GetPedidosResumoUseCase(ctx.read<PedidoRepository>()),
        ),
        Provider<GetPedidosRecentesUseCase>(
          create: (ctx) =>
              GetPedidosRecentesUseCase(ctx.read<PedidoRepository>()),
        ),
        Provider<AtualizarStatusPedidoUseCase>(
          create: (ctx) =>
              AtualizarStatusPedidoUseCase(ctx.read<PedidoRepository>()),
        ),
        // Use case stateless — o controller de detalhes (escopo por
        // pedidoId) é instanciado localmente pela própria página, ver
        // `pedido_detalhe_page.dart`.
        Provider<GetPedidoDetalheUseCase>(
          create: (ctx) =>
              GetPedidoDetalheUseCase(ctx.read<PedidoRepository>()),
        ),
        ChangeNotifierProvider<PedidosController>(
          create: (ctx) => PedidosController(
            getPedidosResumoUseCase: ctx.read<GetPedidosResumoUseCase>(),
            getPedidosRecentesUseCase: ctx.read<GetPedidosRecentesUseCase>(),
            atualizarStatusPedidoUseCase:
                ctx.read<AtualizarStatusPedidoUseCase>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
