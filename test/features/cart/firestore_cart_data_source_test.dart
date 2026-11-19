import 'package:bookhub2/features/cart/data/datasources/firestore_cart_data_source.dart';
import 'package:bookhub2/features/cart/domain/entities/cart_line.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const uid = 'customer-1';
  const bookId = 'book-1';

  test('adds, updates, and removes a cart item using current stock', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('books').doc(bookId).set({'stock': 3});
    final source = FirestoreCartDataSource(firestore);

    await source.addItem(uid: uid, bookId: bookId, quantity: 1);
    await source.addItem(uid: uid, bookId: bookId, quantity: 1);
    var cartItem = await firestore
        .collection('users')
        .doc(uid)
        .collection('cartItems')
        .doc(bookId)
        .get();
    expect(cartItem.data()?['quantity'], 2);

    await source.setQuantity(uid: uid, bookId: bookId, quantity: 3);
    cartItem = await firestore
        .collection('users')
        .doc(uid)
        .collection('cartItems')
        .doc(bookId)
        .get();
    expect(cartItem.data()?['quantity'], 3);

    await source.removeItem(uid: uid, bookId: bookId);
    cartItem = await firestore
        .collection('users')
        .doc(uid)
        .collection('cartItems')
        .doc(bookId)
        .get();
    expect(cartItem.exists, isFalse);
  });

  test('rejects adding more than available stock', () async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('books').doc(bookId).set({'stock': 1});
    final source = FirestoreCartDataSource(firestore);

    await source.addItem(uid: uid, bookId: bookId, quantity: 1);
    await expectLater(
      source.addItem(uid: uid, bookId: bookId, quantity: 1),
      throwsA(isA<CartException>()),
    );

    final cartItem = await firestore
        .collection('users')
        .doc(uid)
        .collection('cartItems')
        .doc(bookId)
        .get();
    expect(cartItem.data()?['quantity'], 1);
  });
}
