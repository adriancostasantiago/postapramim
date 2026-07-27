import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/criar_solicitacao_avulsa_usecase.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/atualizar_status_solicitacao_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:postapramim/core/services/supabase_service.dart';
import 'package:postapramim/features/auth/presentation/providers/auth_providers.dart';
import 'package:postapramim/shared/providers/shared_providers.dart';
import 'package:postapramim/features/solicitacoes/data/datasources/solicitacoes_local_datasource.dart';
import 'package:postapramim/features/solicitacoes/data/datasources/solicitacoes_remote_datasource.dart';
import 'package:postapramim/features/solicitacoes/data/repositories/solicitacoes_repository_impl.dart';
import 'package:postapramim/features/solicitacoes/domain/entities/solicitacao_entity.dart';
import 'package:postapramim/features/solicitacoes/domain/repositories/solicitacoes_repository.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/criar_solicitacao_usecase.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/listar_solicitacoes_usecase.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/obter_solicitacao_usecase.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/cancelar_solicitacao_usecase.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/observar_solicitacoes_usecase.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/listar_minhas_solicitacoes_usecase.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/observar_minhas_solicitacoes_usecase.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/listar_todas_solicitacoes_usecase.dart';
import 'package:postapramim/features/solicitacoes/domain/usecases/observar_todas_solicitacoes_usecase.dart';

part 'solicitacoes_providers.g.dart';

// ---------------------------------------------------------------------------
// DI: Datasources -> Repository -> UseCases
// ---------------------------------------------------------------------------

@riverpod
SolicitacoesRemoteDatasource solicitacoesRemoteDatasource(Ref ref) {
  return SolicitacoesRemoteDatasourceImpl(SupabaseService.client);
}

@riverpod
CriarSolicitacaoAvulsaUsecase criarSolicitacaoAvulsaUsecase(Ref ref) =>
    CriarSolicitacaoAvulsaUsecase(ref.watch(solicitacoesRepositoryProvider));

@riverpod
SolicitacoesLocalDatasource solicitacoesLocalDatasource(Ref ref) {
  return SolicitacoesLocalDatasourceImpl(ref.watch(boxCacheGenericoProvider));
}

@riverpod
SolicitacoesRepository solicitacoesRepository(Ref ref) {
  return SolicitacoesRepositoryImpl(
    ref.watch(solicitacoesRemoteDatasourceProvider),
    ref.watch(solicitacoesLocalDatasourceProvider),
  );
}

@riverpod
CriarSolicitacaoUsecase criarSolicitacaoUsecase(Ref ref) =>
    CriarSolicitacaoUsecase(ref.watch(solicitacoesRepositoryProvider));

@riverpod
ListarSolicitacoesUsecase listarSolicitacoesUsecase(Ref ref) =>
    ListarSolicitacoesUsecase(ref.watch(solicitacoesRepositoryProvider));

@riverpod
ObterSolicitacaoUsecase obterSolicitacaoUsecase(Ref ref) =>
    ObterSolicitacaoUsecase(ref.watch(solicitacoesRepositoryProvider));

/// Busca uma solicitação por id — usado por `DetalheColetaPage` (visão do
/// coletador) e `DetalheSolicitacaoPage` (visão do cliente). É `family`
/// (recebe o id) e não realtime: cada tela chama `ref.invalidate` ou o
/// próprio Riverpod refaz a busca quando o id muda.
@riverpod
Future<Result<SolicitacaoEntity>> detalheSolicitacao(Ref ref, String id) {
  return ref.watch(obterSolicitacaoUsecaseProvider)(id);
}

@riverpod
CancelarSolicitacaoUsecase cancelarSolicitacaoUsecase(Ref ref) =>
    CancelarSolicitacaoUsecase(ref.watch(solicitacoesRepositoryProvider));

@riverpod
AtualizarStatusSolicitacaoUsecase atualizarStatusSolicitacaoUsecase(Ref ref) =>
    AtualizarStatusSolicitacaoUsecase(
      ref.watch(solicitacoesRepositoryProvider),
    );

@riverpod
ObservarSolicitacoesUsecase observarSolicitacoesUsecase(Ref ref) =>
    ObservarSolicitacoesUsecase(ref.watch(solicitacoesRepositoryProvider));

@riverpod
ListarMinhasSolicitacoesUsecase listarMinhasSolicitacoesUsecase(Ref ref) =>
    ListarMinhasSolicitacoesUsecase(ref.watch(solicitacoesRepositoryProvider));

@riverpod
ObservarMinhasSolicitacoesUsecase observarMinhasSolicitacoesUsecase(Ref ref) =>
    ObservarMinhasSolicitacoesUsecase(
      ref.watch(solicitacoesRepositoryProvider),
    );

@riverpod
ListarTodasSolicitacoesUsecase listarTodasSolicitacoesUsecase(Ref ref) =>
    ListarTodasSolicitacoesUsecase(ref.watch(solicitacoesRepositoryProvider));

@riverpod
ObservarTodasSolicitacoesUsecase observarTodasSolicitacoesUsecase(Ref ref) =>
    ObservarTodasSolicitacoesUsecase(ref.watch(solicitacoesRepositoryProvider));

// ---------------------------------------------------------------------------
// Realtime: lista de solicitações do CLIENTE logado (própria + avulsas do
// mesmo CPF), sempre atualizada. Consumida pela ClienteHomePage.
// ---------------------------------------------------------------------------

@riverpod
Stream<List<SolicitacaoEntity>> minhasSolicitacoesRealtime(Ref ref) {
  final usuario = ref.watch(authControllerProvider).usuario;
  if (usuario == null) return const Stream.empty();
  return ref.watch(observarMinhasSolicitacoesUsecaseProvider)(usuario.id);
}

// ---------------------------------------------------------------------------
// Realtime: TODAS as solicitações do sistema. Consumida pelo dashboard do
// COLETADOR — qualquer coletador autenticado enxerga toda a demanda em
// aberto (a RLS `solicitacoes_select_coletador_todas` garante isso no
// banco; aqui só verificamos se há um usuário logado).
// ---------------------------------------------------------------------------

@riverpod
Stream<List<SolicitacaoEntity>> todasSolicitacoesRealtime(Ref ref) {
  final usuario = ref.watch(authControllerProvider).usuario;
  if (usuario == null) return const Stream.empty();
  return ref.watch(observarTodasSolicitacoesUsecaseProvider)();
}

// ---------------------------------------------------------------------------
// Controller para ações (criar, cancelar) com estado de carregamento/erro
// ---------------------------------------------------------------------------

class SolicitacoesActionState {
  final bool carregando;
  final String? erro;
  const SolicitacoesActionState({this.carregando = false, this.erro});
}

@riverpod
class SolicitacoesController extends _$SolicitacoesController {
  @override
  SolicitacoesActionState build() => const SolicitacoesActionState();

  Future<bool> criar(SolicitacaoEntity solicitacao) async {
    state = const SolicitacoesActionState(carregando: true);
    final result = await ref.read(criarSolicitacaoUsecaseProvider)(solicitacao);
    return result.fold(
      onSuccess: (_) {
        state = const SolicitacoesActionState();
        ref.invalidate(minhasSolicitacoesRealtimeProvider);
        return true;
      },
      onFailure: (f) {
        state = SolicitacoesActionState(erro: f.message);
        return false;
      },
    );
  }

  Future<bool> cancelar(String id) async {
    state = const SolicitacoesActionState(carregando: true);
    final result = await ref.read(cancelarSolicitacaoUsecaseProvider)(id);
    return result.fold(
      onSuccess: (_) {
        state = const SolicitacoesActionState();
        return true;
      },
      onFailure: (f) {
        state = SolicitacoesActionState(erro: f.message);
        return false;
      },
    );
  }

  /// Avança o status de uma solicitação. Quando [coletadorId] é passado
  /// (fluxo de "aceitar"), a solicitação também passa a ficar associada a
  /// esse coletador — é isso que faz o nome do coletador aparecer pros
  /// dois lados (cliente e coletador) depois.
  Future<bool> atualizarStatus({
    required String id,
    required StatusSolicitacao novoStatus,
    String? coletadorId,
  }) async {
    state = const SolicitacoesActionState(carregando: true);
    final result = await ref.read(atualizarStatusSolicitacaoUsecaseProvider)(
      id: id,
      status: novoStatus,
      coletadorId: coletadorId,
    );
    return result.fold(
      onSuccess: (_) {
        state = const SolicitacoesActionState();
        return true;
      },
      onFailure: (f) {
        state = SolicitacoesActionState(erro: f.message);
        return false;
      },
    );
  }

  /// Chamado pelo SyncOrchestrator (shared_providers.dart) quando a
  /// conectividade volta, para reconciliar cache local com o servidor.
  Future<void> sincronizar() async {
    final usuario = ref.read(authControllerProvider).usuario;
    if (usuario == null) return;
    await ref.read(listarMinhasSolicitacoesUsecaseProvider)(usuario.id);
  }
}
