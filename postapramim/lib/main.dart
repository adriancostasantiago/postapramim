import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:postapramim/app/app.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/services/supabase_service.dart';
import 'package:postapramim/core/services/notification_service.dart';
import 'package:postapramim/core/services/logger_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  // Cache local (Hive)
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.boxUsuario);
  await Hive.openBox(AppConstants.boxRotaDoDia);
  await Hive.openBox(AppConstants.boxColetasDoDia);
  await Hive.openBox(AppConstants.boxConfiguracoes);
  await Hive.openBox(AppConstants.boxCacheGenerico);

  // Backend
  await SupabaseService.initialize();

  // Firebase / Push
  try {
    await Firebase.initializeApp();
    await NotificationService.initialize();
  } catch (e) {
    LoggerService.warning('Firebase não inicializado (config pendente): $e');
  }

  runApp(const ProviderScope(child: PostaPraMimApp()));
}
