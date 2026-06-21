import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:posta_pra_mim/core/errors/failure.dart';
import 'package:posta_pra_mim/data/models/user_model.dart';

/// Fonte de dados remota — único lugar que conhece a URL/contrato HTTP
/// da API de autenticação. Repositórios dependem desta abstração via DI.
abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> logout();
}

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required http.Client client, required Uri baseUrl})
      : _client = client,
        _baseUrl = baseUrl;

  final http.Client _client;
  final Uri _baseUrl;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final http.Response response;
    try {
      response = await _client.post(
        _baseUrl.replace(path: '/auth/login'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
    } on Exception {
      throw const NetworkFailure();
    }

    if (response.statusCode == 401) {
      throw const AuthFailure('E-mail ou senha inválidos.');
    }
    if (response.statusCode >= 500) {
      throw const ServerFailure();
    }
    if (response.statusCode != 200) {
      throw const UnknownFailure();
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UserModel.fromJson(json);
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final http.Response response;
    try {
      response = await _client.post(
        _baseUrl.replace(path: '/auth/register'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );
    } on Exception {
      throw const NetworkFailure();
    }

    if (response.statusCode == 409) {
      throw const AuthFailure('Este e-mail já está cadastrado.');
    }
    if (response.statusCode >= 500) {
      throw const ServerFailure();
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw const UnknownFailure();
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UserModel.fromJson(json);
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(_baseUrl.replace(path: '/auth/logout'));
    } on Exception {
      throw const NetworkFailure();
    }
  }
}
