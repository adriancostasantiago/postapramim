import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/services/connectivity_service.dart';
import 'package:postapramim/core/services/supabase_service.dart';

part 'shared_providers.g.dart';

/// Stream de conectividade — usado por qualquer feature que precise
/// reagir à volta da internet (sincronização offline-first).
@riverpod
Stream<bool> conectividade(Ref ref) => ConnectivityService.onStatusChange;

/// Client do Supabase exposto via Riverpod para os Datasources.
@riverpod
SupabaseClientRef supabaseClient(Ref ref) =>
    SupabaseClientRef(SupabaseService.client);

class SupabaseClientRef {
  final dynamic client; // SupabaseClient — tipado nos datasources reais
  SupabaseClientRef(this.client);
}

/// Boxes do Hive, abertas no bootstrap (main.dart) e expostas aqui.
final boxUsuarioProvider = Provider<Box>(
  (ref) => Hive.box(AppConstants.boxUsuario),
);
final boxRotaDoDiaProvider = Provider<Box>(
  (ref) => Hive.box(AppConstants.boxRotaDoDia),
);
final boxColetasDoDiaProvider = Provider<Box>(
  (ref) => Hive.box(AppConstants.boxColetasDoDia),
);
final boxConfiguracoesProvider = Provider<Box>(
  (ref) => Hive.box(AppConstants.boxConfiguracoes),
);
final boxCacheGenericoProvider = Provider<Box>(
  (ref) => Hive.box(AppConstants.boxCacheGenerico),
);

/// Dispara sincronização automática quando a conectividade volta.
/// Cada feature registra sua própria rotina de sync ouvindo este provider
/// (ex.: solicitacoes_providers.dart invalida a lista local -> remota).
@riverpod
class SyncOrchestrator extends _$SyncOrchestrator {
  @override
  bool build() {
    ref.listen(conectividadeProvider, (previous, next) {
      final voltouOnline = previous?.value == false && next.value == true;
      if (voltouOnline) _sincronizarTudo();
    });
    return false;
  }

  Future<void> _sincronizarTudo() async {
    // Cada feature expõe um método `sincronizar()` no seu controller;
    // aqui apenas orquestramos a chamada (ver ARCHITECTURE.md - Estratégia Offline).
    state = true;
    // ref.read(solicitacoesControllerProvider.notifier).sincronizar();
    // ref.read(coletasControllerProvider.notifier).sincronizar();
    state = false;
  }
}
