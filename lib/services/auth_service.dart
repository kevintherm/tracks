import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;

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

  set currentUser(dynamic record) {
    if (record == null) {
      _pb.authStore.clear();
    } else {
      // If record is a RecordModel, use its token if available, else pass null
      _pb.authStore.save(_pb.authStore.token, record);
    }
  }

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

  Future<RecordAuth> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _pb.collection('users').authWithPassword(email, password);
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

  Future<RecordModel> updateProfile({required Map<String, dynamic> toUpdate}) async {
    final record = _pb.authStore.record;
    if (record == null) throw Exception('No user is currently signed in.');

    const allowed = ['name', 'avatar', 'avatarName'];

    final body = <String, dynamic>{};
    final files = <http.MultipartFile>[];

    // Process each field
    toUpdate.forEach((key, value) {
      if (!allowed.contains(key)) return;
      
      if (key == 'avatar' && value is List<int>) {
        // This is avatar file bytes
        final fileName = toUpdate['avatarName'] as String? ?? 'avatar.jpg';
        files.add(http.MultipartFile.fromBytes(
          'avatar',
          value,
          filename: fileName,
        ));
      } else if (key != 'avatarName') {
        // Regular field
        body[key] = value;
      }
    });

    final updatedRecord = await _pb.collection('users').update(record.id, body: body, files: files);
    
    // Update the auth store with the new record
    _pb.authStore.save(_pb.authStore.token, updatedRecord);
    
    return updatedRecord;
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
    final email = record.toJson()['email'] as String? ?? '';

    // Reauthenticate
    await signInWithEmail(
      email: email,
      password: currentPassword,
    );

    final body = {
      'oldPassword': currentPassword,
      'password': newPassword, 
      'passwordConfirm': newPassword
    };

    await _pb
        .collection('users')
        .update(record.id, body: body);
        
    // Re-authenticate with new password to get a fresh token
    await signInWithEmail(
      email: email,
      password: newPassword,
    );
  }
}
