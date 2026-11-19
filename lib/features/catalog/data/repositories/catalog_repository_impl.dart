import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/book.dart';
import '../../domain/models/catalog_sort.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/firestore_catalog_data_source.dart';

class CatalogFailure implements Exception {
  const CatalogFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._dataSource);

  final FirestoreCatalogDataSource _dataSource;

  @override
  Future<List<Category>> getCategories() => _execute(_dataSource.getCategories);

  @override
  Future<List<Book>> getFeaturedBooks() =>
      _execute(_dataSource.getFeaturedBooks);

  @override
  Future<List<Book>> getNewArrivals() => _execute(_dataSource.getNewArrivals);

  @override
  Future<List<Book>> searchBooks({
    required String prefix,
    String? categoryId,
    required CatalogSort sort,
  }) {
    return _execute(
      () => _dataSource.searchBooks(
        prefix: prefix,
        categoryId: categoryId,
        sort: sort,
      ),
    );
  }

  @override
  Future<Book?> getBookById(String bookId) =>
      _execute(() => _dataSource.getBookById(bookId));

  Future<T> _execute<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseException catch (error) {
      throw CatalogFailure(
        error.code == 'permission-denied'
            ? 'Catalog access is not allowed. Check your Firestore rules.'
            : 'Could not load the catalog. Check your connection and retry.',
        cause: error,
      );
    } on FormatException catch (error) {
      throw CatalogFailure(
        'Catalog data is invalid. Check the book and category documents.',
        cause: error,
      );
    } on TypeError catch (error) {
      throw CatalogFailure(
        'Catalog data has unexpected fields. Check the book and category documents.',
        cause: error,
      );
    }
  }
}
