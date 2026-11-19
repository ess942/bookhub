import '../models/book.dart';
import '../repositories/catalog_repository.dart';

class GetNewArrivals {
  const GetNewArrivals(this._repository);

  final CatalogRepository _repository;

  Future<List<Book>> call() => _repository.getNewArrivals();
}
