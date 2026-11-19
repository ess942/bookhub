import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.currency = 'EGP',
    this.color = AppColors.actionBlue,
    this.fontSize = 14,
  });

  final double price;
  final String currency;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$currency ${price.toStringAsFixed(2)}',
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
