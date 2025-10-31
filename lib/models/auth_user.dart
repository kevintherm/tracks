class AuthUser {
  final String uid;
  final String photoPath;
  final String name;
  final String email;

  AuthUser({
    required this.uid,
    required this.photoPath,
    required this.name,
    required this.email,
  });

  factory AuthUser.fromMap(Map<String, dynamic> data, String uid) {
    return AuthUser(
      uid: uid,
      photoPath: data['avatar'] ?? data['photoPath'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  static AuthUser empty() {
    return AuthUser(uid: '', photoPath: '', name: '', email: '');
  }

  AuthUser copyWith({
    String? uid,
    String? name,
    String? photoPath,
    String? email,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      email: email ?? this.email,
    );
  }
}
