import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';

class TransferStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const TransferStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
        vertical: AppDimensions.spaceMD,
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= currentStep
                    ? AppColors.primary
                    : AppColors.grey200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}
