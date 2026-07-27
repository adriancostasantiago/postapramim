import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:postapramim/core/services/logger_service.dart';
import 'package:postapramim/core/services/supabase_service.dart';

/// Gerencia o ciclo de vida do FCM:
/// - solicita permissão
/// - obtém/atualiza o device token e salva em `usuarios.fcm_token`
/// - escuta mensagens em foreground/background
/// O disparo do push (server-side) acontece via Edge Function do Supabase,
/// chamada pelos triggers de mudança de status (ver database/schema.sql).
class NotificationService {
  NotificationService._();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    LoggerService.info(
      'Permissão de notificação: ${settings.authorizationStatus}',
    );

    final token = await _messaging.getToken();
    if (token != null) await _salvarToken(token);

    _messaging.onTokenRefresh.listen(_salvarToken);

    FirebaseMessaging.onMessage.listen((message) {
      LoggerService.info('Push recebido em foreground: ${message.messageId}');
      // TODO: disparar snackbar/local notification e invalidar providers relevantes
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // TODO: navegar via GoRouter para a tela referente ao payload (deep link)
    });
  }

  static Future<void> _salvarToken(String token) async {
    final userId = SupabaseService.auth.currentUser?.id;
    if (userId == null) return;
    await SupabaseService.client
        .from('usuarios')
        .update({'fcm_token': token})
        .eq('id', userId);
  }
}
