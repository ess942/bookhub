import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/firestore_library_repository.dart';
import '../../domain/entities/library_book.dart';
import '../../domain/repositories/library_repository.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => FirestoreLibraryRepository(FirebaseFirestore.instance),
);

final myLibraryProvider = FutureProvider.family<List<LibraryBook>, String>(
  (ref, uid) => ref.watch(libraryRepositoryProvider).getLibrary(uid),
);
