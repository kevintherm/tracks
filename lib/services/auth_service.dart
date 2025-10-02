import 'dart:async';
import 'package:pocketbase/pocketbase.dart';

import 'package:factual/models/app_user.dart';
import 'package:factual/services/pocketbase_service.dart';

class AuthService {
  late final Stream<Map<String, dynamic>?> authStateChanges;

  AuthService() {
    final controller = StreamController<Map<String, dynamic>?>.broadcast();

    // Emit the current user state on listen
    controller.onListen = () {
      controller.add(currentUser);
    };

    // Emit subsequent changes
    _pb.authStore.onChange.listen((event) {
      controller.add(event.record?.toJson());
    });

    authStateChanges = controller.stream;
  }

  /// Get the PocketBase client from the singleton service
  PocketBase get _pb => PocketBaseService.instance.client;

  Map<String, dynamic>? get currentUser => _pb.authStore.record?.toJson();

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final body = {
      'email': email,
      'password': password,
      'passwordConfirm': password,
      'name': name,
    };

    await _pb.collection('users').create(body: body);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _pb.collection('users').authWithPassword(email, password);
  }

  Future<void> signOut() async {
    _pb.authStore.clear();
  }

  Future<AppUser?> fetchUserData() async {
    final record = _pb.authStore.record;
    if (record == null) return null;

    final data = record.toJson();
    final uid = data['id'] as String? ?? '';

    return AppUser.fromMap(data, uid);
  }

  Future<void> updateProfile({required String name}) async {
    final record = _pb.authStore.record;
    if (record == null) throw Exception('No user is currently signed in.');

    await _pb.collection('users').update(record.id, body: {'name': name});
  }

  Future<void> updateEmail({
    required String email,
    required String password,
  }) async {
    final record = _pb.authStore.record;
    if (record == null) throw Exception('No user is currently signed in.');

    // Reauthenticate by signing in again
    await signInWithEmail(
      email: record.toJson()['email'] as String? ?? '',
      password: password,
    );

    await _pb.collection('users').update(record.id, body: {'email': email});
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final record = _pb.authStore.record;
    if (record == null) throw Exception('No user is currently signed in.');

    // Reauthenticate
    await signInWithEmail(
      email: record.toJson()['email'] as String? ?? '',
      password: currentPassword,
    );

    await _pb
        .collection('users')
        .update(
          record.id,
          body: {'password': newPassword, 'passwordConfirm': newPassword},
        );
  }
}
