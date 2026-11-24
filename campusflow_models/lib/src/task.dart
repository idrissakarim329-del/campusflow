/// Une tâche à rendre ou à réaliser. Objet immuable : on crée une copie
/// avec [copyWith] au lieu de modifier l'existant.
class Task {
  /// Identifiant attribué par le serveur (null tant que la tâche n'est pas créée).
  final int? id;
  final String titre;
  final DateTime echeance;
  final bool terminee;
  final String? description;

  /// Cours associé (clé étrangère vers `courses`), optionnel.
  final int? courseId;

  const Task({
    this.id,
    required this.titre,
    required this.echeance,
    this.terminee = false,
    this.description,
    this.courseId,
  });

  Task copyWith({
    int? id,
    String? titre,
    DateTime? echeance,
    bool? terminee,
    String? description,
    int? courseId,
  }) =>
      Task(
        id: id ?? this.id,
        titre: titre ?? this.titre,
        echeance: echeance ?? this.echeance,
        terminee: terminee ?? this.terminee,
        description: description ?? this.description,
        courseId: courseId ?? this.courseId,
      );

  /// En retard : non terminée et échéance dépassée.
  bool get enRetard => !terminee && echeance.isBefore(DateTime.now());

  /// Lève une [TypeError] si `titre` ou `echeance` manque ou a un mauvais type.
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: (json['id'] as num?)?.toInt(),
        titre: json['titre'] as String,
        echeance: DateTime.parse(json['echeance'] as String),
        terminee: json['terminee'] as bool? ?? false,
        description: json['description'] as String?,
        courseId: (json['courseId'] as num?)?.toInt(),
      );

  /// Corps envoyé au serveur. `id` n'est pas envoyé : c'est le serveur qui le donne.
  Map<String, dynamic> toJson() => {
        'titre': titre,
        'echeance': echeance.toIso8601String(),
        'terminee': terminee,
        if (description != null) 'description': description,
        if (courseId != null) 'courseId': courseId,
      };

  @override
  bool operator ==(Object other) =>
      other is Task &&
      other.id == id &&
      other.titre == titre &&
      other.echeance == echeance &&
      other.terminee == terminee &&
      other.description == description &&
      other.courseId == courseId;

  @override
  int get hashCode =>
      Object.hash(id, titre, echeance, terminee, description, courseId);

  @override
  String toString() => 'Task(#$id $titre, échéance: $echeance, terminée: $terminee)';
}
