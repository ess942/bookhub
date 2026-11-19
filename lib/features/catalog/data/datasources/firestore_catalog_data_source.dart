import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/book.dart';
import '../../domain/models/category.dart';
import '../../domain/models/catalog_sort.dart';

class FirestoreCatalogDataSource {
  FirestoreCatalogDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<Category>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    final categories =
        snapshot.docs
            .map(
              (document) =>
                  Category.fromJson({...document.data(), 'id': document.id}),
            )
            .where((category) => category.isActive)
            .toList()
          ..sort(
            (first, second) => first.sortOrder.compareTo(second.sortOrder),
          );
    return categories;
  }

  Future<List<Book>> getFeaturedBooks() async {
    final snapshot = await _firestore
        .collection('books')
        .where('isFeatured', isEqualTo: true)
        .limit(12)
        .get();
    final books = snapshot.docs.map(_bookFromDocument).toList()
      ..sort((first, second) {
        final ratingComparison = second.rating.compareTo(first.rating);
        if (ratingComparison != 0) return ratingComparison;
        return _compareDatesDescending(first.createdAt, second.createdAt);
      });
    return books;
  }

  Future<List<Book>> getNewArrivals() async {
    final snapshot = await _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .limit(12)
        .get();
    return snapshot.docs.map(_bookFromDocument).toList();
  }

  Future<List<Book>> searchBooks({
    required String prefix,
    String? categoryId,
    required CatalogSort sort,
  }) async {
    final normalizedPrefix = prefix.trim().toLowerCase();
    Query<Map<String, dynamic>> query = _firestore.collection('books');
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    final snapshot = await query
        .orderBy('titleLower')
        .startAt([normalizedPrefix])
        .endAt(['$normalizedPrefix\uf8ff'])
        .limit(50)
        .get();
    final books = snapshot.docs.map(_bookFromDocument).toList();

    switch (sort) {
      case CatalogSort.relevance:
        break;
      case CatalogSort.newest:
        books.sort(
          (first, second) =>
              _compareDatesDescending(first.createdAt, second.createdAt),
        );
      case CatalogSort.priceLowToHigh:
        books.sort((first, second) => first.price.compareTo(second.price));
      case CatalogSort.priceHighToLow:
        books.sort((first, second) => second.price.compareTo(first.price));
      case CatalogSort.rating:
        books.sort((first, second) => second.rating.compareTo(first.rating));
    }

    return books;
  }

  Future<Book?> getBookById(String bookId) async {
    final snapshot = await _firestore.collection('books').doc(bookId).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    return _bookFromMap(snapshot.id, snapshot.data()!);
  }

  Book _bookFromDocument(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    return _bookFromMap(document.id, document.data());
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

  int _compareDatesDescending(DateTime? first, DateTime? second) {
    if (first == null && second == null) return 0;
    if (first == null) return 1;
    if (second == null) return -1;
    return second.compareTo(first);
  }
}
