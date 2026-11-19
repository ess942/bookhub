import 'package:firebase_auth/firebase_auth.dart';

class AuthFailure implements Exception {
  const AuthFailure(
    this.message, {
    this.profileSetupPending = false,
    this.cause,
  });

  final String message;
  final bool profileSetupPending;
  final Object? cause;

  @override
  String toString() => message;
}

abstract final class AuthErrorMapper {
  static AuthFailure fromFirebaseAuth(FirebaseAuthException error) {
    final message = switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled. Contact support.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Email or password is incorrect.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Choose a stronger password (at least 6 characters).',
      'operation-not-allowed' =>
        'Email/password sign-in is not enabled for this Firebase project.',
      'too-many-requests' => 'Too many attempts. Wait a little and try again.',
      'network-request-failed' =>
        'Network error. Check your connection and try again.',
      'requires-recent-login' =>
        'For your security, sign in again before doing this.',
      'invalid-verification-code' =>
        'The verification code is invalid. Check it and try again.',
      'invalid-verification-id' =>
        'The verification session expired. Request a new code.',
      'session-expired' => 'The verification session expired. Try again.',
      'quota-exceeded' =>
        'The service is temporarily busy. Please try again later.',
      'captcha-check-failed' =>
        'The security check failed. Refresh the page and try again.',
      'missing-phone-number' => 'Enter a phone number.',
      'invalid-phone-number' => 'Enter a valid phone number.',
      'invalid-action-code' => 'This link is invalid or has already been used.',
      'expired-action-code' => 'This link has expired. Request a new one.',
      'provider-already-linked' =>
        'This sign-in method is already linked to your account.',
      'no-such-provider' =>
        'This sign-in method is not linked to your account.',
      'second-factor-required' =>
        'Additional verification is required to sign in.',
      'web-storage-unsupported' =>
        'This browser does not support the required sign-in storage.',
      'unauthorized-domain' =>
        'This domain is not authorized for Firebase Authentication.',
      'popup-closed-by-user' =>
        'The sign-in window was closed before completion.',
      'cancelled-popup-request' => 'The sign-in request was cancelled.',
      'account-exists-with-different-credential' =>
        'An account already exists with a different sign-in method.',
      'credential-already-in-use' =>
        'This sign-in credential is already linked to another account.',
      'user-token-expired' ||
      'invalid-user-token' => 'Your session expired. Sign in again.',
      'app-not-authorized' =>
        'This app is not authorized for the Firebase project.',
      'api-key-not-valid' =>
        'Firebase is not configured correctly for this app.',
      'missing-email' => 'Enter your email address.',
      'missing-password' => 'Enter your password.',
      _ =>
        'Authentication failed (${error.code.replaceAll('-', ' ')}). '
            'Please try again.',
    };
    return AuthFailure(message, cause: error);
  }
}
