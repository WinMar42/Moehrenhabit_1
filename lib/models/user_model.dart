class User {
  final int? id;
  final String name;
  final String email;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}

