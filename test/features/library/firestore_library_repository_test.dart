import 'package:bookhub2/features/library/data/repositories/firestore_library_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads the signed-in user library newest purchase first', () async {
    final firestore = FakeFirebaseFirestore();
    final library = firestore
        .collection('users')
        .doc('customer-1')
        .collection('library');
    await library.doc('older-book').set({
      'titleSnapshot': 'Older Book',
      'authorSnapshot': 'A. Writer',
      'coverUrlSnapshot': 'older.jpg',
      'orderId': 'order-old',
      'purchasedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
    });
    await library.doc('newer-book').set({
      'titleSnapshot': 'Newer Book',
      'authorSnapshot': 'B. Writer',
      'coverUrlSnapshot': 'newer.jpg',
      'orderId': 'order-new',
      'purchasedAt': Timestamp.fromDate(DateTime(2026, 2, 1)),
    });

    final books = await FirestoreLibraryRepository(
      firestore,
    ).getLibrary('customer-1');

    expect(books.map((book) => book.bookId), ['newer-book', 'older-book']);
    expect(books.first.title, 'Newer Book');
    expect(books.first.purchasedAt, DateTime(2026, 2, 1));
  });
}
