class CheckoutReceipt {
  const CheckoutReceipt({
    required this.orderId,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  final String orderId;
  final double subtotal;
  final double deliveryFee;
  final double total;
}
