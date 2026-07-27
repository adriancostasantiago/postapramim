import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postapramim/core/constants/supabase_constants.dart';
import 'package:postapramim/core/error/exceptions.dart';
import 'package:postapramim/features/solicitacoes/data/models/solicitacao_model.dart';

abstract interface class SolicitacoesRemoteDatasource {
  Future<SolicitacaoModel> criar(SolicitacaoModel solicitacao);
  Future<void> criarAvulsa({
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
  });

  /// Solicitações do cliente logado (fluxo com cadastro).
  Future<List<SolicitacaoModel>> listarPorCliente(String clienteId);
  Stream<List<SolicitacaoModel>> observarPorCliente(String clienteId);

  /// Solicitações do cliente logado + solicitações avulsas feitas com o
  /// mesmo CPF do cadastro (ex.: pediu sem login e depois criou conta).
  Future<List<SolicitacaoModel>> listarPorClienteOuCpf({
    required String clienteId,
    String? cpf,
  });
  Stream<List<SolicitacaoModel>> observarPorClienteOuCpf({
    required String clienteId,
    String? cpf,
  });

  /// Todas as solicitações do sistema — usado pelo dashboard do coletador,
  /// que precisa enxergar toda a demanda em aberto, não só a já atribuída
  /// a ele. Depende da policy de RLS `solicitacoes_select_coletador_todas`.
  Future<List<SolicitacaoModel>> listarTodas();
  Stream<List<SolicitacaoModel>> observarTodas();

  Future<SolicitacaoModel> obterPorId(String id);
  Future<void> cancelar(String id);

  /// Atualiza o status de uma solicitação — usado pelo coletador para
  /// avançar o fluxo (ex.: aceita -> em_rota -> coletada -> ...) ou
  /// cancelar. Quando [coletadorId] é informado, também associa a
  /// solicitação a esse coletador (ex.: no momento em que ele aceita).
  Future<void> atualizarStatus({
    required String id,
    required String status,
    String? coletadorId,
  });

  /// CPF cadastrado do cliente (tabela `clientes`). Usado para casar
  /// solicitações avulsas feitas antes do cadastro.
  Future<String?> obterCpfCliente(String clienteId);

  // Stream<List<SolicitacaoModel>> observarPorCliente(String clienteId);
}

class SolicitacoesRemoteDatasourceImpl implements SolicitacoesRemoteDatasource {
  final SupabaseClient _client;
  SolicitacoesRemoteDatasourceImpl(this._client);

  @override
  Future<SolicitacaoModel> criar(SolicitacaoModel solicitacao) async {
    try {
      // Removemos 'id' (deixa o banco gerar) e qualquer chave com valor
      // null. Isso é importante especialmente para 'atualizado_em': se
      // mandarmos `null` explícito, o Postgres grava NULL e ignora o
      // `default now()` da coluna — o default só entra em ação quando a
      // chave nem aparece no payload.
      final payload = solicitacao.toJson()..remove('id');
      payload.removeWhere((_, value) => value == null);

      final data = await _client
          .from(SupabaseConstants.tableSolicitacoes)
          .insert(payload)
          .select()
          .single();
      return SolicitacaoModel.fromJson(data);
    } catch (e) {
      throw ServerException('Erro ao criar solicitação: $e');
    }
  }

  @override
  Future<void> criarAvulsa({
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
      await _client.from(SupabaseConstants.tableSolicitacoes).insert({
        'avulsa': true,
        'codigo_devolucao': codigoDevolucao,
        'nome_contato': nomeContato,
        'cpf_contato': cpfContato,
        'telefone_contato': telefoneContato,
        'cep_contato': cep,
        'logradouro_contato': logradouro,
        'numero_contato': numero,
        'complemento_contato': complemento,
        'bairro_contato': bairro,
        'cidade_contato': cidade,
        'uf_contato': uf,
      });
    } catch (e) {
      throw ServerException('Erro ao criar solicitação avulsa: $e');
    }
  }

  @override
  Future<List<SolicitacaoModel>> listarPorCliente(String clienteId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.tableSolicitacoes)
          .select()
          .eq('cliente_id', clienteId)
          .order('criado_em', ascending: false);
      return (data as List).map((e) => SolicitacaoModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException('Erro ao listar solicitações: $e');
    }
  }

  @override
  Future<List<SolicitacaoModel>> listarPorClienteOuCpf({
    required String clienteId,
    String? cpf,
  }) async {
    try {
      final porCliente = await _client
          .from(SupabaseConstants.tableSolicitacoes)
          .select()
          .eq('cliente_id', clienteId)
          .order('criado_em', ascending: false);

      final modelosPorCliente = (porCliente as List)
          .map((e) => SolicitacaoModel.fromJson(e))
          .toList();

      if (cpf == null || cpf.isEmpty) return modelosPorCliente;

      final porCpf = await _client
          .from(SupabaseConstants.tableSolicitacoes)
          .select()
          .eq('avulsa', true)
          .eq('cpf_contato', cpf)
          .order('criado_em', ascending: false);

      final modelosPorCpf = (porCpf as List)
          .map((e) => SolicitacaoModel.fromJson(e))
          .toList();

      return _mesclarPorId([modelosPorCliente, modelosPorCpf]);
    } catch (e) {
      throw ServerException('Erro ao listar solicitações do cliente: $e');
    }
  }

  @override
  Future<List<SolicitacaoModel>> listarTodas() async {
    try {
      final data = await _client
          .from(SupabaseConstants.tableSolicitacoes)
          .select()
          .order('criado_em', ascending: false);
      return (data as List).map((e) => SolicitacaoModel.fromJson(e)).toList();
    } catch (e) {
      throw ServerException('Erro ao listar todas as solicitações: $e');
    }
  }

  @override
  Future<SolicitacaoModel> obterPorId(String id) async {
    try {
      final data = await _client
          .from(SupabaseConstants.tableSolicitacoes)
          .select()
          .eq('id', id)
          .single();
      return SolicitacaoModel.fromJson(data);
    } catch (e) {
      throw ServerException('Erro ao obter solicitação: $e');
    }
  }

  @override
  Future<void> cancelar(String id) async {
    try {
      await _client
          .from(SupabaseConstants.tableSolicitacoes)
          .update({'status': 'cancelada'})
          .eq('id', id);
    } catch (e) {
      throw ServerException('Erro ao cancelar solicitação: $e');
    }
  }

  @override
  Future<void> atualizarStatus({
    required String id,
    required String status,
    String? coletadorId,
  }) async {
    try {
      final payload = <String, dynamic>{'status': status};
      if (coletadorId != null) payload['coletador_id'] = coletadorId;

      await _client
          .from(SupabaseConstants.tableSolicitacoes)
          .update(payload)
          .eq('id', id);
    } catch (e) {
      throw ServerException('Erro ao atualizar status da solicitação: $e');
    }
  }

  @override
  Future<String?> obterCpfCliente(String clienteId) async {
    try {
      final data = await _client
          .from('clientes')
          .select('cpf')
          .eq('usuario_id', clienteId)
          .maybeSingle();
      return data?['cpf'] as String?;
    } catch (e) {
      throw ServerException('Erro ao obter CPF do cliente: $e');
    }
  }

  /// Realtime: emite uma nova lista sempre que houver INSERT/UPDATE/DELETE
  /// na tabela `solicitacoes` filtrada pelo cliente — cobre os eventos
  /// "nova coleta", "coleta aceita", "cancelada" e "concluída" do escopo.
  @override
  Stream<List<SolicitacaoModel>> observarPorCliente(String clienteId) {
    return _client
        .from(SupabaseConstants.tableSolicitacoes)
        .stream(primaryKey: ['id'])
        .eq('cliente_id', clienteId)
        .order('criado_em', ascending: false)
        .map((rows) => rows.map((e) => SolicitacaoModel.fromJson(e)).toList());
  }

  /// Combina o realtime das solicitações do cliente com o realtime das
  /// avulsas do mesmo CPF. O client de realtime do Supabase só aceita um
  /// filtro `.eq()` por stream, então mesclamos duas streams aqui.
  @override
  Stream<List<SolicitacaoModel>> observarPorClienteOuCpf({
    required String clienteId,
    String? cpf,
  }) {
    final streamCliente = observarPorCliente(clienteId);
    if (cpf == null || cpf.isEmpty) return streamCliente;

    final streamCpf = _client
        .from(SupabaseConstants.tableSolicitacoes)
        .stream(primaryKey: ['id'])
        .eq('cpf_contato', cpf)
        .order('criado_em', ascending: false)
        .map(
          (rows) => rows
              .map((e) => SolicitacaoModel.fromJson(e))
              .where((m) => m.avulsa)
              .toList(),
        );

    return _mesclarStreams(streamCliente, streamCpf);
  }

  @override
  Stream<List<SolicitacaoModel>> observarTodas() {
    return _client
        .from(SupabaseConstants.tableSolicitacoes)
        .stream(primaryKey: ['id'])
        .order('criado_em', ascending: false)
        .map((rows) => rows.map((e) => SolicitacaoModel.fromJson(e)).toList());
  }

  // -------------------------------------------------------------------
  // Helpers de merge (sem depender de rxdart)
  // -------------------------------------------------------------------

  List<SolicitacaoModel> _mesclarPorId(List<List<SolicitacaoModel>> listas) {
    final porId = <String, SolicitacaoModel>{};
    for (final lista in listas) {
      for (final m in lista) {
        porId[m.id] = m;
      }
    }
    final resultado = porId.values.toList()
      ..sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
    return resultado;
  }

  Stream<List<SolicitacaoModel>> _mesclarStreams(
    Stream<List<SolicitacaoModel>> a,
    Stream<List<SolicitacaoModel>> b,
  ) {
    late final StreamController<List<SolicitacaoModel>> controller;
    List<SolicitacaoModel> ultimaA = [];
    List<SolicitacaoModel> ultimaB = [];
    StreamSubscription<List<SolicitacaoModel>>? subA;
    StreamSubscription<List<SolicitacaoModel>>? subB;
    var recebeuA = false;
    var recebeuB = false;

    void emitir() {
      if (!recebeuA && !recebeuB) return;
      controller.add(_mesclarPorId([ultimaA, ultimaB]));
    }

    controller = StreamController<List<SolicitacaoModel>>(
      onListen: () {
        subA = a.listen((v) {
          ultimaA = v;
          recebeuA = true;
          emitir();
        }, onError: controller.addError);
        subB = b.listen((v) {
          ultimaB = v;
          recebeuB = true;
          emitir();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await subA?.cancel();
        await subB?.cancel();
      },
    );

    return controller.stream;
  }
}
