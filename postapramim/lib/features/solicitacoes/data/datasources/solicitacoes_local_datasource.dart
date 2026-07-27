import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:postapramim/core/error/exceptions.dart';
import 'package:postapramim/features/solicitacoes/data/models/solicitacao_model.dart';

abstract interface class SolicitacoesLocalDatasource {
  /// [chave] permite manter caches separados por contexto (ex.: lista do
  /// cliente logado vs. lista completa usada no dashboard do coletador).
  /// Por padrão usa a chave 'solicitacoes' (compatível com código antigo).
  Future<void> salvarLista(List<SolicitacaoModel> lista, {String? chave});
  Future<List<SolicitacaoModel>> obterLista({String? chave});
  Future<void> limpar({String? chave});
}

/// Usa a box genérica de cache (ver AppConstants.boxCacheGenerico). Cada
/// contexto (cliente, coletador) grava sob uma chave própria para não
/// sobrescrever o cache um do outro quando o app está offline.
class SolicitacoesLocalDatasourceImpl implements SolicitacoesLocalDatasource {
  final Box _box;
  static const _chavePadrao = 'solicitacoes';

  SolicitacoesLocalDatasourceImpl(this._box);

  @override
  Future<void> salvarLista(
    List<SolicitacaoModel> lista, {
    String? chave,
  }) async {
    try {
      final jsonList = lista.map((s) => s.toJson()).toList();
      await _box.put(chave ?? _chavePadrao, jsonEncode(jsonList));
    } catch (e) {
      throw CacheException('Erro ao salvar cache de solicitações: $e');
    }
  }

  @override
  Future<List<SolicitacaoModel>> obterLista({String? chave}) async {
    try {
      final raw = _box.get(chave ?? _chavePadrao);
      if (raw == null) return [];
      final jsonList = jsonDecode(raw) as List;
      return jsonList
          .map((e) => SolicitacaoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw CacheException('Erro ao ler cache de solicitações: $e');
    }
  }

  @override
  Future<void> limpar({String? chave}) async =>
      _box.delete(chave ?? _chavePadrao);
}

/// Chaves de cache usadas pelas telas de dashboard.
class SolicitacoesCacheKeys {
  SolicitacoesCacheKeys._();
  static const minhas = 'solicitacoes_minhas';
  static const todas = 'solicitacoes_todas';
}
