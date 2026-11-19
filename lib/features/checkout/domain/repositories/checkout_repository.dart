import '../entities/checkout_request.dart';
import '../entities/checkout_receipt.dart';

/// عقد تنفيذ الطلب: طبقة المجال لا تعرف Firestore أو Widgets.
abstract interface class CheckoutRepository {
  Future<CheckoutReceipt> placeOrder(CheckoutRequest request);
}
