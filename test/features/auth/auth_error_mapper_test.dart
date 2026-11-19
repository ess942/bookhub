import 'package:bookhub2/features/auth/data/errors/auth_error_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthErrorMapper', () {
    test('maps invalid credentials to a friendly message', () {
      final failure = AuthErrorMapper.fromFirebaseAuth(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      expect(failure.message, 'Email or password is incorrect.');
    });

    test('explains when email and password sign-in is disabled', () {
      final failure = AuthErrorMapper.fromFirebaseAuth(
        FirebaseAuthException(code: 'operation-not-allowed'),
      );

      expect(
        failure.message,
        'Email/password sign-in is not enabled for this Firebase project.',
      );
    });

    test('keeps an unknown Firebase error identifiable and readable', () {
      final failure = AuthErrorMapper.fromFirebaseAuth(
        FirebaseAuthException(code: 'custom-server-error'),
      );

      expect(
        failure.message,
        'Authentication failed (custom server error). Please try again.',
      );
    });
  });
}
