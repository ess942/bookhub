import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_checkout_repository.dart';
import '../../domain/entities/checkout_line_expectation.dart';
import '../../domain/entities/checkout_receipt.dart';
import '../../domain/entities/checkout_request.dart';
import '../../domain/entities/checkout_pricing.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/usecases/place_order.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (ref) => FirestoreCheckoutRepository(FirebaseFirestore.instance),
);

final placeOrderProvider = Provider<PlaceOrder>(
  (ref) => PlaceOrder(ref.watch(checkoutRepositoryProvider)),
);

class CheckoutState {
  const CheckoutState({
    this.isSubmitting = false,
    this.receipt,
    this.reviewRequired,
    this.error,
  });

  final bool isSubmitting;
  final CheckoutReceipt? receipt;
  final CheckoutReviewRequired? reviewRequired;
  final String? error;

  CheckoutState copyWith({
    bool? isSubmitting,
    CheckoutReceipt? receipt,
    CheckoutReviewRequired? reviewRequired,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return CheckoutState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      receipt: clearResult ? null : receipt ?? this.receipt,
      reviewRequired: clearResult
          ? null
          : reviewRequired ?? this.reviewRequired,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutState>(CheckoutController.new);

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  Future<void> placeOrder(CheckoutRequest request) async {
    state = const CheckoutState(isSubmitting: true);
    try {
      final receipt = await ref.read(placeOrderProvider)(request);
      state = CheckoutState(receipt: receipt);
    } on CheckoutReviewRequired catch (error) {
      state = CheckoutState(reviewRequired: error);
    } on CheckoutFailure catch (error) {
      state = CheckoutState(error: error.message);
    } on FirebaseException catch (error) {
      state = CheckoutState(
        error: error.code == 'permission-denied'
            ? 'The order was not allowed by Firestore security rules.'
            : 'Could not place the order. Check your connection and retry.',
      );
    } catch (error) {
      state = CheckoutState(error: 'Checkout failed: $error');
    }
  }

  void clearResult() => state = const CheckoutState();
}

List<CheckoutLineExpectation> checkoutExpectationsFromLines(
  Iterable<({String bookId, int quantity, double price, int stock})> lines,
) {
  return [
    for (final line in lines)
      CheckoutLineExpectation(
        bookId: line.bookId,
        quantity: line.quantity,
        price: line.price,
        stock: line.stock,
      ),
  ];
}

double calculateCheckoutTotal(double subtotal) =>
    subtotal + CheckoutPricing.deliveryFee;
