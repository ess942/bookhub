import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../catalog/domain/models/book.dart';
import '../../domain/entities/cart_line.dart';

class FirestoreCartDataSource {
  FirestoreCartDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<CartLine>> watchCart(String uid) {
    if (uid.isEmpty) throw const CartException('Sign in to view your cart.');

    final controller = StreamController<List<CartLine>>();
    final quantities = <String, int>{};
    final books = <String, Book?>{};
    final bookSubscriptions =
        <String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? cartSubscription;

    void emitLines() {
      if (controller.isClosed) return;
      controller.add([
        for (final entry in quantities.entries)
          CartLine(
            bookId: entry.key,
            quantity: entry.value,
            book: books[entry.key],
          ),
      ]);
    }

    cartSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('cartItems')
        .snapshots()
        .listen((snapshot) {
          final nextQuantities = <String, int>{};
          for (final document in snapshot.docs) {
            final quantity = document.data()['quantity'];
            if (quantity is! num ||
                quantity.toInt() < 1 ||
                quantity.toInt() != quantity) {
              controller.addError(
                const CartException('The cart contains an invalid quantity.'),
              );
              return;
            }
            nextQuantities[document.id] = quantity.toInt();
          }

          quantities
            ..clear()
            ..addAll(nextQuantities);

          for (final bookId in bookSubscriptions.keys.toList()) {
            if (!quantities.containsKey(bookId)) {
              bookSubscriptions.remove(bookId)?.cancel();
              books.remove(bookId);
            }
          }

          for (final bookId in quantities.keys) {
            if (bookSubscriptions.containsKey(bookId)) continue;
            bookSubscriptions[bookId] = _firestore
                .collection('books')
                .doc(bookId)
                .snapshots()
                .listen((snapshot) {
                  books[bookId] = snapshot.exists && snapshot.data() != null
                      ? _bookFromMap(bookId, snapshot.data()!)
                      : null;
                  emitLines();
                }, onError: controller.addError);
          }
          emitLines();
        }, onError: controller.addError);

    controller.onCancel = () async {
      await cartSubscription?.cancel();
      for (final subscription in bookSubscriptions.values) {
        await subscription.cancel();
      }
      bookSubscriptions.clear();
    };

    return controller.stream;
  }

  Future<void> addItem({
    required String uid,
    required String bookId,
    required int quantity,
  }) async {
    _validateIdentity(uid, bookId);
    if (quantity < 1) throw const CartException('Quantity must be at least 1.');

    final cartReference = _firestore
        .collection('users')
        .doc(uid)
        .collection('cartItems')
        .doc(bookId);
    final bookReference = _firestore.collection('books').doc(bookId);
    await _firestore.runTransaction((transaction) async {
      final bookSnapshot = await transaction.get(bookReference);
      final cartSnapshot = await transaction.get(cartReference);
      final bookData = bookSnapshot.data();
      if (!bookSnapshot.exists || bookData == null) {
        throw const CartException('This book is no longer available.');
      }
      final rawStock = bookData['stock'];
      final rawQuantity = cartSnapshot.exists
          ? (cartSnapshot.data()?['quantity'])
          : 0;
      if (rawStock is! num ||
          rawStock.toInt() != rawStock ||
          rawStock < 0 ||
          rawQuantity is! num ||
          rawQuantity.toInt() != rawQuantity ||
          (cartSnapshot.exists ? rawQuantity < 1 : rawQuantity != 0)) {
        throw const CartException('The book or cart has invalid stock data.');
      }
      final stock = rawStock.toInt();
      final currentQuantity = rawQuantity.toInt();
      final nextQuantity = currentQuantity + quantity;
      if (stock < nextQuantity) {
        throw const CartException(
          'There is not enough stock to add this quantity.',
        );
      }

      transaction.set(cartReference, {
        'bookId': bookId,
        'quantity': nextQuantity,
        'addedAt':
            cartSnapshot.data()?['addedAt'] ?? FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> setQuantity({
    required String uid,
    required String bookId,
    required int quantity,
  }) async {
    _validateIdentity(uid, bookId);
    if (quantity < 1) throw const CartException('Quantity must be at least 1.');

    final cartReference = _firestore
        .collection('users')
        .doc(uid)
        .collection('cartItems')
        .doc(bookId);
    final bookReference = _firestore.collection('books').doc(bookId);
    await _firestore.runTransaction((transaction) async {
      final cartSnapshot = await transaction.get(cartReference);
      final bookSnapshot = await transaction.get(bookReference);
      if (!cartSnapshot.exists) {
        throw const CartException('This item is no longer in your cart.');
      }
      final rawStock = bookSnapshot.data()?['stock'];
      if (rawStock is! num || rawStock.toInt() != rawStock || rawStock < 0) {
        throw const CartException('This book has invalid stock data.');
      }
      final stock = rawStock.toInt();
      if (!bookSnapshot.exists || stock < quantity) {
        throw const CartException('The requested quantity is not in stock.');
      }
      transaction.update(cartReference, {'quantity': quantity});
    });
  }

  Future<void> removeItem({required String uid, required String bookId}) async {
    _validateIdentity(uid, bookId);
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('cartItems')
        .doc(bookId)
        .delete();
  }

  Book _bookFromMap(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    return Book.fromJson({
      ...data,
      'id': id,
      if (createdAt is Timestamp)
        'createdAt': createdAt.toDate().toIso8601String(),
    });
  }

  void _validateIdentity(String uid, String bookId) {
    if (uid.isEmpty || bookId.isEmpty) {
      throw const CartException('Sign in before updating your cart.');
    }
  }
}
