import 'package:campusflow_models/campusflow_models.dart';

Future<void> main() async {
  final repo = SimulatedTaskRepository(delai: Duration(milliseconds: 500));

  print('Chargement...');
  try {
    final taches = await repo.charger();
    print('${taches.length} tâche(s)');
    for (final t in taches) {
      print(' - ${resumeParDefaut(t)}');
    }
    final premiere = taches.first.copyWith(terminee: true);
    print('Après copyWith : ${premiere.terminee} (original : ${taches.first.terminee})');
  } catch (e) {
    print('Erreur : $e');
  } finally {
    print('Fin du chargement');
  }

  try {
    await SimulatedTaskRepository(
      delai: Duration(milliseconds: 100),
      echec: true,
    ).charger();
  } catch (e) {
    print('Échec attendu : $e');
  }
}
