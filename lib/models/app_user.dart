class AppUser {
  final String uid;
  final String photoPath;
  final String name;
  final String email;

  AppUser({required this.uid, required this.photoPath, required this.name, required this.email});

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(uid: uid, photoPath: data['photoPath'] ?? '', name: data['name'] ?? '', email: data['email'] ?? '');
  }

  static AppUser empty() {
    return AppUser(uid: '', photoPath: '', name: '', email: '');
  }

  AppUser copyWith({String? uid, String? name, String? photoPath, String? email}) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      email: email ?? this.email,
    );
  }
}
