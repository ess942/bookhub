import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firestore_cart_data_source.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_cart_item.dart';
import '../../domain/usecases/remove_cart_item.dart';
import '../../domain/usecases/set_cart_quantity.dart';
import '../../domain/usecases/watch_cart.dart';

final firestoreCartDataSourceProvider = Provider<FirestoreCartDataSource>(
  (ref) => FirestoreCartDataSource(FirebaseFirestore.instance),
);

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepositoryImpl(ref.watch(firestoreCartDataSourceProvider)),
);

final watchCartProvider = Provider<WatchCart>(
  (ref) => WatchCart(ref.watch(cartRepositoryProvider)),
);
final addCartItemProvider = Provider<AddCartItem>(
  (ref) => AddCartItem(ref.watch(cartRepositoryProvider)),
);
final setCartQuantityProvider = Provider<SetCartQuantity>(
  (ref) => SetCartQuantity(ref.watch(cartRepositoryProvider)),
);
final removeCartItemProvider = Provider<RemoveCartItem>(
  (ref) => RemoveCartItem(ref.watch(cartRepositoryProvider)),
);

final cartItemsProvider = StreamProvider.family<List<CartLine>, String>(
  (ref, uid) => ref.watch(watchCartProvider)(uid),
);
