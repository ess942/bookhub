import '../entities/cart_line.dart';
import '../repositories/cart_repository.dart';

class WatchCart {
  const WatchCart(this._repository);

  final CartRepository _repository;

  Stream<List<CartLine>> call(String uid) => _repository.watchCart(uid);
}
