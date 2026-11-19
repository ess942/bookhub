import '../repositories/cart_repository.dart';

class RemoveCartItem {
  const RemoveCartItem(this._repository);

  final CartRepository _repository;

  Future<void> call({required String uid, required String bookId}) {
    return _repository.removeItem(uid: uid, bookId: bookId);
  }
}
