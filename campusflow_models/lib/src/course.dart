/// Un cours suivi par l'étudiant.
class Course {
  final String id;
  final String intitule;
  final String enseignant;
  final int credits;

  const Course({
    required this.id,
    required this.intitule,
    required this.enseignant,
    this.credits = 3,
  });

  Course copyWith({
    String? id,
    String? intitule,
    String? enseignant,
    int? credits,
  }) =>
      Course(
        id: id ?? this.id,
        intitule: intitule ?? this.intitule,
        enseignant: enseignant ?? this.enseignant,
        credits: credits ?? this.credits,
      );

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: '${json['id']}', // json-server renvoie un entier : on le convertit
        intitule: json['intitule'] as String,
        enseignant: json['enseignant'] as String,
        credits: json['credits'] as int? ?? 3,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'intitule': intitule,
        'enseignant': enseignant,
        'credits': credits,
      };

  @override
  bool operator ==(Object other) =>
      other is Course &&
      other.id == id &&
      other.intitule == intitule &&
      other.enseignant == enseignant &&
      other.credits == credits;

  @override
  int get hashCode => Object.hash(id, intitule, enseignant, credits);

  @override
  String toString() => 'Course($id, $intitule)';
}
