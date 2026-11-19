import '../entities/library_book.dart';

abstract interface class LibraryRepository {
  Future<List<LibraryBook>> getLibrary(String uid);
}
