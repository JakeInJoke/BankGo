import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/routes/app_router.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/dashboard_event.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.quickActions,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickActionButton(
              label: AppStrings.sendMoney,
              icon: Icons.send_rounded,
              color: AppColors.primary,
              onTap: () async {
                final result =
                    await Navigator.pushNamed(context, '/transfer-wizard');
                if (result == true && context.mounted) {
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardRefreshRequested());
                }
              },
            ),
            _QuickActionButton(
              label: "Servicios",
              icon: Icons.receipt_long_rounded,
              color: AppColors.warning,
              onTap: () async {
                final result =
                    await Navigator.pushNamed(context, '/service-payment');
                if (result == true && context.mounted) {
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardRefreshRequested());
                }
              },
            ),
            _QuickActionButton(
              label: "Historial",
              icon: Icons.history_rounded,
              color: AppColors.accent,
              onTap: () => Navigator.pushNamed(context, AppRouter.transactions),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXS),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
