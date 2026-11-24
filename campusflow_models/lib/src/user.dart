/// Un utilisateur de CampusFlow.
class User {
  final String id;
  final String nom;
  final String email;
  final String? filiere;

  const User({
    required this.id,
    required this.nom,
    required this.email,
    this.filiere,
  });

  User copyWith({
    String? id,
    String? nom,
    String? email,
    String? filiere,
  }) =>
      User(
        id: id ?? this.id,
        nom: nom ?? this.nom,
        email: email ?? this.email,
        filiere: filiere ?? this.filiere,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: '${json['id']}', // json-server renvoie un entier : on le convertit
        nom: json['nom'] as String,
        email: json['email'] as String,
        filiere: json['filiere'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'email': email,
        'filiere': filiere,
      };

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.nom == nom &&
      other.email == email &&
      other.filiere == filiere;

  @override
  int get hashCode => Object.hash(id, nom, email, filiere);

  @override
  String toString() => 'User($id, $nom)';
}
