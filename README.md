# CampusFlow

Application Flutter de gestion des échéances universitaires, réalisée dans le cadre du cours Programmation Mobile (Master).

## Contenu du dépôt

- `campusflow_models/` : package Dart (modèles Task, Course, User, `fromJson`, dépôt simulé, 3 tests)
- `server/` : API simulée avec json-server (`db.json`, middleware d'authentification)
- `campusflow_app/` : application Flutter (écrans Échéances, Détail, Formulaire, version tablette, navigation, état partagé, connexion avec jeton sécurisé)

## Lancer le projet

1. Démarrer le serveur :

   ```
   cd server
   npm install
   npx json-server db.json
   ```

2. Lancer l'application (dans un second terminal) :

   ```
   cd campusflow_app
   flutter pub get
   flutter run
   ```

3. Lancer les tests du package de modèles :

   ```
   cd campusflow_models
   dart test
   ```
