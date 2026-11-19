import 'package:bookhub2/features/catalog/data/datasources/firestore_catalog_data_source.dart';
import 'package:bookhub2/features/catalog/domain/models/catalog_sort.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'search applies title prefix, category, and selected price sort',
    () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('books').doc('deep-work').set({
        'title': 'Deep Work',
        'titleLower': 'deep work',
        'author': 'Cal Newport',
        'authorLower': 'cal newport',
        'description': '',
        'coverUrl': '',
        'price': 430,
        'categoryId': 'productivity',
        'rating': 4.7,
        'stock': 3,
        'isFeatured': false,
      });
      await firestore.collection('books').doc('deep-focus').set({
        'title': 'Deep Focus',
        'titleLower': 'deep focus',
        'author': 'A. Writer',
        'authorLower': 'a writer',
        'description': '',
        'coverUrl': '',
        'price': 300,
        'categoryId': 'productivity',
        'rating': 4.2,
        'stock': 2,
        'isFeatured': false,
      });
      await firestore.collection('books').doc('deep-sea').set({
        'title': 'Deep Sea',
        'titleLower': 'deep sea',
        'author': 'B. Writer',
        'authorLower': 'b writer',
        'description': '',
        'coverUrl': '',
        'price': 800,
        'categoryId': 'fiction',
        'rating': 4.9,
        'stock': 1,
        'isFeatured': false,
      });

      final source = FirestoreCatalogDataSource(firestore);
      final books = await source.searchBooks(
        prefix: 'DEEP',
        categoryId: 'productivity',
        sort: CatalogSort.priceHighToLow,
      );

      expect(books.map((book) => book.id), ['deep-work', 'deep-focus']);
    },
  );
}
