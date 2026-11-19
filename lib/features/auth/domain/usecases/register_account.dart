import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class RegisterAccount {
  const RegisterAccount(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _repository.register(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
