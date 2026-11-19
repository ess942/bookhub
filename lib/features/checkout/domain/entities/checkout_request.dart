import 'checkout_line_expectation.dart';

class CheckoutRequest {
  const CheckoutRequest({
    required this.uid,
    required this.address,
    required this.phone,
    required this.items,
  });

  final String uid;
  final String address;
  final String phone;
  final List<CheckoutLineExpectation> items;
}
