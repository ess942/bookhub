import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDataSource {
  FirebaseAuthDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> writeUserProfile({
    required String uid,
    required String fullName,
    required String email,
  }) {
    final userReference = _firestore.collection('users').doc(uid);
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userReference);
      final now = FieldValue.serverTimestamp();
      transaction.set(userReference, {
        'uid': uid,
        'fullName': fullName.trim(),
        'email': email.trim(),
        'phone': snapshot.data()?['phone'] ?? '',
        'photoUrl': snapshot.data()?['photoUrl'] ?? '',
        'createdAt': snapshot.data()?['createdAt'] ?? now,
        'updatedAt': now,
      }, SetOptions(merge: true));
    });
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentUser => _auth.currentUser;
}
