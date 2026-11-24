import 'package:campusflow_models/campusflow_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import 'task_repository_api.dart';

enum FiltreTaches { aFaire, enRetard, faites }

List<Task> _trier(List<Task> l) =>
    [...l]..sort((a, b) => a.echeance.compareTo(b.echeance));

/// Les trois états (loading / data / error) sont gérés par `AsyncValue`.
/// Les actions lèvent une exception en cas d'échec : l'écran l'affiche
/// dans un SnackBar et la liste affichée reste intacte.
class TasksController extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    // Se reconstruit à la connexion/déconnexion : jamais de données d'un autre compte.
    final connecte = ref.watch(authControllerProvider).valueOrNull ?? false;
    if (!connecte) return [];
    final taches = await ref.read(taskRepositoryProvider).charger();
    return _trier(taches);
  }

  List<Task> get _courantes => state.valueOrNull ?? [];

  Future<void> rafraichir() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> ajouter(Task tache) async {
    final creee = await ref.read(taskRepositoryProvider).creer(tache);
    state = AsyncData(_trier([..._courantes, creee]));
  }

  Future<void> marquerFaite(int id) async {
    final maj =
        await ref.read(taskRepositoryProvider).modifier(id, {'terminee': true});
    state = AsyncData(_trier(
      [for (final t in _courantes) t.id == id ? maj : t],
    ));
  }

  Future<void> supprimer(int id) async {
    await ref.read(taskRepositoryProvider).supprimer(id);
    state = AsyncData(_courantes.where((t) => t.id != id).toList());
  }
}

final tasksProvider =
    AsyncNotifierProvider<TasksController, List<Task>>(TasksController.new);

final filtreProvider =
    StateProvider<FiltreTaches>((ref) => FiltreTaches.aFaire);

/// Tâche ouverte dans le volet de droite (version tablette).
final tacheSelectionneeProvider = StateProvider<int?>((ref) => null);
