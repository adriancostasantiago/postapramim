import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/error/exceptions.dart';
import 'package:postapramim/core/error/failures.dart';
import 'package:postapramim/core/error/result.dart';
import 'package:postapramim/core/services/connectivity_service.dart';
import 'package:postapramim/core/services/logger_service.dart';
import 'package:postapramim/features/solicitacoes/data/datasources/solicitacoes_local_datasource.dart';
import 'package:postapramim/features/solicitacoes/data/datasources/solicitacoes_remote_datasource.dart';
import 'package:postapramim/features/solicitacoes/data/models/solicitacao_model.dart';
import 'package:postapramim/features/solicitacoes/domain/entities/solicitacao_entity.dart';
import 'package:postapramim/features/solicitacoes/domain/repositories/solicitacoes_repository.dart';

class SolicitacoesRepositoryImpl implements SolicitacoesRepository {
  final SolicitacoesRemoteDatasource _remote;
  final SolicitacoesLocalDatasource _local;

  SolicitacoesRepositoryImpl(this._remote, this._local);

  @override
  Future<Result<SolicitacaoEntity>> criar(SolicitacaoEntity solicitacao) async {
    try {
      final model = await _remote.criar(
        SolicitacaoModel.fromEntity(solicitacao),
      );
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> criarAvulsa({
    required String codigoDevolucao,
    required String nomeContato,
    required String cpfContato,
    required String telefoneContato,
    required String cep,
    required String logradouro,
    required String numero,
    String? complemento,
    required String bairro,
    required String cidade,
    required String uf,
  }) async {
    try {
      await _remote.criarAvulsa(
        codigoDevolucao: codigoDevolucao,
        nomeContato: nomeContato,
        cpfContato: cpfContato,
        telefoneContato: telefoneContato,
        cep: cep,
        logradouro: logradouro,
        numero: numero,
        complemento: complemento,
        bairro: bairro,
        cidade: cidade,
        uf: uf,
      );
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SolicitacaoEntity>>> listarPorCliente(
    String clienteId,
  ) async {
    final online = await ConnectivityService.isOnline;

    if (!online) {
      LoggerService.info('Offline: lendo solicitações do cache local');
      final cache = await _local.obterLista(
        chave: SolicitacoesCacheKeys.minhas,
      );
      return Result.success(cache.map((m) => m.toEntity()).toList());
    }

    try {
      final modelos = await _remote.listarPorCliente(clienteId);
      await _local.salvarLista(modelos, chave: SolicitacoesCacheKeys.minhas);
      return Result.success(modelos.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      final cache = await _local.obterLista(
        chave: SolicitacoesCacheKeys.minhas,
      );
      if (cache.isNotEmpty) {
        return Result.success(cache.map((m) => m.toEntity()).toList());
      }
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Lista as solicitações do cliente logado + as avulsas feitas com o
  /// mesmo CPF do cadastro dele (caso tenha solicitado sem estar logado
  /// antes de criar a conta).
  @override
  Future<Result<List<SolicitacaoEntity>>> listarMinhas(String clienteId) async {
    final online = await ConnectivityService.isOnline;

    if (!online) {
      LoggerService.info('Offline: lendo minhas solicitações do cache local');
      final cache = await _local.obterLista(
        chave: SolicitacoesCacheKeys.minhas,
      );
      return Result.success(cache.map((m) => m.toEntity()).toList());
    }

    try {
      final cpf = await _remote.obterCpfCliente(clienteId);
      final modelos = await _remote.listarPorClienteOuCpf(
        clienteId: clienteId,
        cpf: cpf,
      );
      await _local.salvarLista(modelos, chave: SolicitacoesCacheKeys.minhas);
      return Result.success(modelos.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      final cache = await _local.obterLista(
        chave: SolicitacoesCacheKeys.minhas,
      );
      if (cache.isNotEmpty) {
        return Result.success(cache.map((m) => m.toEntity()).toList());
      }
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Todas as solicitações — dashboard do coletador. A RLS
  /// (`solicitacoes_select_coletador_todas`) garante que só um usuário
  /// com perfil coletador consegue de fato ler tudo aqui.
  @override
  Future<Result<List<SolicitacaoEntity>>> listarTodas() async {
    final online = await ConnectivityService.isOnline;

    if (!online) {
      LoggerService.info('Offline: lendo todas as solicitações do cache local');
      final cache = await _local.obterLista(chave: SolicitacoesCacheKeys.todas);
      return Result.success(cache.map((m) => m.toEntity()).toList());
    }

    try {
      final modelos = await _remote.listarTodas();
      await _local.salvarLista(modelos, chave: SolicitacoesCacheKeys.todas);
      return Result.success(modelos.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      final cache = await _local.obterLista(chave: SolicitacoesCacheKeys.todas);
      if (cache.isNotEmpty) {
        return Result.success(cache.map((m) => m.toEntity()).toList());
      }
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<SolicitacaoEntity>> obterPorId(String id) async {
    try {
      final model = await _remote.obterPorId(id);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> cancelar(String id) async {
    try {
      await _remote.cancelar(id);
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> atualizarStatus({
    required String id,
    required StatusSolicitacao status,
    String? coletadorId,
  }) async {
    try {
      await _remote.atualizarStatus(
        id: id,
        status: status.valorBanco,
        coletadorId: coletadorId,
      );
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<List<SolicitacaoEntity>> observarPorCliente(String clienteId) {
    return _remote
        .observarPorCliente(clienteId)
        .map((modelos) => modelos.map((m) => m.toEntity()).toList());
  }

  /// Stream combinada: solicitações do cliente + avulsas do mesmo CPF.
  /// Faz uma busca única do CPF antes de abrir o stream (o CPF do cliente
  /// não muda com frequência, então não precisa ser reativo).
  @override
  Stream<List<SolicitacaoEntity>> observarMinhas(String clienteId) {
    return Stream.fromFuture(_remote.obterCpfCliente(clienteId)).asyncExpand((
      cpf,
    ) {
      return _remote
          .observarPorClienteOuCpf(clienteId: clienteId, cpf: cpf)
          .map((modelos) => modelos.map((m) => m.toEntity()).toList());
    });
  }

  @override
  Stream<List<SolicitacaoEntity>> observarTodas() {
    return _remote.observarTodas().map(
      (modelos) => modelos.map((m) => m.toEntity()).toList(),
    );
  }
}
