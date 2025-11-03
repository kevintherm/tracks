class AuthUser {
  final String id;
  final String avatar;
  final String name;
  final String email;

  AuthUser({
    required this.id,
    required this.avatar,
    required this.name,
    required this.email,
  });

  factory AuthUser.fromMap(Map<String, dynamic> data, String uid) {
    return AuthUser(
      id: uid,
      avatar: data['avatar'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  static AuthUser empty() {
    return AuthUser(id: '', avatar: '', name: '', email: '');
  }

  AuthUser copyWith({
    String? uid,
    String? name,
    String? avatar,
    String? email,
  }) {
    return AuthUser(
      id: uid ?? id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
    );
  }
}
