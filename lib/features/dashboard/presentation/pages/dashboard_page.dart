import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shimmer/shimmer.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/routes/app_router.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_event.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_state.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:bank_go/features/dashboard/presentation/widgets/account_card.dart';
import 'package:bank_go/features/dashboard/presentation/widgets/quick_actions_widget.dart';
import 'package:bank_go/features/dashboard/presentation/widgets/transaction_tile.dart';

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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
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
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccountCard(summary: state.accountSummary),
          const SizedBox(height: AppDimensions.spaceLG),
          const QuickActionsWidget(),
          const SizedBox(height: AppDimensions.spaceLG),
          _buildRecentTransactions(context, state),
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
