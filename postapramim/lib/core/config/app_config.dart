/// Configuração de ambiente centralizada — mesma filosofia da
/// `API_BASE_URL` já existente em `main.dart`: valores padrão para
/// dev, sobrescritos em CI/prod via `--dart-define`.
abstract final class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zhwbxussexmugzlsgrac.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_mPyxhOhPzu60hPPoQ9-1SQ_qto1QgsW',
  );
}
