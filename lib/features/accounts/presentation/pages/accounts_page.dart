import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/accounts/data/models/account_model.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';
import 'package:bank_go/injection_container.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  List<AccountModel> _accounts = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final response = await sl<MockBankApi>().getAccounts();
      if (!mounted) return;
      setState(() {
        _accounts = response.map(AccountModel.fromJson).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myAccounts),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAccounts,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingPage,
                  vertical: AppDimensions.spaceLG,
                ),
                itemCount: _accounts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppDimensions.spaceLG),
                itemBuilder: (context, index) {
                  return _AccountCard(account: _accounts[index]);
                },
              ),
            ),
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

  static const Duration _revealDuration = Duration(minutes: 1);

  @override
  Widget build(BuildContext context) {
    final (gradient, icon) = _styleForType(widget.account.type);
    final isPrimary = widget.account.isDefault;
    final showCardNumber = isPrimary || _isRevealed;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account.alias,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _labelForType(widget.account.type),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isPrimary)
                      IconButton(
                        icon: Icon(
                          _isRevealed ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                        onPressed: () {
                          if (!_isRevealed) {
                            _showTokenReveal(context);
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
            if (widget.account.type == AccountType.credit)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consumido: ${CurrencyFormatter.format(widget.account.consumption ?? 0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    'Restante: ${CurrencyFormatter.format(widget.account.remainingCredit)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              )
            else
              Text(
                CurrencyFormatter.format(widget.account.balance),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            const SizedBox(height: AppDimensions.spaceMD),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    showCardNumber
                        ? widget.account.maskedNumber
                        : '**** **** **** ****',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                          letterSpacing: 2,
                        ),
                  ),
                ),
                if (isPrimary)
                  const SizedBox(width: AppDimensions.spaceSM),
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

  void _showTokenReveal(BuildContext outerContext) {
    final tokenController = TextEditingController();
    String? receivedToken;
    bool isRequesting = true;
    String? requestError;
    void Function(void Function())? modalSetState;

    // Fire notification
    outerContext.read<SimulationBloc>().add(AddUserActionNotification(
          title: 'Solicitud de token',
          message:
              '${DateTime.now().toString().substring(0, 16)} — Se solicitó token para ver datos de ${widget.account.alias}.',
          type: NotificationType.security,
        ));

    Future<void> requestToken() async {
      try {
        final token =
            await sl<MockBankApi>().requestSecurityToken(accountId: widget.account.id);
        if (!mounted) return;
        if (modalSetState != null) {
          modalSetState!(() {
            receivedToken = token;
            tokenController.text = token;
            isRequesting = false;
            requestError = null;
          });
        } else {
          receivedToken = token;
          tokenController.text = token;
          isRequesting = false;
          requestError = null;
        }
      } catch (_) {
        if (!mounted) return;
        if (modalSetState != null) {
          modalSetState!(() {
            isRequesting = false;
            requestError = 'No se pudo generar el token.';
          });
        } else {
          isRequesting = false;
          requestError = 'No se pudo generar el token.';
        }
      }
    }

    requestToken();

    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            modalSetState = setModalState;

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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingresa el token para ver los datos de ${widget.account.alias}.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  if (isRequesting)
                    const Text('Generando token...',
                        style: TextStyle(color: AppColors.grey500))
                  else if (receivedToken != null)
                    const Text(
                      'Token auto-completado',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    )
                  else
                    Text(
                      requestError ?? 'No se pudo generar el token.',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  if (!isRequesting && receivedToken == null)
                    TextButton.icon(
                      onPressed: () {
                        setModalState(() {
                          isRequesting = true;
                          requestError = null;
                        });
                        requestToken();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar token'),
                    ),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: receivedToken == null
                        ? null
                        : () {
                            if (tokenController.text == receivedToken) {
                              Navigator.pop(modalContext);
                              setState(() => _isRevealed = true);
                              Future.delayed(_revealDuration, () {
                                if (mounted) {
                                  setState(() => _isRevealed = false);
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(outerContext).showSnackBar(
                                const SnackBar(
                                    content: Text('Token incorrecto.')),
                              );
                            }
                          },
                    child: const Text('Validar'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
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
