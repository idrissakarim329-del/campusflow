import 'package:campusflow_models/campusflow_models.dart';
import 'package:test/test.dart';

void main() {
  test('copyWith modifie un champ et conserve les autres', () {
    final t = Task(titre: 'TP Dart', echeance: DateTime(2026, 11, 5));
    final fait = t.copyWith(terminee: true);

    expect(fait.terminee, isTrue);
    expect(fait.titre, 'TP Dart');
    expect(fait.echeance, t.echeance);
    expect(t.terminee, isFalse); // l'original n'a pas changé
  });

  test('fromJson construit Task, Course et User', () {
    final t = Task.fromJson({
      'titre': 'QCM',
      'echeance': '2026-10-30T08:00:00.000',
      'terminee': true,
    });
    expect(t.titre, 'QCM');
    expect(t.echeance, DateTime(2026, 10, 30, 8));
    expect(t.terminee, isTrue);
    expect(t.description, isNull);

    final c = Course.fromJson({
      'id': 'c1',
      'intitule': 'Programmation mobile',
      'enseignant': 'M. Ouédraogo',
    });
    expect(c.credits, 3);

    final u = User.fromJson({'id': 'u1', 'nom': 'Idrissa', 'email': 'i@mail.bf'});
    expect(u.filiere, isNull);
  });

  test('erreurs attendues : JSON invalide et dépôt en échec', () async {
    expect(() => Task.fromJson({}), throwsA(isA<TypeError>()));

    final repo = SimulatedTaskRepository(delai: Duration.zero, echec: true);
    await expectLater(repo.charger(), throwsA(isA<Exception>()));
  });
}
