import 'package:bookhub2/features/checkout/data/repositories/firestore_checkout_repository.dart';
import 'package:bookhub2/features/checkout/domain/entities/checkout_line_expectation.dart';
import 'package:bookhub2/features/checkout/domain/entities/checkout_request.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const uid = 'customer-1';
  const bookId = 'book-1';

  Future<FakeFirebaseFirestore> createFirestore({double price = 20}) async {
    final firestore = FakeFirebaseFirestore();
    await firestore.collection('books').doc(bookId).set({
      'title': 'A Test Book',
      'author': 'A. Writer',
      'coverUrl': 'cover.jpg',
      'price': price,
      'stock': 5,
    });
    await firestore
        .collection('users')
        .doc(uid)
        .collection('cartItems')
        .doc(bookId)
        .set({'bookId': bookId, 'quantity': 2});
    return firestore;
  }

  CheckoutRequest createRequest({double expectedPrice = 20}) => CheckoutRequest(
    uid: uid,
    address: '1 Main Street',
    phone: '123456789',
    items: [
      CheckoutLineExpectation(
        bookId: bookId,
        quantity: 2,
        price: expectedPrice,
        stock: 5,
      ),
    ],
  );

  test('commits order, library, stock, and cart changes atomically', () async {
    final firestore = await createFirestore();
    final repository = FirestoreCheckoutRepository(firestore);

    final receipt = await repository.placeOrder(createRequest());

    expect(receipt.subtotal, 40);
    expect(receipt.total, 75);
    expect(
      (await firestore.collection('books').doc(bookId).get()).data()?['stock'],
      3,
    );
    expect(
      (await firestore
              .collection('users')
              .doc(uid)
              .collection('cartItems')
              .get())
          .docs,
      isEmpty,
    );
    expect(
      (await firestore
              .collection('users')
              .doc(uid)
              .collection('library')
              .doc(bookId)
              .get())
          .data()?['orderId'],
      receipt.orderId,
    );
    final order = await firestore
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(receipt.orderId)
        .get();
    expect(order.data()?['total'], 75);
    expect(order.data()?['paymentMethod'], 'cash_on_delivery_demo');
  });

  test(
    'requires cart review without writes when stock is no longer enough',
    () async {
      final firestore = await createFirestore();
      await firestore.collection('books').doc(bookId).update({'stock': 1});
      final repository = FirestoreCheckoutRepository(firestore);

      await expectLater(
        repository.placeOrder(createRequest()),
        throwsA(
          isA<CheckoutReviewRequired>().having(
            (error) => error.changes.any(
              (change) => change.type == CheckoutChangeType.stock,
            ),
            'contains stock change',
            isTrue,
          ),
        ),
      );

      expect(
        (await firestore.collection('books').doc(bookId).get())
            .data()?['stock'],
        1,
      );
      expect(
        (await firestore
                .collection('users')
                .doc(uid)
                .collection('orders')
                .get())
            .docs,
        isEmpty,
      );
      expect(
        (await firestore
                .collection('users')
                .doc(uid)
                .collection('cartItems')
                .doc(bookId)
                .get())
            .exists,
        isTrue,
      );
    },
  );

  test(
    'requires cart review without writes when the current price changed',
    () async {
      final firestore = await createFirestore(price: 24);
      final repository = FirestoreCheckoutRepository(firestore);

      await expectLater(
        repository.placeOrder(createRequest()),
        throwsA(
          isA<CheckoutReviewRequired>().having(
            (error) => error.changes.any(
              (change) => change.type == CheckoutChangeType.price,
            ),
            'contains price change',
            isTrue,
          ),
        ),
      );

      expect(
        (await firestore.collection('books').doc(bookId).get())
            .data()?['stock'],
        5,
      );
      expect(
        (await firestore
                .collection('users')
                .doc(uid)
                .collection('orders')
                .get())
            .docs,
        isEmpty,
      );
      expect(
        (await firestore
                .collection('users')
                .doc(uid)
                .collection('cartItems')
                .doc(bookId)
                .get())
            .exists,
        isTrue,
      );
    },
  );
}
