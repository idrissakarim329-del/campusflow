import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config.dart';
import 'token_storage.dart';

/// Flux d'événements « session expirée » : l'intercepteur y publie quand le
/// serveur répond 401 sur une route protégée (jeton absent, expiré ou invalide),
/// et le contrôleur d'authentification l'écoute pour déconnecter l'utilisateur.
class SessionEvents {
  final _controller = StreamController<void>.broadcast();
  Stream<void> get expiree => _controller.stream;
  void signalerExpiration() => _controller.add(null);
  void dispose() => _controller.close();
}

final sessionEventsProvider = Provider<SessionEvents>((ref) {
  final events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
});

/// Intercepteur : ajoute `Authorization: Bearer <jeton>` à chaque requête
/// et signale les réponses 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._onExpired);

  final TokenStorage _storage;
  final void Function() _onExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final jeton = await _storage.lire();
    if (jeton != null) {
      options.headers['Authorization'] = 'Bearer $jeton';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Un 401 sur /login signifie « mauvais mot de passe », pas « session expirée ».
    final estLogin = err.requestOptions.path.endsWith('/login');
    if (err.response?.statusCode == 401 && !estLogin) {
      _onExpired();
    }
    handler.next(err);
  }
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
      contentType: Headers.jsonContentType,
    ),
  );
  dio.interceptors.add(
    AuthInterceptor(
      ref.read(tokenStorageProvider),
      ref.read(sessionEventsProvider).signalerExpiration,
    ),
  );
  return dio;
});

/// Transforme une erreur Dio en message lisible pour l'utilisateur.
String messageErreur(Object e) {
  if (e is DioException) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Serveur injoignable ($apiBaseUrl). '
            'Vérifiez que json-server est lancé et que l\'adresse est correcte.';
      default:
        final data = e.response?.data;
        if (data is Map && data['message'] is String) {
          return data['message'] as String;
        }
        return 'Erreur serveur (${e.response?.statusCode ?? 'inconnue'}).';
    }
  }
  return 'Erreur : $e';
}
