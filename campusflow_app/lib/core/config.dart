import 'package:flutter/foundation.dart';

/// Adresse du serveur json-server.
///
/// - Web, Windows, macOS, Linux, simulateur iOS : `localhost` fonctionne.
/// - Émulateur Android : `localhost` désigne l'émulateur lui-même, il faut
///   `10.0.2.2` (alias de la machine hôte).
/// - Téléphone réel : donner l'IP du PC sur le Wi-Fi, par exemple
///   `flutter run --dart-define=API_URL=http://192.168.1.20:3000`.
String get apiBaseUrl {
  const fromEnv = String.fromEnvironment('API_URL');
  if (fromEnv.isNotEmpty) return fromEnv;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}
