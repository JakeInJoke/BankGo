import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/routes/app_router.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/accounts/domain/repositories/accounts_repository.dart';

class DashboardAccountsCarousel extends StatefulWidget {
  const DashboardAccountsCarousel({super.key});

  @override
  State<DashboardAccountsCarousel> createState() =>
      _DashboardAccountsCarouselState();
}

class _DashboardAccountsCarouselState extends State<DashboardAccountsCarousel> {
  final PageController _pageController = PageController();
  List<Account> _accounts = const [];
  bool _isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    final result = await GetIt.instance<AccountsRepository>().getAccounts();
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _isLoading = false),
      (accounts) => setState(() {
        _accounts = accounts;
        _isLoading = false;
        if (_currentPage >= _accounts.length) {
          _currentPage = _accounts.isEmpty ? 0 : _accounts.length - 1;
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 170,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_accounts.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No hay cuentas disponibles.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tus cuentas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${_currentPage + 1}/${_accounts.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _accounts.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final account = _accounts[index];
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.spaceSM),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  onTap: account.isLinkedToCard
                      ? () => Navigator.pushNamed(
                            context,
                            AppRouter.cardDetails,
                            arguments: account,
                          )
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppDimensions.paddingCard),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.alias,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: AppDimensions.spaceXS),
                        Text(
                          account.type == AccountType.credit
                              ? 'Tarjeta de crédito'
                              : 'Cuenta bancaria',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                        ),
                        const Spacer(),
                        if (account.type == AccountType.credit) ...[
                          Text(
                            'Disponible',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                          ),
                          Text(
                            CurrencyFormatter.format(account.remainingCredit),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: AppDimensions.spaceXS),
                          Text(
                            'Usado: ${CurrencyFormatter.format(account.consumption ?? 0)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                          ),
                        ] else ...[
                          Text(
                            'Saldo disponible',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                          ),
                          Text(
                            CurrencyFormatter.format(account.balance),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                        const SizedBox(height: AppDimensions.spaceXS),
                        Text(
                          account.maskedNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    letterSpacing: 1.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
