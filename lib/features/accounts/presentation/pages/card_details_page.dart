import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_bloc.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_event.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_state.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/injection_container.dart';

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
                account.type == AccountType.credit
                    ? _buildCreditSection(context)
                    : _buildAccountBalanceSection(context),
                const SizedBox(height: AppDimensions.spaceLG),
                _buildStatusSection(context, state),
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  state.isSensitiveVisible
                      ? (state.cardNumber ?? '**** **** **** ****')
                      : account.maskedNumber,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500),
                ),
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
              Image.network(
                'https://www.svgrepo.com/show/327380/visa.svg',
                height: 20,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 20,
                  width: 35,
                  child: Icon(Icons.payment),
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
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado de la Tarjeta',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Apágala para evitar compras no autorizadas',
                    style: TextStyle(fontSize: 12, color: AppColors.grey500)),
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

  Widget _buildAccountBalanceSection(BuildContext context) {
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
          const Text(
            'Saldo de la cuenta',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            CurrencyFormatter.format(account.balance),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFreezeTokenRequest(BuildContext context, bool freeze) {
    context.read<CardBloc>().add(RequestFreezeToken(account.id));
    context.read<SimulationBloc>().add(AddUserActionNotification(
          title: 'Solicitud de token',
          message:
              '${DateTime.now().toString().substring(0, 16)} — Se solicitó token para ${freeze ? 'congelar' : 'activar'} tarjeta de ${account.alias}.',
          type: NotificationType.security,
        ));
    final tokenController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return BlocProvider.value(
          value: context.read<CardBloc>(),
          child: BlocConsumer<CardBloc, CardState>(
            listenWhen: (previous, current) =>
                previous.securityToken != current.securityToken ||
                previous.isLoading != current.isLoading ||
                previous.error != current.error,
            listener: (context, state) {
              if (state.securityToken != null && tokenController.text.isEmpty) {
                tokenController.text = state.securityToken!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Token recibido: ${state.securityToken!.replaceAll(RegExp(r'.'), '*')}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              if (!state.isLoading &&
                  state.error == null &&
                  state.securityToken == null) {
                Navigator.of(modalContext).pop();
              }
            },
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 24,
                    right: 24,
                    top: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(freeze ? 'Congelar Tarjeta' : 'Activar Tarjeta',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(
                        'Ingresa el token para ${freeze ? 'congelar' : 'activar'} tu tarjeta.'),
                    const SizedBox(height: 8),
                    if (state.securityToken != null)
                      const Text('Token auto-completado',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary))
                    else
                      const Text('Generando token...',
                          style: TextStyle(color: AppColors.grey500)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: tokenController,
                      obscureText: true,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Token de seguridad',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state.isLoading || state.securityToken == null
                          ? null
                          : () {
                              if (tokenController.text != state.securityToken) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Token incorrecto.'),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(modalContext).pop();
                              context.read<CardBloc>().add(ToggleCardFreeze(
                                  account.id, freeze, tokenController.text));
                            },
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Confirmar'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
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
    context.read<SimulationBloc>().add(AddUserActionNotification(
          title: 'Solicitud de token',
          message:
              '${DateTime.now().toString().substring(0, 16)} — Se solicitó token para ver datos sensibles de ${account.alias}.',
          type: NotificationType.security,
        ));
    final tokenController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return BlocProvider.value(
          value: context.read<CardBloc>(),
          child: BlocConsumer<CardBloc, CardState>(
            listener: (context, state) {
              if (state.securityToken != null && tokenController.text.isEmpty) {
                tokenController.text = state.securityToken!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Token recibido: ${state.securityToken!.replaceAll(RegExp(r'.'), '*')}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              if (state.isSensitiveVisible) {
                Navigator.pop(modalContext);
              }
            },
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Verificación de Seguridad',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                        'Ingresa el token de seguridad para ver los datos de la tarjeta.'),
                    const SizedBox(height: 8),
                    if (state.securityToken != null)
                      const Text('Token auto-completado',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary))
                    else
                      const Text('Generando token...',
                          style: TextStyle(color: AppColors.grey500)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: tokenController,
                      obscureText: true,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Token de seguridad',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state.isLoading || state.securityToken == null
                          ? null
                          : () {
                              if (tokenController.text != state.securityToken) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Token incorrecto.'),
                                  ),
                                );
                                return;
                              }
                              Navigator.of(modalContext).pop();
                              context.read<CardBloc>().add(
                                    ShowSensitiveInfo(
                                        account.id, tokenController.text),
                                  );
                            },
                      child: state.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Validar y Mostrar'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
