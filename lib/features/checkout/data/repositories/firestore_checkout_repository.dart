import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/checkout_line_expectation.dart';
import '../../domain/entities/checkout_pricing.dart';
import '../../domain/entities/checkout_receipt.dart';
import '../../domain/entities/checkout_request.dart';
import '../../domain/repositories/checkout_repository.dart';

class FirestoreCheckoutRepository implements CheckoutRepository {
  FirestoreCheckoutRepository(this._firestore);

  static const int _maxOrderItems = 150;
  final FirebaseFirestore _firestore;

  @override
  Future<CheckoutReceipt> placeOrder(CheckoutRequest request) async {
    if (request.uid.isEmpty) {
      throw const CheckoutFailure('Sign in before placing your order.');
    }
    if (request.address.trim().isEmpty || request.phone.trim().isEmpty) {
      throw const CheckoutFailure('Enter a delivery address and phone number.');
    }

    final userReference = _firestore.collection('users').doc(request.uid);
    final cartReference = userReference.collection('cartItems');
    final queriedCart = await cartReference.limit(_maxOrderItems + 1).get();
    if (queriedCart.docs.isEmpty) {
      throw const CheckoutFailure('Your cart is empty.');
    }
    if (queriedCart.docs.length > _maxOrderItems) {
      throw const CheckoutFailure(
        'The cart has too many items to check out at once.',
      );
    }

    final orderReference = userReference.collection('orders').doc();
    final expectedById = {for (final item in request.items) item.bookId: item};

    return _firestore.runTransaction((transaction) async {
      final changes = <CheckoutChange>[];
      final cartLines =
          <
            ({
              String bookId,
              DocumentReference<Map<String, dynamic>> cartReference,
              int quantity,
            })
          >[];

      for (final queriedCartDocument in queriedCart.docs) {
        final currentCart = await transaction.get(
          queriedCartDocument.reference,
        );
        final cartData = currentCart.data();
        final rawQuantity = cartData?['quantity'];
        if (!currentCart.exists ||
            rawQuantity is! num ||
            rawQuantity.toInt() < 1 ||
            rawQuantity.toInt() != rawQuantity) {
          changes.add(
            CheckoutChange(
              bookId: queriedCartDocument.id,
              title: queriedCartDocument.id,
              type: CheckoutChangeType.cartContents,
            ),
          );
          continue;
        }

        final quantity = rawQuantity.toInt();
        final expectation = expectedById[queriedCartDocument.id];
        if (expectation == null || expectation.quantity != quantity) {
          changes.add(
            CheckoutChange(
              bookId: queriedCartDocument.id,
              title: queriedCartDocument.id,
              type: CheckoutChangeType.quantity,
              requestedQuantity: quantity,
            ),
          );
        }
        cartLines.add((
          bookId: queriedCartDocument.id,
          cartReference: queriedCartDocument.reference,
          quantity: quantity,
        ));
      }

      final currentCartIds = cartLines.map((line) => line.bookId).toSet();
      for (final expected in request.items) {
        if (!currentCartIds.contains(expected.bookId)) {
          changes.add(
            CheckoutChange(
              bookId: expected.bookId,
              title: expected.bookId,
              type: CheckoutChangeType.cartContents,
              requestedQuantity: expected.quantity,
            ),
          );
        }
      }

      final bookLines =
          <
            ({
              String bookId,
              DocumentReference<Map<String, dynamic>> cartReference,
              DocumentSnapshot<Map<String, dynamic>> bookSnapshot,
              int quantity,
            })
          >[];

      for (final line in cartLines) {
        final bookReference = _firestore.collection('books').doc(line.bookId);
        final bookSnapshot = await transaction.get(bookReference);
        bookLines.add((
          bookId: line.bookId,
          cartReference: line.cartReference,
          bookSnapshot: bookSnapshot,
          quantity: line.quantity,
        ));
      }

      final orderItems = <Map<String, dynamic>>[];
      var subtotal = 0.0;

      for (final line in bookLines) {
        final bookData = line.bookSnapshot.data();
        final expectation = expectedById[line.bookId];
        if (!line.bookSnapshot.exists || bookData == null) {
          changes.add(
            CheckoutChange(
              bookId: line.bookId,
              title: line.bookId,
              type: CheckoutChangeType.unavailable,
              requestedQuantity: line.quantity,
              availableStock: 0,
            ),
          );
          continue;
        }

        final rawPrice = bookData['price'];
        final rawStock = bookData['stock'];
        if (rawPrice is! num || rawStock is! num) {
          throw const CheckoutFailure(
            'A book has invalid price or stock data. Contact the store.',
          );
        }
        final price = rawPrice.toDouble();
        if (!price.isFinite ||
            price < 0 ||
            rawStock.toInt() != rawStock ||
            rawStock < 0) {
          throw const CheckoutFailure(
            'A book has invalid price or stock data. Contact the store.',
          );
        }
        final stock = rawStock.toInt();
        final title = bookData['title'] as String? ?? line.bookId;

        if (expectation == null || expectation.price != price) {
          changes.add(
            CheckoutChange(
              bookId: line.bookId,
              title: title,
              type: CheckoutChangeType.price,
              previousPrice: expectation?.price,
              currentPrice: price,
              requestedQuantity: line.quantity,
              availableStock: stock,
            ),
          );
        }
        if (expectation == null ||
            expectation.stock != stock ||
            stock < line.quantity) {
          changes.add(
            CheckoutChange(
              bookId: line.bookId,
              title: title,
              type: CheckoutChangeType.stock,
              previousPrice: expectation?.price,
              currentPrice: price,
              requestedQuantity: line.quantity,
              availableStock: stock,
            ),
          );
        }

        subtotal += price * line.quantity;
        orderItems.add({
          'bookId': line.bookId,
          'titleSnapshot': title,
          'coverUrlSnapshot': bookData['coverUrl'] as String? ?? '',
          'unitPrice': price,
          'quantity': line.quantity,
        });
      }

      if (changes.isNotEmpty) throw CheckoutReviewRequired(changes);
      if (orderItems.isEmpty) {
        throw const CheckoutFailure('Your cart has no available books.');
      }

      final deliveryFee = CheckoutPricing.deliveryFee;
      final total = subtotal + deliveryFee;

      // No writes occur before every cart and book document has been read and validated.
      transaction.set(orderReference, {
        'items': orderItems,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'address': request.address.trim(),
        'phone': request.phone.trim(),
        'paymentMethod': 'cash_on_delivery_demo',
        'status': 'placed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      for (final line in bookLines) {
        final bookData = line.bookSnapshot.data()!;
        final currentStock = (bookData['stock'] as num).toInt();
        final bookReference = _firestore.collection('books').doc(line.bookId);
        transaction.update(bookReference, {
          'stock': currentStock - line.quantity,
        });
        transaction.set(userReference.collection('library').doc(line.bookId), {
          'bookId': line.bookId,
          'titleSnapshot': bookData['title'] as String? ?? line.bookId,
          'coverUrlSnapshot': bookData['coverUrl'] as String? ?? '',
          'authorSnapshot': bookData['author'] as String? ?? '',
          'orderId': orderReference.id,
          'purchasedAt': FieldValue.serverTimestamp(),
        });
        transaction.delete(line.cartReference);
      }

      return CheckoutReceipt(
        orderId: orderReference.id,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
      );
    });
  }
}
