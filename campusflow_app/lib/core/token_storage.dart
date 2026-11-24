import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stockage du jeton dans le coffre sécurisé de l'appareil
/// (Keychain sur iOS/macOS, Keystore sur Android).
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const _cle = 'campusflow_token';
  final FlutterSecureStorage _storage;

  Future<String?> lire() async {
    try {
      return await _storage.read(key: _cle);
    } catch (_) {
      return null; // coffre illisible : on considère l'utilisateur déconnecté
    }
  }

  Future<void> ecrire(String jeton) => _storage.write(key: _cle, value: jeton);

  Future<void> effacer() => _storage.delete(key: _cle);
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
