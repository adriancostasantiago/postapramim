import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postapramim/core/constants/supabase_constants.dart';
import 'package:postapramim/core/services/logger_service.dart';

/// Ponto único de acesso ao client Supabase.
/// Nenhuma tela ou widget deve chamar `Supabase.instance` diretamente:
/// tudo passa pelos Datasources, que usam este serviço.
class SupabaseService {
  SupabaseService._();
  static late final SupabaseClient client;

  static Future<void> initialize() async {
    print(SupabaseConstants.url);
    print(SupabaseConstants.anonKey);

    await Supabase.initialize(
      url: SupabaseConstants.url,
      publishableKey: SupabaseConstants.anonKey,
      // anonKey: SupabaseConstants.anonKey,
      debug: false,
    );
    client = Supabase.instance.client;
    LoggerService.info('Supabase inicializado com sucesso');
  }

  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;

  static RealtimeChannel channel(String name) => client.channel(name);
}
