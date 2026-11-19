import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase_auth_data_source.dart';
import '../../data/errors/auth_error_mapper.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_account.dart';
import '../../domain/usecases/retry_user_profile.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';

final authDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});

final signInProvider = Provider<SignIn>(
  (ref) => SignIn(ref.watch(authRepositoryProvider)),
);
final registerAccountProvider = Provider<RegisterAccount>(
  (ref) => RegisterAccount(ref.watch(authRepositoryProvider)),
);
final retryUserProfileProvider = Provider<RetryUserProfile>(
  (ref) => RetryUserProfile(ref.watch(authRepositoryProvider)),
);
final sendPasswordResetProvider = Provider<SendPasswordReset>(
  (ref) => SendPasswordReset(ref.watch(authRepositoryProvider)),
);
final signOutProvider = Provider<SignOut>(
  (ref) => SignOut(ref.watch(authRepositoryProvider)),
);

class AuthState {
  const AuthState({
    this.isBusy = false,
    this.error,
    this.user,
    this.profileSetupPending = false,
    this.resetEmailSent = false,
  });

  final bool isBusy;
  final String? error;
  final AuthUser? user;
  final bool profileSetupPending;
  final bool resetEmailSent;

  AuthState copyWith({
    bool? isBusy,
    String? error,
    bool clearError = false,
    AuthUser? user,
    bool clearUser = false,
    bool? profileSetupPending,
    bool? resetEmailSent,
  }) {
    return AuthState(
      isBusy: isBusy ?? this.isBusy,
      error: clearError ? null : error ?? this.error,
      user: clearUser ? null : user ?? this.user,
      profileSetupPending: profileSetupPending ?? this.profileSetupPending,
      resetEmailSent: resetEmailSent ?? this.resetEmailSent,
    );
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  late AuthRepository _repository;
  StreamSubscription<AuthUser?>? _authSubscription;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    _authSubscription = _repository.authStateChanges().listen(
      (user) {
        state = state.copyWith(user: user, clearUser: user == null);
      },
      onError: (Object error, StackTrace stackTrace) {
        state = state.copyWith(error: _friendlyMessage(error));
      },
    );
    ref.onDispose(() => _authSubscription?.cancel());
    return const AuthState();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final user = await ref.read(signInProvider)(
        email: email,
        password: password,
      );
      state = state.copyWith(
        isBusy: false,
        user: user,
        profileSetupPending: false,
      );
    } catch (error) {
      state = state.copyWith(isBusy: false, error: _friendlyMessage(error));
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isBusy: true,
      clearError: true,
      profileSetupPending: true,
    );
    try {
      final user = await ref.read(registerAccountProvider)(
        fullName: fullName,
        email: email,
        password: password,
      );
      state = state.copyWith(
        isBusy: false,
        user: user,
        profileSetupPending: false,
      );
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        error: _friendlyMessage(error),
        profileSetupPending: error is AuthFailure && error.profileSetupPending,
      );
    }
  }

  Future<void> retryProfileSetup({required String fullName}) async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await ref.read(retryUserProfileProvider)(fullName: fullName);
      state = state.copyWith(isBusy: false, profileSetupPending: false);
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        error: _friendlyMessage(error),
        profileSetupPending: error is AuthFailure && error.profileSetupPending,
      );
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    state = state.copyWith(
      isBusy: true,
      clearError: true,
      resetEmailSent: false,
    );
    try {
      await ref.read(sendPasswordResetProvider)(email: email);
      state = state.copyWith(isBusy: false, resetEmailSent: true);
    } catch (error) {
      state = state.copyWith(isBusy: false, error: _friendlyMessage(error));
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      await ref.read(signOutProvider)();
      state = state.copyWith(
        isBusy: false,
        clearUser: true,
        profileSetupPending: false,
      );
    } catch (error) {
      state = state.copyWith(isBusy: false, error: _friendlyMessage(error));
    }
  }

  static String _friendlyMessage(Object error) {
    if (error is AuthFailure) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
