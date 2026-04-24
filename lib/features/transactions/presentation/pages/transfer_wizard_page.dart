import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/accounts/data/models/account_model.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';
import 'package:bank_go/features/transactions/presentation/bloc/transfer_bloc.dart';
import 'package:bank_go/features/transactions/presentation/bloc/transfer_event_state.dart';
import 'package:bank_go/injection_container.dart';

class TransferWizardPage extends StatefulWidget {
  const TransferWizardPage({super.key});

  @override
  State<TransferWizardPage> createState() => _TransferWizardPageState();
}

class _TransferWizardPageState extends State<TransferWizardPage> {
  final PageController _pageController = PageController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  int _currentStep = 0;
  String? _selectedSourceAccountId;
  List<AccountModel> _accounts = const [];
  bool _isLoadingAccounts = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final response = await sl<MockBankApi>().getAccounts();
      if (!mounted) return;
      setState(() {
        _accounts = response
            .map(AccountModel.fromJson)
            .where((account) => account.type != AccountType.credit)
            .toList();
        _isLoadingAccounts = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingAccounts = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep++);
  }

  void _resetWizard(BuildContext context) {
    _accountController.clear();
    _amountController.clear();
    _tokenController.clear();
    context.read<TransferBloc>().add(const ResetTransfer());
    setState(() {
      _currentStep = 0;
      _selectedSourceAccountId = null;
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TransferBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transferir'),
        ),
        body: BlocConsumer<TransferBloc, TransferState>(
          listener: (context, state) {
            if (state.status == TransferStatus.accountValid &&
                _currentStep == 0) {
              _nextPage();
            } else if (state.status == TransferStatus.tokenRequested &&
                _currentStep == 2) {
              if (state.securityToken != null) {
                _tokenController.text = state.securityToken!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Token recibido: ${state.securityToken!.replaceAll(RegExp(r'.'), '*')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.read<SimulationBloc>().add(AddUserActionNotification(
                      title: 'Token de transferencia',
                      message:
                          '${DateTime.now().toString().substring(0, 16)} — Token solicitado para transferencia a cuenta ${state.destinationAccount ?? ''}.',
                      type: NotificationType.info,
                    ));
              }
              _nextPage();
            } else if (state.status == TransferStatus.success) {
              context.read<SimulationBloc>().add(AddUserActionNotification(
                    title: 'Transferencia exitosa',
                    message:
                        '${DateTime.now().toString().substring(0, 16)} — Transferencia de S/ ${state.amount.toStringAsFixed(2)} a cuenta ${state.destinationAccount ?? ''} completada.',
                    type: NotificationType.purchase,
                  ));
              if (_currentStep == 3) {
                _nextPage();
              }
            } else if (state.status == TransferStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error ?? 'Error')),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildStepIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(context, state),
                      _buildStep2(context, state),
                      _buildStep3(context, state),
                      _buildStep4(context, state),
                      _buildStep5(context, state),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
        vertical: AppDimensions.spaceMD,
      ),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? AppColors.primary
                    : AppColors.grey200,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1(BuildContext context, TransferState state) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppDimensions.paddingPage,
          right: AppDimensions.paddingPage,
          top: AppDimensions.spaceLG,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + AppDimensions.spaceLG,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: constraints.maxHeight - AppDimensions.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('¿A quién deseas transferir?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppDimensions.spaceSM),
              const Text(
                'Ingresa el número de cuenta o tarjeta (16 dígitos) del destinatario.',
                style: TextStyle(color: AppColors.grey500),
              ),
              const SizedBox(height: AppDimensions.spaceXXL),
              TextField(
                controller: _accountController,
                decoration: InputDecoration(
                  labelText: 'Número de cuenta',
                  prefixIcon: const Icon(Icons.account_balance_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  hintText: '0000 0000 0000 0000',
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppDimensions.spaceXL),
              ElevatedButton(
                onPressed: state.status == TransferStatus.validatingAccount
                    ? null
                    : () {
                        if (_accountController.text.length < 16) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('El número debe tener 16 dígitos'),
                            ),
                          );
                          return;
                        }
                        context.read<TransferBloc>().add(
                            UpdateDestinationAccount(_accountController.text));
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: state.status == TransferStatus.validatingAccount
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Validar Cuenta',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2(BuildContext context, TransferState state) {
    if (_isLoadingAccounts) {
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppDimensions.paddingPage,
          right: AppDimensions.paddingPage,
          top: AppDimensions.spaceLG,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + AppDimensions.spaceLG,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: constraints.maxHeight - AppDimensions.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Detalles del envío',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (state.isDestinationVerified) ...[
                const SizedBox(height: AppDimensions.spaceMD),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spaceMD),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded,
                          color: AppColors.success),
                      const SizedBox(width: AppDimensions.spaceSM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.destinationAccountName ??
                                  'Destinatario verificado',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${state.destinationBankName ?? 'Banco mock'} · ${state.destinationAccount ?? ''}',
                              style: const TextStyle(color: AppColors.grey500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.spaceXXL),
              const Text(
                'Cuenta de origen',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: AppDimensions.spaceSM),
              DropdownButtonFormField<String>(
                initialValue: _selectedSourceAccountId,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                hint: const Text('Selecciona una cuenta'),
                items: _accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(
                          '${a.alias} (${CurrencyFormatter.format(a.balance)})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedSourceAccountId = val),
              ),
              const SizedBox(height: AppDimensions.spaceXL),
              const Text(
                'Monto a transferir',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: AppDimensions.spaceSM),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'S/',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  hintText: '0.00',
                ),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceXL),
              ElevatedButton(
                onPressed: () {
                  if (_selectedSourceAccountId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selecciona una cuenta de origen'),
                      ),
                    );
                    return;
                  }

                  final amount = double.tryParse(
                          _amountController.text.replaceAll(',', '.')) ??
                      0;
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ingresa un monto válido')),
                    );
                    return;
                  }

                  final account = _accounts
                      .firstWhere((a) => a.id == _selectedSourceAccountId);
                  final available = account.type == AccountType.credit
                      ? account.remainingCredit
                      : account.balance;

                  if (amount > available) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          account.type == AccountType.credit
                              ? 'Línea de crédito insuficiente. Disponible: ${CurrencyFormatter.format(available)}'
                              : 'Saldo insuficiente. Disponible: ${CurrencyFormatter.format(available)}',
                        ),
                      ),
                    );
                    return;
                  }

                  context
                      .read<TransferBloc>()
                      .add(UpdateTransferDetails(account, amount));
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep3(BuildContext context, TransferState state) {
    final sourceAccount = state.sourceAccount;
    final sourceLabel = sourceAccount?.alias ?? 'Cuenta no seleccionada';
    final sourceNumber = sourceAccount?.maskedNumber ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
        vertical: AppDimensions.spaceLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Confirmación de transferencia',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          const Text(
            'Revisa los datos antes de solicitar el token de seguridad.',
            style: TextStyle(color: AppColors.grey500),
          ),
          const SizedBox(height: AppDimensions.spaceXL),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(label: 'Desde', value: sourceLabel),
                if (sourceNumber.isNotEmpty)
                  _SummaryRow(label: 'Nro. origen', value: sourceNumber),
                _SummaryRow(
                  label: 'Hacia',
                  value: state.destinationAccountName ?? 'Destinatario',
                ),
                _SummaryRow(
                  label: 'Cuenta destino',
                  value: state.destinationAccount ?? '-',
                ),
                _SummaryRow(
                  label: 'Banco',
                  value: state.destinationBankName ?? 'Banco mock',
                ),
                _SummaryRow(
                  label: 'Monto',
                  value: CurrencyFormatter.format(state.amount),
                  isAmount: true,
                ),
              ],
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() => _currentStep--);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Editar datos'),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          ElevatedButton(
            onPressed: state.status == TransferStatus.processing
                ? null
                : () {
                    context.read<TransferBloc>().add(const RequestToken());
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: state.status == TransferStatus.processing
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Solicitar token',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(BuildContext context, TransferState state) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppDimensions.paddingPage,
          right: AppDimensions.paddingPage,
          top: AppDimensions.spaceLG,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + AppDimensions.spaceLG,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: constraints.maxHeight - AppDimensions.spaceLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Verificación Final',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (state.isDestinationVerified) ...[
                const SizedBox(height: AppDimensions.spaceMD),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_outlined),
                  title: Text(state.destinationAccountName ?? 'Destinatario'),
                  subtitle: Text(
                    '${state.destinationBankName ?? 'Banco mock'} · ${state.destinationAccount ?? ''}',
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.spaceXL),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.security_rounded,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Se ha enviado un token a tu móvil registrado:',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (state.securityToken != null)
                      const Text(
                        'Token auto-completado y protegido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      )
                    else
                      const Text(
                        'Generando token...',
                        style: TextStyle(color: AppColors.grey500),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXXL),
              TextField(
                controller: _tokenController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Ingresa el token',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  counterText: '',
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXL),
              ElevatedButton(
                onPressed: state.status == TransferStatus.processing
                    ? null
                    : () {
                        context
                            .read<TransferBloc>()
                            .add(SubmitTransfer(_tokenController.text));
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: state.status == TransferStatus.processing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirmar Transferencia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep5(BuildContext context, TransferState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
        vertical: AppDimensions.spaceLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceXL),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 52,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLG),
                const Text(
                  'Transferencia realizada',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppDimensions.spaceSM),
                const Text(
                  'La operación se completó correctamente y ya fue registrada en tus movimientos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey500),
                ),
                const SizedBox(height: AppDimensions.spaceXL),
                _SuccessDetailRow(
                  label: 'Monto transferido',
                  value: CurrencyFormatter.format(state.amount),
                  highlight: true,
                ),
                _SuccessDetailRow(
                  label: 'Destinatario',
                  value: state.destinationAccountName ?? 'Cuenta verificada',
                ),
                _SuccessDetailRow(
                  label: 'Cuenta destino',
                  value: state.destinationAccount ?? '-',
                ),
                _SuccessDetailRow(
                  label: 'Cuenta origen',
                  value: state.sourceAccount?.alias ?? '-',
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Finalizar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          OutlinedButton(
            onPressed: () => _resetWizard(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Nueva transferencia'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAmount;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.grey500),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
                color: isAmount ? AppColors.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SuccessDetailRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.grey500),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSM),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                color: highlight ? AppColors.success : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
