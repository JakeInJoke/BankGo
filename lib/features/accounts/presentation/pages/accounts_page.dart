import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/auth/presentation/widgets/pin_indicator.dart';
import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:bank_go/features/accounts/presentation/widgets/account_page_content.dart';
import 'package:bank_go/injection_container.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final PageController _pageController = PageController();
  List<Account> _accounts = [];
  bool _isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final result = await sl<AccountsRepository>().getAccounts();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _isLoading = false),
      (accounts) => setState(() {
        _accounts = accounts;
        _isLoading = false;
      }),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myAccounts),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? const Center(child: Text('No hay cuentas disponibles.'))
              : Column(
                  children: [
                    const SizedBox(height: AppDimensions.spaceMD),
                    _buildPageIndicator(),
                    const SizedBox(height: AppDimensions.spaceSM),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _accounts.length,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemBuilder: (context, index) {
                          return AccountPageContent(
                            account: _accounts[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_accounts.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.grey300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _AccountCard extends StatefulWidget {
  final Account account;

  const _AccountCard({required this.account});

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final (gradient, icon) = _styleForType(widget.account.type);
    final isPrimary = widget.account.isDefault;
    final showInfo = isPrimary || _isRevealed;

    return InkWell(
      onTap: widget.account.isLinkedToCard
          ? () => Navigator.pushNamed(context, '/card-details',
              arguments: widget.account)
          : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: [
            BoxShadow(
              color: _primaryColorForType(widget.account.type)
                  .withValues(alpha: 0.3),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.account.alias,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      _labelForType(widget.account.type),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (!isPrimary)
                      IconButton(
                        icon: Icon(
                          _isRevealed ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                        onPressed: () {
                          if (!_isRevealed) {
                            _showRevealConfirmation(context);
                          } else {
                            setState(() => _isRevealed = false);
                          }
                        },
                      ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                      child: Icon(icon, color: AppColors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            Text(
              showInfo
                  ? CurrencyFormatter.format(widget.account.balance)
                  : '****',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showInfo
                      ? widget.account.maskedNumber
                      : '**** **** **** ****',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.8),
                        letterSpacing: 2,
                      ),
                ),
                if (isPrimary)
                  Container(
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
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRevealConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Verificar Identidad',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Ingresa tu PIN de 6 dígitos para ver los saldos.'),
              const SizedBox(height: 24),
              const PinIndicator(length: 6, filledCount: 0),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(modalContext);
                  setState(() => _isRevealed = true);
                  // Hide again after 1 minute for security
                  Future.delayed(const Duration(minutes: 1), () {
                    if (mounted) setState(() => _isRevealed = false);
                  });
                },
                child: const Text('Confirmar'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
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
