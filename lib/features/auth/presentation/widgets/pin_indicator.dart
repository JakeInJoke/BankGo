import 'package:flutter/material.dart';
import 'package:bank_go/core/constants/app_colors.dart';

class PinIndicator extends StatelessWidget {
  final int length;
  final int filledCount;

  const PinIndicator({
    super.key,
    required this.length,
    required this.filledCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        bool isFilled = index < filledCount;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.primary : AppColors.grey200,
            border: Border.all(
              color: isFilled ? AppColors.primary : AppColors.grey300,
            ),
          ),
        );
      }),
    );
  }
}
