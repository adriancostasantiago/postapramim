class SupabaseConstants {
  SupabaseConstants._();

  // Carregados via --dart-define ou arquivo .env (nunca commitar chaves reais)
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Tabelas
  static const String tableUsuarios = 'usuarios';
  static const String tableClientes = 'clientes';
  static const String tableColetadores = 'coletadores';
  static const String tableAdministradores = 'administradores';
  static const String tableEnderecos = 'enderecos';
  static const String tableSolicitacoes = 'solicitacoes';
  static const String tableColetas = 'coletas';
  static const String tableRotas = 'rotas';
  static const String tableHistoricoStatus = 'historico_status';
  static const String tableNotificacoes = 'notificacoes';
  static const String tableArquivos = 'arquivos';
  static const String tableConfiguracoes = 'configuracoes';

  // Storage buckets
  static const String bucketFotosColeta = 'fotos-coleta';
  static const String bucketFotosEmbalagem = 'fotos-embalagem';
  static const String bucketComprovantes = 'comprovantes';
  static const String bucketDocumentos = 'documentos';
  static const String bucketAvatares = 'avatares';

  // Realtime channels
  static const String channelSolicitacoes = 'realtime:solicitacoes';
  static const String channelColetas = 'realtime:coletas';
  static const String channelNotificacoes = 'realtime:notificacoes';

  // Edge Functions
  static const String fnEnviarPush = 'enviar-push-notification';
  static const String fnAtribuirColeta = 'atribuir-coleta';
}
