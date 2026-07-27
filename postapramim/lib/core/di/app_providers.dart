import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posta_pra_mim/data/datasources/auth_local_datasource.dart';
import 'package:posta_pra_mim/data/datasources/auth_remote_datasource.dart';
import 'package:posta_pra_mim/data/datasources/google_auth_datasource.dart';
import 'package:posta_pra_mim/data/datasources/supabase_auth_datasource.dart';
import 'package:posta_pra_mim/data/datasources/supabase_local_datasource.dart';
import 'package:posta_pra_mim/data/repositories/auth_repository_impl.dart';
import 'package:posta_pra_mim/data/repositories/mock_novo_pedido_repository.dart';
import 'package:posta_pra_mim/data/repositories/mock_pedido_repository.dart';
import 'package:posta_pra_mim/domain/repositories/auth_repository.dart';
import 'package:posta_pra_mim/domain/repositories/novo_pedido_repository.dart';
import 'package:posta_pra_mim/domain/repositories/pedido_repository.dart';
import 'package:posta_pra_mim/domain/usecases/auth_usecases.dart';
import 'package:posta_pra_mim/domain/usecases/novo_pedido_usecases.dart';
import 'package:posta_pra_mim/domain/usecases/pedido_usecases.dart';
import 'package:posta_pra_mim/presentation/shared/state/auth_controller.dart';
import 'package:posta_pra_mim/presentation/shared/state/pedidos_controller.dart';

/// Composição de dependências do app. Único lugar onde implementações
/// concretas são construídas — o resto do app depende de abstrações.
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
        // --- Infra ---
        Provider<http.Client>(
          create: (_) => http.Client(),
          dispose: (_, client) => client.close(),
        ),

        // O SupabaseClient é um singleton gerenciado pelo SDK — acesso
        // via `Supabase.instance.client` (inicializado em main.dart).
        Provider<SupabaseClient>(
          create: (_) => Supabase.instance.client,
        ),

        // --- Data sources (Supabase) ---
        Provider<AuthRemoteDataSource>(
          create: (ctx) => SupabaseAuthDataSourceImpl(
            client: ctx.read<SupabaseClient>(),
          ),
        ),
        Provider<AuthLocalDataSource>(
          create: (ctx) => SupabaseLocalDataSourceImpl(
            client: ctx.read<SupabaseClient>(),
          ),
        ),
        // STUB Google: trocar por SupabaseGoogleAuthDataSource quando
        // OAuth estiver configurado no Supabase Dashboard.
        Provider<GoogleAuthDataSource>(
          create: (_) => const GoogleAuthDataSourceStub(),
        ),

        // --- Repositories ---
        Provider<AuthRepository>(
          create: (ctx) => AuthRepositoryImpl(
            remoteDataSource: ctx.read<AuthRemoteDataSource>(),
            localDataSource: ctx.read<AuthLocalDataSource>(),
            googleAuthDataSource: ctx.read<GoogleAuthDataSource>(),
          ),
        ),

        // --- Auth use cases ---
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

        // --- Auth controller ---
        ChangeNotifierProvider<AuthController>(
          create: (ctx) => AuthController(
            loginUseCase: ctx.read<LoginUseCase>(),
            registerUseCase: ctx.read<RegisterUseCase>(),
            signInWithGoogleUseCase: ctx.read<SignInWithGoogleUseCase>(),
            getCurrentUserUseCase: ctx.read<GetCurrentUserUseCase>(),
            authRepository: ctx.read<AuthRepository>(),
          ),
        ),

        // --- Pedidos (MOCK — troque por implementação HTTP real) ---
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

        // --- Novo pedido (MOCK) ---
        // Provider<NovoPedidoRepository>(
        //   create: (_) => MockNovoPedidoRepository(),
        // ),
        // Provider<BuscarEnderecoPorCepUseCase>(
        //   create: (ctx) =>
        //       BuscarEnderecoPorCepUseCase(ctx.read<NovoPedidoRepository>()),
        // ),
        // Provider<CriarPedidoUseCase>(
        //   create: (ctx) => CriarPedidoUseCase(ctx.read<NovoPedidoRepository>()),
        // ),
        // Provider<CalcularValorEstimadoUseCase>(
        //   create: (ctx) =>
        //       CalcularValorEstimadoUseCase(ctx.read<NovoPedidoRepository>()),
        // ),

        Provider<NovoPedidoRepository>(
          create: (_) => MockNovoPedidoRepository(),
        ),
        Provider<BuscarEnderecoPorCepUseCase>(
          create: (ctx) =>
              BuscarEnderecoPorCepUseCase(ctx.read<NovoPedidoRepository>()),
        ),
        Provider<CriarPedidoUseCase>(
          create: (ctx) => CriarPedidoUseCase(ctx.read<NovoPedidoRepository>()),
        ),
        Provider<CalcularValorEstimadoUseCase>(
          create: (ctx) =>
              CalcularValorEstimadoUseCase(ctx.read<NovoPedidoRepository>()),
        ),
      ],
      child: child,
    );
  }
}
