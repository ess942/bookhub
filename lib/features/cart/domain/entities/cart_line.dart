import '../../../catalog/domain/models/book.dart';

class CartLine {
  const CartLine({
    required this.bookId,
    required this.quantity,
    required this.book,
  });

  final String bookId;
  final int quantity;
  final Book? book;

  double get total => (book?.price ?? 0) * quantity;

  bool get isAvailable => book != null && book!.stock >= quantity;
}

class CartException implements Exception {
  const CartException(this.message);

  final String message;

  @override
  String toString() => message;
}
