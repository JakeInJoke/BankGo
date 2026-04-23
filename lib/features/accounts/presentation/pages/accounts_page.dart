import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/account_model.dart';
import '../../domain/entities/account.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Using placeholder data until API is connected.
    final accounts = AccountModel.placeholders();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myAccounts),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {},
            tooltip: 'Agregar cuenta',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.only(bottom: AppDimensions.spaceMD),
            child: _AccountCard(account: accounts[index]),
          );
        },
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;

  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final (gradient, icon) = _styleForType(account.type);

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: _primaryColorForType(account.type).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.alias,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                        ),
                  ),
                  Text(
                    _labelForType(account.type),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Icon(icon, color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          Text(
            CurrencyFormatter.format(account.balance),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                account.maskedNumber,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                      letterSpacing: 2,
                    ),
              ),
              if (account.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceXS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXS),
                  ),
                  child: Text(
                    'Principal',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.white,
                        ),
                  ),
                ),
            ],
          ),
        ],
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
            colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          Icons.account_balance_wallet_rounded,
        );
      case AccountType.credit:
        return (
          const LinearGradient(
            colors: [Color(0xFFDB2777), Color(0xFF9D174D)],
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
        return const Color(0xFF7C3AED);
      case AccountType.credit:
        return const Color(0xFFDB2777);
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
