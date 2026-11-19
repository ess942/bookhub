import '../entities/cart_line.dart';

abstract interface class CartRepository {
  Stream<List<CartLine>> watchCart(String uid);

  Future<void> addItem({
    required String uid,
    required String bookId,
    int quantity = 1,
  });

  Future<void> setQuantity({
    required String uid,
    required String bookId,
    required int quantity,
  });

  Future<void> removeItem({required String uid, required String bookId});
}
