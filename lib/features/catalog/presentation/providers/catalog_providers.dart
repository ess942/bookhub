import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firestore_catalog_data_source.dart';
import '../../data/repositories/catalog_repository_impl.dart';
import '../../domain/models/book.dart';
import '../../domain/models/catalog_sort.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../domain/usecases/get_book_details.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_featured_books.dart';
import '../../domain/usecases/get_new_arrivals.dart';
import '../../domain/usecases/search_books.dart';

final firestoreCatalogDataSourceProvider = Provider<FirestoreCatalogDataSource>(
  (ref) => FirestoreCatalogDataSource(FirebaseFirestore.instance),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepositoryImpl(ref.watch(firestoreCatalogDataSourceProvider)),
);

final getCategoriesProvider = Provider<GetCategories>(
  (ref) => GetCategories(ref.watch(catalogRepositoryProvider)),
);
final getFeaturedBooksProvider = Provider<GetFeaturedBooks>(
  (ref) => GetFeaturedBooks(ref.watch(catalogRepositoryProvider)),
);
final getNewArrivalsProvider = Provider<GetNewArrivals>(
  (ref) => GetNewArrivals(ref.watch(catalogRepositoryProvider)),
);
final searchBooksUseCaseProvider = Provider<SearchBooks>(
  (ref) => SearchBooks(ref.watch(catalogRepositoryProvider)),
);
final getBookDetailsProvider = Provider<GetBookDetails>(
  (ref) => GetBookDetails(ref.watch(catalogRepositoryProvider)),
);

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(getCategoriesProvider)(),
);

final featuredBooksProvider = FutureProvider<List<Book>>(
  (ref) => ref.watch(getFeaturedBooksProvider)(),
);

final newArrivalsProvider = FutureProvider<List<Book>>(
  (ref) => ref.watch(getNewArrivalsProvider)(),
);

typedef CatalogSearchRequest = ({
  String prefix,
  String? categoryId,
  CatalogSort sort,
});

final searchBooksProvider =
    FutureProvider.family<List<Book>, CatalogSearchRequest>(
      (ref, request) => ref.watch(searchBooksUseCaseProvider)(
        prefix: request.prefix,
        categoryId: request.categoryId,
        sort: request.sort,
      ),
    );

final bookDetailsProvider = FutureProvider.family<Book?, String>(
  (ref, bookId) => ref.watch(getBookDetailsProvider)(bookId),
);
