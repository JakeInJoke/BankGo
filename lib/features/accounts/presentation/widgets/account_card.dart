import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final bool isRevealed;

  const AccountCard({
    super.key,
    required this.account,
    required this.isRevealed,
  });

  @override
  Widget build(BuildContext context) {
    final (gradient, icon) = _styleForType(account.type);
    final isPrimary = account.isDefault;
    final showCardNumber = isPrimary || isRevealed;

    return InkWell(
      onTap: account.isLinkedToCard
          ? () =>
              Navigator.pushNamed(context, '/card-details', arguments: account)
          : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: [
            BoxShadow(
              color: _primaryColorForType(account.type).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingCard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.alias,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _labelForType(account.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  child: Icon(icon, color: AppColors.white),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            if (account.type == AccountType.credit)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consumido: ${CurrencyFormatter.format(account.consumption ?? 0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    'Restante: ${CurrencyFormatter.format(account.remainingCredit)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              )
            else
              Text(
                CurrencyFormatter.format(account.balance),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            const SizedBox(height: AppDimensions.spaceMD),
            Row(
              children: [
                Expanded(
                  child: Text(
                    showCardNumber
                        ? account.maskedNumber
                        : '**** **** **** ****',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          letterSpacing: 2,
                        ),
                  ),
                ),
                if (isPrimary) ...[
                  const SizedBox(width: AppDimensions.spaceSM),
                  Flexible(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spaceSM,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusSM),
                          ),
                          child: Text(
                            'PRINCIPAL',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  (LinearGradient, IconData) _styleForType(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return (
          const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          Icons.savings_rounded,
        );
      case AccountType.checking:
        return (
          const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          Icons.account_balance_wallet_rounded,
        );
      case AccountType.credit:
        return (
          const LinearGradient(
            colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          Icons.credit_card_rounded,
        );
    }
  }

  Color _primaryColorForType(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return AppColors.primary;
      case AccountType.checking:
        return const Color(0xFF6366F1);
      case AccountType.credit:
        return const Color(0xFFEC4899);
    }
  }

  String _labelForType(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return AppStrings.savingsAccount;
      case AccountType.checking:
        return AppStrings.checkingAccount;
      case AccountType.credit:
        return AppStrings.creditCard;
    }
  }
}
