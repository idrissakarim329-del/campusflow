import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/token_storage.dart';
import 'auth_repository.dart';

/// État : `true` = connecté (jeton présent), `false` = déconnecté.
/// Pendant la lecture du jeton au démarrage, l'état est « loading ».
class AuthController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    // Le serveur a répondu 401 : on efface le jeton et on repart sur l'écran de connexion.
    final abonnement =
        ref.read(sessionEventsProvider).expiree.listen((_) => deconnecter());
    ref.onDispose(abonnement.cancel);

    final jeton = await ref.read(tokenStorageProvider).lire();
    return jeton != null;
  }

  /// Lève une exception en cas d'échec (l'écran affiche le message).
  /// On ne passe volontairement pas par `loading` : le formulaire reste affiché.
  Future<void> login(String email, String password) async {
    final jeton = await ref.read(authRepositoryProvider).login(email, password);
    await ref.read(tokenStorageProvider).ecrire(jeton);
    state = const AsyncData(true);
  }

  Future<void> deconnecter() async {
    await ref.read(tokenStorageProvider).effacer();
    state = const AsyncData(false);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, bool>(AuthController.new);
