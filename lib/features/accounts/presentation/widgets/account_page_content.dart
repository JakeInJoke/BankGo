import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/utils/app_logger.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/core/utils/date_formatter.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:bank_go/features/accounts/presentation/widgets/account_card.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';
import 'package:bank_go/injection_container.dart';

class AccountPageContent extends StatefulWidget {
  final Account account;

  const AccountPageContent({super.key, required this.account});

  @override
  State<AccountPageContent> createState() => _AccountPageContentState();
}

class _AccountPageContentState extends State<AccountPageContent> {
  List<Transaction> _transactions = [];
  bool _isLoadingTx = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final result = await sl<AccountsRepository>().getTransactionsForAccount(
      accountId: widget.account.id,
      limit: 10,
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        AppLogger.warn('ACCOUNT_TX_LOAD_FAIL', failure.message);
        setState(() => _isLoadingTx = false);
      },
      (transactions) {
        setState(() {
          _transactions = transactions;
          _isLoadingTx = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      children: [
        AccountCard(account: widget.account, isRevealed: true),
        const SizedBox(height: AppDimensions.spaceLG),
        Text(
          'Movimientos recientes',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        if (_isLoadingTx)
          const Padding(
            padding: EdgeInsets.all(AppDimensions.spaceLG),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppDimensions.spaceLG),
            child: Center(child: Text('No hay movimientos para esta cuenta.')),
          )
        else
          ...List.generate(_transactions.length, (i) {
            final tx = _transactions[i];
            final isPositive = tx.amount >= 0;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isPositive
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.error.withValues(alpha: 0.12),
                child: Icon(
                  isPositive
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isPositive ? AppColors.success : AppColors.error,
                  size: 18,
                ),
              ),
              title:
                  Text(tx.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${tx.category ?? ''} · ${DateFormatter.formatRelative(tx.date)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                CurrencyFormatter.formatSigned(tx.amount),
                style: TextStyle(
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
      ],
    );
  }
}
