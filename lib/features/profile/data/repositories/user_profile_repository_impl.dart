import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:bookhub2/features/profile/domain/entities/user_profile.dart';
import 'package:bookhub2/features/profile/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _auth = auth ?? FirebaseAuth.instance;

  static const _userCollections = [
    'cartItems',
    'orders',
    'library',
    'favorites',
  ];

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  @override
  Future<UserProfile> getProfile(String uid) async {
    _validateUid(uid);
    final doc = await _firestore.collection('users').doc(uid).get();
    return UserProfile.fromMap(doc.data() ?? const <String, dynamic>{}, uid);
  }

  @override
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async {
    _validateUid(uid);
    final normalizedName = fullName.trim();
    if (normalizedName.isEmpty) {
      throw const ProfileFailure('Enter your full name.');
    }

    await _firestore.collection('users').doc(uid).set({
      'fullName': normalizedName,
      'phone': phone.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<String> uploadAvatar({
    required String uid,
    required Uint8List imageBytes,
    required String contentType,
  }) async {
    _validateUid(uid);
    if (imageBytes.isEmpty) {
      throw const ProfileFailure('Choose an image before uploading.');
    }

    final avatarReference = _storage.ref().child('avatars/$uid/profile.jpg');
    await avatarReference.putData(
      imageBytes,
      SettableMetadata(contentType: contentType),
    );
    final photoUrl = await avatarReference.getDownloadURL();
    await _firestore.collection('users').doc(uid).set({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return photoUrl;
  }

  @override
  Future<void> deleteAccount({
    required String uid,
    required String password,
  }) async {
    _validateUid(uid);
    if (password.isEmpty) {
      throw const ProfileFailure('Enter your password to re-authenticate.');
    }
    final user = _auth.currentUser;
    if (user == null || user.uid != uid || user.email == null) {
      throw const ProfileFailure(
        'Your session is unavailable. Sign in again and retry.',
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw ProfileFailure(_reauthenticationMessage(error.code));
    }

    final avatarReference = _storage.ref().child('avatars/$uid/profile.jpg');
    try {
      await avatarReference.delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        rethrow;
      }
    }

    final userReference = _firestore.collection('users').doc(uid);
    for (final collectionName in _userCollections) {
      final collection = userReference.collection(collectionName);
      while (true) {
        final snapshot = await collection.limit(450).get();
        if (snapshot.docs.isEmpty) break;

        final batch = _firestore.batch();
        for (final document in snapshot.docs) {
          batch.delete(document.reference);
        }
        await batch.commit();
      }
    }

    await userReference.delete();
    try {
      await user.delete();
    } on FirebaseAuthException catch (error) {
      throw ProfileFailure(_reauthenticationMessage(error.code));
    }
  }

  void _validateUid(String uid) {
    if (uid.isEmpty) {
      throw const ProfileFailure('A signed-in user is required.');
    }
  }

  String _reauthenticationMessage(String code) => switch (code) {
    'wrong-password' || 'invalid-credential' =>
      'That password is incorrect. Check it and try again.',
    'user-mismatch' =>
      'The signed-in account does not match this profile. Sign in again.',
    'requires-recent-login' =>
      'Re-authentication was not accepted. Sign in again and retry.',
    'network-request-failed' =>
      'Network error. Check your connection and try again.',
    _ => 'Could not verify your identity ($code). Please try again.',
  };
}

class ProfileFailure implements Exception {
  const ProfileFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
