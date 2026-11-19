import '../models/book.dart';
import '../repositories/catalog_repository.dart';

class GetBookDetails {
  const GetBookDetails(this._repository);

  final CatalogRepository _repository;

  Future<Book?> call(String bookId) => _repository.getBookById(bookId);
}
