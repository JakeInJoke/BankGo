import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/recent_transaction.dart';

class TransactionTile extends StatelessWidget {
  final RecentTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(transaction.type);
    final icon = _iconForType(transaction.type);
    final amountText = CurrencyFormatter.formatSigned(transaction.amount);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
        child: Icon(icon, color: color, size: AppDimensions.iconMD),
      ),
      title: Text(
        transaction.title,
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${transaction.subtitle} • ${DateFormatter.formatRelative(transaction.date)}',
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        amountText,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: transaction.isIncome ? AppColors.income : AppColors.expense,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Color _colorForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
    }
  }

  IconData _iconForType(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.expense:
        return Icons.arrow_upward_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
    }
  }
}
