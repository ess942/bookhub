import '../models/book.dart';
import '../models/catalog_sort.dart';
import '../repositories/catalog_repository.dart';

class SearchBooks {
  const SearchBooks(this._repository);

  final CatalogRepository _repository;

  Future<List<Book>> call({
    required String prefix,
    String? categoryId,
    required CatalogSort sort,
  }) {
    return _repository.searchBooks(
      prefix: prefix,
      categoryId: categoryId,
      sort: sort,
    );
  }
}
