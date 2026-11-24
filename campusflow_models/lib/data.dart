import 'package:campusflow_models/campusflow_models.dart';

/// Liste partagée par les écrans Échéances, Détail et Formulaire.
final List<Task> tasks = [
  Task(
    titre: 'Rapport de TP Flutter',
    echeance: DateTime(2026, 11, 12),
    description: 'Rendre le rapport du TP sur les widgets Flutter.',
  ),
  Task(
    titre: 'Projet entrepôt de données',
    echeance: DateTime(2026, 11, 15),
    description: 'Rendu du projet ETL et entrepôt de données.',
  ),
  Task(
    titre: 'Exposé machine learning',
    echeance: DateTime(2026, 11, 20),
    terminee: true,
  ),
  Task(
    titre: 'Réviser Dart',
    echeance: DateTime(2026, 11, 25),
  ),
];