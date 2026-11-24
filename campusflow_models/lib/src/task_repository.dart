import 'task.dart';

/// Contrat : permet d'échanger l'implémentation (API réelle, simulation, test).
abstract class TaskRepository {
  Future<List<Task>> charger();

  /// Crée la tâche et renvoie la version avec l'`id` donné par le serveur.
  Future<Task> creer(Task tache);

  /// Modifie uniquement les champs fournis (PATCH) et renvoie la tâche à jour.
  Future<Task> modifier(int id, Map<String, dynamic> champs);

  Future<void> supprimer(int id);
}

/// Dépôt simulé (« Fake ») : garde les tâches en mémoire, attend un peu,
/// ou échoue si [echec] vaut true. Utile pour les tests et le mode hors serveur.
class SimulatedTaskRepository implements TaskRepository {
  final Duration delai;
  final bool echec;

  SimulatedTaskRepository({
    this.delai = const Duration(seconds: 1),
    this.echec = false,
  }) : _taches = _donnees.map(Task.fromJson).toList();

  static const List<Map<String, dynamic>> _donnees = [
    {
      'id': 1,
      'titre': 'TP Dart',
      'echeance': '2026-11-05T12:00:00.000',
      'terminee': false,
      'description': 'Modèles de CampusFlow',
    },
    {
      'id': 2,
      'titre': 'Projet',
      'echeance': '2026-11-15T23:59:00.000',
      'terminee': false,
    },
    {
      'id': 3,
      'titre': 'QCM',
      'echeance': '2026-10-30T08:00:00.000',
      'terminee': true,
    },
  ];

  final List<Task> _taches;
  int _prochainId = 4;

  Future<void> _attendre() async {
    await Future.delayed(delai);
    if (echec) {
      throw Exception('Réseau indisponible (simulation)');
    }
  }

  @override
  Future<List<Task>> charger() async {
    await _attendre();
    return List.of(_taches);
  }

  @override
  Future<Task> creer(Task tache) async {
    await _attendre();
    final cree = tache.copyWith(id: _prochainId++);
    _taches.add(cree);
    return cree;
  }

  @override
  Future<Task> modifier(int id, Map<String, dynamic> champs) async {
    await _attendre();
    final i = _taches.indexWhere((t) => t.id == id);
    if (i < 0) throw Exception('Tâche $id introuvable');
    final fusion = {..._taches[i].toJson(), ...champs};
    final maj = Task.fromJson({'id': id, ...fusion});
    _taches[i] = maj;
    return maj;
  }

  @override
  Future<void> supprimer(int id) async {
    await _attendre();
    _taches.removeWhere((t) => t.id == id);
  }
}
