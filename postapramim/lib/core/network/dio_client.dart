import 'package:dio/dio.dart';
import 'package:postapramim/core/constants/app_constants.dart';
import 'package:postapramim/core/services/logger_service.dart';

/// Cliente Dio isolado, usado SOMENTE para APIs externas (ex.: ViaCEP).
/// Toda comunicação com o backend do app usa o SupabaseService — nunca Dio.
class DioClient {
  DioClient._();

  static final Dio viaCep =
      Dio(
          BaseOptions(
            baseUrl: 'https://viacep.com.br/ws/',
            connectTimeout: const Duration(
              seconds: AppConstants.timeoutRequestSeconds,
            ),
            receiveTimeout: const Duration(
              seconds: AppConstants.timeoutRequestSeconds,
            ),
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onError: (error, handler) {
              LoggerService.error('Erro Dio (ViaCEP)', error);
              handler.next(error);
            },
          ),
        );
}
