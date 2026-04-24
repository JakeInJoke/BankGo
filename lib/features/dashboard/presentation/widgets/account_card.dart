import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/dashboard/domain/entities/account_summary.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_bloc.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_event.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_state.dart';
import 'package:bank_go/features/accounts/presentation/widgets/card_action_modal.dart';

class AccountCard extends StatefulWidget {
  final AccountSummary summary;
  final String accountId;

  const AccountCard({super.key, required this.summary, this.accountId = '1'});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardBloc, CardState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        final isCardEnabled = !state.isFrozen;

        return Column(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isCardEnabled ? 1.0 : 0.6,
              child: Container(
                height: AppDimensions.accountCardHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCardEnabled
                        ? [AppColors.primary, AppColors.primaryDark]
                        : [AppColors.grey400, AppColors.grey600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: (isCardEnabled
                              ? AppColors.primary
                              : AppColors.grey500)
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
                Text(
                  isCardEnabled
                      ? "Estado: Tarjeta Activa"
                      : "Estado: Tarjeta Apagada",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Switch(
                  value: isCardEnabled,
                  onChanged: (value) {
                    _showFreezeTokenRequest(context, !value);
                  },
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.2),
                  inactiveThumbColor: AppColors.error,
                  inactiveTrackColor: AppColors.error.withValues(alpha: 0.2),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showFreezeTokenRequest(BuildContext context, bool freeze) {
    context.read<CardBloc>().add(RequestFreezeToken(widget.accountId));
    context.read<SimulationBloc>().add(AddUserActionNotification(
          title: 'Solicitud de token',
          message:
              '${DateTime.now().toString().substring(0, 16)} — Se solicitó token para ${freeze ? 'congelar' : 'activar'} tarjeta principal.',
          type: NotificationType.security,
        ));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return BlocProvider.value(
          value: context.read<CardBloc>(),
          child: CardActionModal(
            accountId: widget.accountId,
            isFreezeAction: true,
            title: freeze ? 'Congelar Tarjeta' : 'Activar Tarjeta',
            description:
                'Ingresa el token para ${freeze ? 'congelar' : 'activar'} tu tarjeta.',
            onConfirm: (token) {
              context
                  .read<CardBloc>()
                  .add(ToggleCardFreeze(widget.accountId, freeze, token));
            },
          ),
        );
      },
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
          "Saldo en Cuenta",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.7),
              ),
        ),
        const SizedBox(height: AppDimensions.spaceXXS),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            CurrencyFormatter.format(widget.summary.availableBalance),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.summary.accountNumber,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                    letterSpacing: 2,
                    fontFamily: 'Courier',
                  ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSM),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceSM,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.22),
            ),
          ),
          child: Text(
            'BANKGO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
          ),
        ),
      ],
    );
  }
}
