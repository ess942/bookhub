import '../repositories/auth_repository.dart';

class RetryUserProfile {
  const RetryUserProfile(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String fullName}) {
    return _repository.retryUserProfile(fullName: fullName);
  }
}
