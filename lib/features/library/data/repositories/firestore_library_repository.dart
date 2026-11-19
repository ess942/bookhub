import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/library_book.dart';
import '../../domain/repositories/library_repository.dart';

class FirestoreLibraryRepository implements LibraryRepository {
  FirestoreLibraryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<LibraryBook>> getLibrary(String uid) async {
    if (uid.isEmpty) {
      throw const LibraryFailure('Sign in to view your library.');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('library')
        .orderBy('purchasedAt', descending: true)
        .get();

    return [
      for (final document in snapshot.docs)
        LibraryBook(
          bookId: document.id,
          title: document.data()['titleSnapshot'] as String? ?? 'Untitled',
          author: document.data()['authorSnapshot'] as String? ?? '',
          coverUrl: document.data()['coverUrlSnapshot'] as String? ?? '',
          orderId: document.data()['orderId'] as String? ?? '',
          purchasedAt: (document.data()['purchasedAt'] as Timestamp?)?.toDate(),
        ),
    ];
  }
}

class LibraryFailure implements Exception {
  const LibraryFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
