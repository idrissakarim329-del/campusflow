import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';

/// Appelle le faux serveur d'authentification : POST /login.
class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  /// Renvoie le jeton. Lève une [DioException] (401) si les identifiants sont faux.
  Future<String> login(String email, String password) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/login',
      data: {'email': email, 'password': password},
    );
    final jeton = res.data?['token'];
    if (jeton is! String || jeton.isEmpty) {
      throw Exception('Réponse de connexion invalide : jeton absent.');
    }
    return jeton;
  }
}

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository(ref.watch(dioProvider)));
