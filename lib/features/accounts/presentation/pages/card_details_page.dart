import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_bloc.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_event.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_state.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/accounts/presentation/widgets/card_action_modal.dart';

class CardDetailsPage extends StatelessWidget {
  final Account account;

  const CardDetailsPage({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Tarjeta'),
      ),
      body: BlocConsumer<CardBloc, CardState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.cardNumber == null && !state.isLoading) {
            context.read<CardBloc>().add(LoadCardDetails(account.id));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingPage),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCardVisual(context, state),
                const SizedBox(height: AppDimensions.spaceXL),
                _buildStatusSection(context, state),
                const SizedBox(height: AppDimensions.spaceLG),
                if (account.type == AccountType.credit)
                  _buildCreditSection(context),
                const SizedBox(height: AppDimensions.spaceXL),
                _buildActions(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardVisual(BuildContext context, CardState state) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingCard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('BankGo',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              Icon(Icons.contactless, color: Colors.white),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.isSensitiveVisible
                    ? (state.cardNumber ?? '**** **** **** ****')
                    : account.maskedNumber,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('EXP',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 10)),
                      Text(
                          state.isSensitiveVisible
                              ? (state.expirationDate ?? 'MM/YY')
                              : '**/**',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CVV',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 10)),
                      Text(
                          state.isSensitiveVisible
                              ? (state.cvv ?? '***')
                              : '***',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ANA GOMEZ',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceSM,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                ),
                child: const Text(
                  'VISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, CardState state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado de la Tarjeta',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Apágala para evitar compras no autorizadas',
                  style: TextStyle(fontSize: 12, color: AppColors.grey500),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Switch(
            value: !state.isFrozen,
            onChanged: (val) {
              _showFreezeTokenRequest(context, !val);
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showFreezeTokenRequest(BuildContext context, bool freeze) {
    context.read<CardBloc>().add(RequestFreezeToken(account.id));
    context.read<SimulationBloc>().add(
          AddUserActionNotification(
            title: 'Código de seguridad enviado',
            message:
                'Se envió un código para ${freeze ? 'congelar' : 'activar'} tu tarjeta.',
            type: NotificationType.security,
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return BlocProvider.value(
          value: context.read<CardBloc>(),
          child: CardActionModal(
            accountId: account.id,
            isFreezeAction: true,
            title: freeze ? 'Congelar Tarjeta' : 'Activar Tarjeta',
            description:
                'Ingresa el token para ${freeze ? 'congelar' : 'activar'} tu tarjeta.',
            onConfirm: (token) {
              context
                  .read<CardBloc>()
                  .add(ToggleCardFreeze(account.id, freeze, token));
            },
          ),
        );
      },
    );
  }

  Widget _buildCreditSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Línea de Crédito',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: AppDimensions.spaceSM),
        LinearProgressIndicator(
          value: (account.consumption ?? 0) / (account.creditLimit ?? 1),
          backgroundColor: AppColors.grey200,
          color: AppColors.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: AppDimensions.spaceXS),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                'Consumo: ${CurrencyFormatter.format(account.consumption ?? 0)}',
                style: const TextStyle(fontSize: 12)),
            Text(
                'Disponible: ${CurrencyFormatter.format(account.remainingCredit)}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, CardState state) {
    if (state.isSensitiveVisible) {
      return Column(
        children: [
          const Text('La información se ocultará en:',
              style: TextStyle(color: AppColors.grey600)),
          Text(
            '${(state.remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(state.remainingSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          TextButton(
            onPressed: () =>
                context.read<CardBloc>().add(const HideSensitiveInfo()),
            child: const Text('Ocultar ahora'),
          ),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: () {
        // Here we should request a token first, but for the demo we'll just show it
        // The user said: "deba pedirse de nuevo un token al mock server"
        _showTokenRequest(context);
      },
      icon: const Icon(Icons.visibility),
      label: const Text('Ver datos sensibles (CVV dinámico)'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showTokenRequest(BuildContext context) {
    context.read<CardBloc>().add(RequestFreezeToken(account.id));
    context.read<SimulationBloc>().add(
          const AddUserActionNotification(
            title: 'Código de seguridad enviado',
            message:
                'Se envió un código para visualizar los datos sensibles de la tarjeta.',
            type: NotificationType.security,
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return BlocProvider.value(
          value: context.read<CardBloc>(),
          child: CardActionModal(
            accountId: account.id,
            isFreezeAction: false,
            title: 'Verificación de Seguridad',
            description:
                'Ingresa el token de seguridad para ver los datos de la tarjeta.',
            onConfirm: (token) {
              context
                  .read<CardBloc>()
                  .add(ShowSensitiveInfo(account.id, token));
            },
          ),
        );
      },
    );
  }
}
