import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:factual/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Future<void> signUpWithEmail({
  //   required String name,
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     UserCredential userCredential = await _auth
  //         .createUserWithEmailAndPassword(email: email, password: password);
  //     final uid = userCredential.user?.uid;

  //     if (uid == null) throw Exception('User UID is null');

  //     await _firestore.collection('users').doc(uid).set({
  //       'name': name,
  //       'email': email,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //   } on FirebaseAuthException catch (e) {
  //     rethrow;
  //   }
  // }

  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await cred.user!.updateDisplayName(name);
    await cred.user!.reload();
    return cred.user;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('AuthService: Attempting to sign in with email');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('AuthService: Sign in successful');
    } on FirebaseAuthException {
      print('AuthService: Sign in failed');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> fetchUserData() async {
    final user = currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return null;

    return UserModel.fromMap(userDoc.data() as Map<String, dynamic>, user.uid);
  }
}
