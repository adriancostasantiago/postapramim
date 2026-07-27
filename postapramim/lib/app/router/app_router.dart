import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:postapramim/app/router/route_paths.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/services/supabase_service.dart';
import 'package:postapramim/features/auth/presentation/providers/auth_providers.dart';
import 'package:postapramim/features/auth/presentation/pages/splash_page.dart';
import 'package:postapramim/features/auth/presentation/pages/boas_vindas_page.dart';
import 'package:postapramim/features/auth/presentation/pages/solicitar_sem_cadastro_page.dart';
import 'package:postapramim/features/auth/presentation/pages/login_page.dart';
import 'package:postapramim/features/auth/presentation/pages/register_page.dart';
import 'package:postapramim/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:postapramim/features/dashboard/presentation/pages/cliente_home_page.dart';
import 'package:postapramim/features/dashboard/presentation/pages/coletador_dashboard_page.dart';
import 'package:postapramim/features/enderecos/domain/entities/endereco_resumo.dart';
import 'package:postapramim/features/enderecos/presentation/pages/endereco_form_page.dart';
import 'package:postapramim/features/solicitacoes/presentation/pages/nova_solicitacao_page.dart';
import 'package:postapramim/features/solicitacoes/presentation/pages/detalhe_solicitacao_page.dart';
import 'package:postapramim/features/solicitacoes/presentation/pages/historico_solicitacoes_page.dart';
import 'package:postapramim/features/coletas/presentation/pages/minhas_coletas_page.dart';
import 'package:postapramim/features/coletas/presentation/pages/detalhe_coleta_page.dart';
import 'package:postapramim/features/coletas/presentation/pages/scanner_page.dart';
import 'package:postapramim/features/rotas/presentation/pages/mapa_rota_page.dart';
import 'package:postapramim/features/perfil/presentation/pages/perfil_page.dart';
import 'package:postapramim/features/perfil/presentation/pages/editar_perfil_page.dart';
import 'package:postapramim/features/configuracoes/presentation/pages/configuracoes_page.dart';
import 'package:postapramim/features/notificacoes/presentation/pages/notificacoes_page.dart';

/// Rotas públicas (não exigem sessão ativa).
const _rotasPublicas = {
  RoutePaths.splash,
  RoutePaths.boasVindas,
  RoutePaths.onboarding,
  RoutePaths.login,
  RoutePaths.cadastro,
  RoutePaths.recuperarSenha,
  RoutePaths.solicitarSemCadastro,
};

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      SupabaseService.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final estaLogado = authState.usuario != null;
      final indoParaPublica = _rotasPublicas.contains(state.matchedLocation);

      if (state.matchedLocation == RoutePaths.splash)
        return null; // splash decide sozinha

      if (!estaLogado && !indoParaPublica) return RoutePaths.login;

      if (estaLogado && indoParaPublica) {
        return switch (authState.usuario!.perfil) {
          PerfilUsuario.cliente => RoutePaths.clienteHome,
          PerfilUsuario.coletador => RoutePaths.coletadorDashboard,
          PerfilUsuario.administrador => RoutePaths.adminDashboard,
        };
      }
      return null;
    },
    routes: [
      GoRoute(path: RoutePaths.splash, builder: (_, __) => const SplashPage()),
      GoRoute(
        path: RoutePaths.boasVindas,
        builder: (_, __) => const BoasVindasPage(),
      ),
      GoRoute(
        path: RoutePaths.solicitarSemCadastro,
        builder: (_, __) => const SolicitarSemCadastroPage(),
      ),
      GoRoute(path: RoutePaths.login, builder: (_, __) => const LoginPage()),
      GoRoute(
        path: RoutePaths.cadastro,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: RoutePaths.recuperarSenha,
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      // Cliente
      GoRoute(
        path: RoutePaths.clienteHome,
        builder: (_, __) => const ClienteHomePage(),
      ),
      GoRoute(
        path: RoutePaths.clienteNovaSolicitacao,
        builder: (_, __) => const NovaSolicitacaoPage(),
      ),
      GoRoute(
        path: RoutePaths.clienteDetalheSolicitacao,
        builder: (_, state) =>
            DetalheSolicitacaoPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.clienteHistorico,
        builder: (_, __) => const HistoricoSolicitacoesPage(),
      ),

      // Coletador
      GoRoute(
        path: RoutePaths.coletadorDashboard,
        builder: (_, __) => const ColetadorDashboardPage(),
      ),
      GoRoute(
        path: RoutePaths.coletadorMinhasColetas,
        builder: (_, __) => const MinhasColetasPage(),
      ),
      GoRoute(
        path: RoutePaths.coletadorDetalheColeta,
        builder: (_, state) =>
            DetalheColetaPage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.coletadorScanner,
        builder: (_, __) => const ScannerPage(),
      ),
      GoRoute(
        path: RoutePaths.coletadorMapaRota,
        builder: (_, __) => const MapaRotaPage(),
      ),

      // Compartilhadas
      GoRoute(path: RoutePaths.perfil, builder: (_, __) => const PerfilPage()),
      GoRoute(
        path: RoutePaths.editarPerfil,
        builder: (_, __) => const EditarPerfilPage(),
      ),
      GoRoute(
        path: RoutePaths.configuracoes,
        builder: (_, __) => const ConfiguracoesPage(),
      ),
      GoRoute(
        path: RoutePaths.notificacoes,
        builder: (_, __) => const NotificacoesPage(),
      ),
      GoRoute(
        path: RoutePaths.clienteEnderecoForm,
        builder: (context, state) =>
            EnderecoFormPage(enderecoExistente: state.extra as EnderecoResumo?),
      ),
    ],
  );
});

/// Adapta um Stream (mudanças de sessão do Supabase) para o Listenable
/// exigido pelo `refreshListenable` do GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  late final Stream<dynamic> _stream;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _stream = stream.asBroadcastStream();
    _stream.listen((_) => notifyListeners());
  }
}
