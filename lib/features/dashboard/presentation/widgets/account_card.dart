import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/dashboard/domain/entities/account_summary.dart';

class AccountCard extends StatefulWidget {
  final AccountSummary summary;

  const AccountCard({super.key, required this.summary});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _isCardEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isCardEnabled ? 1.0 : 0.6,
          child: Container(
            height: AppDimensions.accountCardHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isCardEnabled
                    ? [AppColors.primary, AppColors.primaryDark]
                    : [AppColors.grey400, AppColors.grey600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: (_isCardEnabled ? AppColors.primary : AppColors.grey500)
                      .withValues(alpha: 0.4),
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
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Status: Card Active",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Switch(
              value: _isCardEnabled,
              onChanged: (value) {
                setState(() {
                  _isCardEnabled = value;
                });
              },
              activeColor: AppColors.primary,
              inactiveThumbColor: AppColors.error,
              inactiveTrackColor: AppColors.error.withValues(alpha: 0.2),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "BankGo Platinum",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              widget.summary.accountType,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
        const Icon(
          Icons.contactless,
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
          CurrencyFormatter.format(widget.summary.totalBalance),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
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
          widget.summary.accountNumber,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
                letterSpacing: 2,
                fontFamily: 'Courier',
              ),
        ),
        Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png',
          height: 30,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.credit_card,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}
