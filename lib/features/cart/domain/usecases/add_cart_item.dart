import '../repositories/cart_repository.dart';

class AddCartItem {
  const AddCartItem(this._repository);

  final CartRepository _repository;

  Future<void> call({
    required String uid,
    required String bookId,
    int quantity = 1,
  }) {
    return _repository.addItem(uid: uid, bookId: bookId, quantity: quantity);
  }
}
