import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_data_source.dart';
import '../errors/auth_error_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final FirebaseAuthDataSource _dataSource;
  String? _pendingProfileName;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _dataSource.authStateChanges().map(_mapUser);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _dataSource.signIn(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Sign in failed. Please try again.');
      }
      return _mapUser(user)!;
    } on FirebaseAuthException catch (error) {
      throw AuthErrorMapper.fromFirebaseAuth(error);
    }
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // Keep profile completion pending before auth emits the new signed-in user.
      _pendingProfileName = fullName.trim();
      final credential = await _dataSource.createAccount(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('Account creation failed. Please try again.');
      }

      try {
        await _dataSource.writeUserProfile(
          uid: user.uid,
          fullName: fullName,
          email: user.email ?? email,
        );
        _pendingProfileName = null;
        return _mapUser(user)!;
      } on FirebaseException catch (error) {
        throw AuthFailure(
          'Your account was created, but your profile could not be saved. '
          'Check your connection and retry.',
          profileSetupPending: true,
          cause: error,
        );
      } catch (error) {
        throw AuthFailure(
          'Your account was created, but your profile could not be saved. '
          'Check your connection and retry.',
          profileSetupPending: true,
          cause: error,
        );
      }
    } on FirebaseAuthException catch (error) {
      _pendingProfileName = null;
      throw AuthErrorMapper.fromFirebaseAuth(error);
    }
  }

  @override
  Future<void> retryUserProfile({required String fullName}) async {
    final user = _dataSource.currentUser;
    if (user == null) {
      _pendingProfileName = null;
      throw const AuthFailure(
        'Your session expired. Sign in before retrying profile setup.',
      );
    }

    try {
      await _dataSource.writeUserProfile(
        uid: user.uid,
        fullName: fullName.trim().isEmpty
            ? (_pendingProfileName ?? user.displayName ?? '')
            : fullName,
        email: user.email ?? '',
      );
      _pendingProfileName = null;
    } on FirebaseException catch (error) {
      throw AuthFailure(
        'Profile setup is still incomplete. Please retry.',
        profileSetupPending: true,
        cause: error,
      );
    } catch (error) {
      throw AuthFailure(
        'Profile setup is still incomplete. Please retry.',
        profileSetupPending: true,
        cause: error,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _dataSource.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthErrorMapper.fromFirebaseAuth(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
      _pendingProfileName = null;
    } on FirebaseAuthException catch (error) {
      throw AuthErrorMapper.fromFirebaseAuth(error);
    }
  }

  AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }
}
