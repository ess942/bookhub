import '../repositories/cart_repository.dart';

class SetCartQuantity {
  const SetCartQuantity(this._repository);

  final CartRepository _repository;

  Future<void> call({
    required String uid,
    required String bookId,
    required int quantity,
  }) {
    return _repository.setQuantity(
      uid: uid,
      bookId: bookId,
      quantity: quantity,
    );
  }
}
