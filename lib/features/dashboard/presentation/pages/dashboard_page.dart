import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/core/routes/app_router.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/accounts/data/models/account_model.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_event.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_state.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';
import 'package:bank_go/features/dashboard/presentation/pages/notifications_page.dart';
import 'package:bank_go/features/dashboard/presentation/widgets/quick_actions_widget.dart';
import 'package:bank_go/features/dashboard/presentation/widgets/transaction_tile.dart';
import 'package:bank_go/injection_container.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<DashboardBloc>()..add(const DashboardLoadRequested()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 18) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final name = state is AuthAuthenticated
                ? state.user.name.split(' ').first
                : '';
            return Text('${_greeting()}, $name 👋');
          },
        ),
        actions: [
          BlocBuilder<SimulationBloc, SimulationState>(
            builder: (context, simulationState) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  if (simulationState.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 18),
                        child: Text(
                          simulationState.unreadCount > 99
                              ? '99+'
                              : simulationState.unreadCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(const DashboardRefreshRequested());
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return _buildSkeleton();
            }
            if (state is DashboardError) {
              return _buildError(context, state.message);
            }
            if (state is DashboardLoaded) {
              return _buildContent(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: _BottomNavigationBar(),
    );
  }

  Widget _buildContent(BuildContext context, DashboardLoaded state) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
        vertical: AppDimensions.spaceLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DashboardAccountsCarousel(),
          const SizedBox(height: AppDimensions.spaceXL),
          const QuickActionsWidget(),
          const SizedBox(height: AppDimensions.spaceXL),
          _buildRecentTransactions(context, state),
          const SizedBox(height: AppDimensions.spaceLG),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentTransactions,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.transactions),
              child: const Text(AppStrings.seeAll),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceSM),
        if (state.recentTransactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceLG),
              child: Text(
                AppStrings.noTransactions,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.recentTransactions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) => TransactionTile(
              transaction: state.recentTransactions[index],
            ),
          ),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            ElevatedButton(
              onPressed: () => context
                  .read<DashboardBloc>()
                  .add(const DashboardLoadRequested()),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Shimmer.fromColors(
        baseColor: AppColors.grey200,
        highlightColor: AppColors.grey100,
        child: Column(
          children: [
            Container(
              height: AppDimensions.accountCardHeight,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (_) => Column(
                  children: [
                    Container(
                      width: AppDimensions.quickActionSize,
                      height: AppDimensions.quickActionSize,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceXS),
                    Container(
                      width: 50,
                      height: 12,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLG),
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spaceMD),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: double.infinity,
                            color: AppColors.white,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 12,
                            width: 120,
                            color: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.logout),
        content: const Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.pushReplacementNamed(context, AppRouter.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.pushNamed(context, AppRouter.accounts);
            break;
          case 2:
            Navigator.pushNamed(context, AppRouter.transactions);
            break;
          case 3:
            Navigator.pushNamed(context, AppRouter.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: AppStrings.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: AppStrings.accounts,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: AppStrings.transactions,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: AppStrings.profile,
        ),
      ],
    );
  }
}

class _DashboardAccountsCarousel extends StatefulWidget {
  const _DashboardAccountsCarousel();

  @override
  State<_DashboardAccountsCarousel> createState() =>
      _DashboardAccountsCarouselState();
}

class _DashboardAccountsCarouselState
    extends State<_DashboardAccountsCarousel> {
  final PageController _pageController = PageController();
  List<AccountModel> _accounts = const [];
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
    try {
      final response = await sl<MockBankApi>().getAccounts();
      if (!mounted) return;
      setState(() {
        _accounts = response.map(AccountModel.fromJson).toList();
        _isLoading = false;
        if (_currentPage >= _accounts.length) {
          _currentPage = _accounts.isEmpty ? 0 : _accounts.length - 1;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
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
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
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
                          Row(
                            children: [
                              Text(
                                'Usado: ${CurrencyFormatter.format(account.consumption ?? 0)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.75),
                                    ),
                              ),
                            ],
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
