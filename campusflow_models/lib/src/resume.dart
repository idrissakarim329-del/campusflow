import 'task.dart';

// Exercice : supprimer tout usage de « ! ».
// Avant : t.description!.trim() plante si la description est absente.

/// Correction 1 : valeur par défaut avec `??`.
String resumeParDefaut(Task t) =>
    '${t.titre} : ${(t.description ?? 'Aucune').trim()}';

/// Correction 2 : test explicite du cas null.
String resumeAvecTest(Task t) {
  final d = t.description;
  if (d == null) {
    return '${t.titre} : (pas de description)';
  }
  return '${t.titre} : ${d.trim()}';
}

/// Correction 3 : appel conditionnel avec `?.` (le résultat peut être null).
String resumeConditionnel(Task t) => '${t.titre} : ${t.description?.trim()}';
