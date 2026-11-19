import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/cart_line.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/firestore_cart_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._dataSource);

  final FirestoreCartDataSource _dataSource;

  @override
  Stream<List<CartLine>> watchCart(String uid) => _dataSource.watchCart(uid);

  @override
  Future<void> addItem({
    required String uid,
    required String bookId,
    int quantity = 1,
  }) {
    return _mapFirestoreErrors(
      () => _dataSource.addItem(uid: uid, bookId: bookId, quantity: quantity),
    );
  }

  @override
  Future<void> setQuantity({
    required String uid,
    required String bookId,
    required int quantity,
  }) {
    return _mapFirestoreErrors(
      () =>
          _dataSource.setQuantity(uid: uid, bookId: bookId, quantity: quantity),
    );
  }

  @override
  Future<void> removeItem({required String uid, required String bookId}) {
    return _mapFirestoreErrors(
      () => _dataSource.removeItem(uid: uid, bookId: bookId),
    );
  }

  Future<void> _mapFirestoreErrors(Future<void> Function() operation) async {
    try {
      await operation();
    } on FirebaseException catch (error) {
      throw CartException(
        error.code == 'permission-denied'
            ? 'You do not have permission to change this cart.'
            : 'Could not update your cart. Check your connection and retry.',
      );
    }
  }
}
