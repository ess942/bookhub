class LibraryBook {
  const LibraryBook({
    required this.bookId,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.orderId,
    this.purchasedAt,
  });

  final String bookId;
  final String title;
  final String author;
  final String coverUrl;
  final String orderId;
  final DateTime? purchasedAt;
}
