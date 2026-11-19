import '../models/book.dart';
import '../repositories/catalog_repository.dart';

class GetFeaturedBooks {
  const GetFeaturedBooks(this._repository);

  final CatalogRepository _repository;

  Future<List<Book>> call() => _repository.getFeaturedBooks();
}
