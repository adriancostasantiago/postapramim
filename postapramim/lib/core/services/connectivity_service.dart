import 'package:connectivity_plus/connectivity_plus.dart';

/// Expõe stream de conectividade usado pelos providers de sincronização
/// (ver shared/providers/shared_providers.dart) para disparar sync
/// automático quando a internet retorna.
class ConnectivityService {
  ConnectivityService._();
  static final Connectivity _connectivity = Connectivity();

  static Stream<bool> get onStatusChange => _connectivity.onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));

  static Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
