import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/core/utils/date_formatter.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';
import 'package:bank_go/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:bank_go/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:bank_go/features/transactions/presentation/bloc/transactions_state.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<TransactionsBloc>()
        ..add(const TransactionsLoadRequested()),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactionHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: AppDimensions.spaceMD),
                  Text(state.message),
                  const SizedBox(height: AppDimensions.spaceMD),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TransactionsBloc>()
                        .add(const TransactionsLoadRequested()),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }
          if (state is TransactionsLoaded) {
            return _buildList(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, TransactionsLoaded state) {
    if (state.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.grey300,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              AppStrings.noTransactions,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        _FilterChips(activeFilter: state.activeFilter),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingPage,
              vertical: AppDimensions.spaceSM,
            ),
            itemCount: state.transactions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) =>
                _TransactionItem(transaction: state.transactions[index]),
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL),
        ),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.filterBy,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            ListTile(
              leading: const Icon(Icons.filter_list_off),
              title: const Text('Todos'),
              onTap: () {
                context
                    .read<TransactionsBloc>()
                    .add(const TransactionsFilterChanged());
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.arrow_downward, color: AppColors.income),
              title: const Text(AppStrings.income),
              onTap: () {
                context.read<TransactionsBloc>().add(
                      const TransactionsFilterChanged(
                        type: TransactionType.income,
                      ),
                    );
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward, color: AppColors.expense),
              title: const Text(AppStrings.expense),
              onTap: () {
                context.read<TransactionsBloc>().add(
                      const TransactionsFilterChanged(
                        type: TransactionType.expense,
                      ),
                    );
                Navigator.pop(sheetContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: AppColors.transfer),
              title: const Text(AppStrings.transfer),
              onTap: () {
                context.read<TransactionsBloc>().add(
                      const TransactionsFilterChanged(
                        type: TransactionType.transfer,
                      ),
                    );
                Navigator.pop(sheetContext);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final TransactionType? activeFilter;

  const _FilterChips({required this.activeFilter});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
        vertical: AppDimensions.spaceSM,
      ),
      child: Row(
        children: [
          _chip(context, null, 'Todos'),
          const SizedBox(width: AppDimensions.spaceXS),
          _chip(context, TransactionType.income, AppStrings.income),
          const SizedBox(width: AppDimensions.spaceXS),
          _chip(context, TransactionType.expense, AppStrings.expense),
          const SizedBox(width: AppDimensions.spaceXS),
          _chip(context, TransactionType.transfer, AppStrings.transfer),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, TransactionType? type, String label) {
    final isSelected = activeFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => context
          .read<TransactionsBloc>()
          .add(TransactionsFilterChanged(type: type)),
      selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.grey600,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(transaction.type);
    final icon = _iconForType(transaction.type);
    final amountText = CurrencyFormatter.formatSigned(transaction.amount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceSM),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Icon(icon, color: color, size: AppDimensions.iconMD),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${transaction.description} • ${DateFormatter.formatDate(transaction.date)}',
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (transaction.reference != null)
                  Text(
                    'Ref: ${transaction.reference}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey400,
                        ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: transaction.isIncome
                          ? AppColors.income
                          : AppColors.expense,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              _StatusBadge(status: transaction.status),
            ],
          ),
        ],
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

class _StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      TransactionStatus.completed => (AppColors.success, 'Completada'),
      TransactionStatus.pending => (AppColors.warning, 'Pendiente'),
      TransactionStatus.failed => (AppColors.error, 'Fallida'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceXS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
