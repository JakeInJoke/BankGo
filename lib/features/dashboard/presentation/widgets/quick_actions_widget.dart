import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/routes/app_router.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  static const List<_QuickAction> _actions = [
    _QuickAction(
      label: AppStrings.sendMoney,
      icon: Icons.send_rounded,
      color: AppColors.primary,
      route: AppRouter.transactions,
    ),
    _QuickAction(
      label: AppStrings.payBills,
      icon: Icons.receipt_long_rounded,
      color: AppColors.warning,
      route: AppRouter.payment,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.quickActions,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _actions
              .map((action) => _QuickActionButton(action: action))
              .toList(),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, action.route),
      child: Column(
        children: [
          Container(
            width: AppDimensions.quickActionSize,
            height: AppDimensions.quickActionSize,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: AppDimensions.iconLG,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXS),
          Text(
            action.label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}
