import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:factual/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signUpWithEmail({required String name, required String email, required String password}) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = userCredential.user?.uid;

    if (uid == null) throw Exception('User UID is null');

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signInWithEmail({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> fetchUserData() async {
    final user = currentUser;
    if (user == null) return null;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return null;

    return AppUser.fromMap(userDoc.data() as Map<String, dynamic>, user.uid);
  }

  Future<void> updateProfile({required String name}) async {
    final user = currentUser;
    if (user == null) throw Exception('No user is currently signed in.');

    // Update name in Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'name': name,
    });
  }

  Future<void> updateEmail({required String email, required String password}) async {
    final user = currentUser;
    if (user == null) throw Exception('No user is currently signed in.');

    // Reauthenticate the user
    await reauthenticateUser(email: user.email!, password: password);

    // Update email in Firebase Authentication
    if (user.email != email) {
      await user.verifyBeforeUpdateEmail(email);
    }

    // Update email in Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'email': email,
    });
  }

  Future<void> reauthenticateUser({required String email, required String password}) async {
    final user = currentUser;
    if (user == null) throw Exception('No user is currently signed in.');

    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> updatePassword({required String currentPassword, required String newPassword}) async {
    final user = currentUser;
    if (user == null) throw Exception('No user is currently signed in.');

    // Reauthenticate the user
    await reauthenticateUser(email: user.email!, password: currentPassword);

    // Update the password in Firebase Authentication
    await user.updatePassword(newPassword);
  }
}
