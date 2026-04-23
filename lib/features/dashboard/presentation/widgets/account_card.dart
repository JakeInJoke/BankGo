import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/dashboard/domain/entities/account_summary.dart';

class AccountCard extends StatelessWidget {
  final AccountSummary summary;

  const AccountCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.accountCardHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(context),
          const Spacer(),
          _buildBalance(context),
          const SizedBox(height: AppDimensions.spaceXS),
          _buildAccountInfo(context),
        ],
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          summary.accountType,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
        ),
        const Icon(
          Icons.account_balance,
          color: AppColors.white,
          size: AppDimensions.iconMD,
        ),
      ],
    );
  }

  Widget _buildBalance(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.totalBalance,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
              ),
        ),
        const SizedBox(height: AppDimensions.spaceXXS),
        Text(
          CurrencyFormatter.format(summary.totalBalance),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildAccountInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          summary.accountNumber,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
                letterSpacing: 2,
              ),
        ),
        Row(
          children: [
            for (int i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: i < 2
                        ? AppColors.white.withValues(alpha: 0.6)
                        : AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
