import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';

class TransferSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAmount;
  final bool highlight;

  const TransferSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.isAmount = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.grey500),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight:
                    highlight || isAmount ? FontWeight.bold : FontWeight.w600,
                color: highlight
                    ? AppColors.success
                    : isAmount
                        ? AppColors.primary
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
