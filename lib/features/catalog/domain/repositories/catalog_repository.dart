import '../models/book.dart';
import '../models/catalog_sort.dart';
import '../models/category.dart';

abstract interface class CatalogRepository {
  Future<List<Category>> getCategories();

  Future<List<Book>> getFeaturedBooks();

  Future<List<Book>> getNewArrivals();

  Future<List<Book>> searchBooks({
    required String prefix,
    String? categoryId,
    required CatalogSort sort,
  });

  Future<Book?> getBookById(String bookId);
}
