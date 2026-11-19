class CheckoutLineExpectation {
  const CheckoutLineExpectation({
    required this.bookId,
    required this.quantity,
    required this.price,
    required this.stock,
  });

  final String bookId;
  final int quantity;
  final double price;
  final int stock;
}

enum CheckoutChangeType { price, stock, quantity, unavailable, cartContents }

class CheckoutChange {
  const CheckoutChange({
    required this.bookId,
    required this.title,
    required this.type,
    this.previousPrice,
    this.currentPrice,
    this.requestedQuantity,
    this.availableStock,
  });

  final String bookId;
  final String title;
  final CheckoutChangeType type;
  final double? previousPrice;
  final double? currentPrice;
  final int? requestedQuantity;
  final int? availableStock;
}

class CheckoutReviewRequired implements Exception {
  const CheckoutReviewRequired(this.changes);

  final List<CheckoutChange> changes;

  @override
  String toString() =>
      'Prices, stock, or cart quantities changed. Review the cart and try again.';
}

class CheckoutFailure implements Exception {
  const CheckoutFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
