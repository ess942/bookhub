import '../models/category.dart';
import '../repositories/catalog_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final CatalogRepository _repository;

  Future<List<Category>> call() => _repository.getCategories();
}
