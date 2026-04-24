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
      if (mounted) {
        setState(() {
          _accounts = response
              .map(AccountModel.fromJson)
              .where((a) => a.type != AccountType.credit)
              .toList();
          _isLoadingAccounts = false;
        });
      }
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
            // Step 0 → 1: destinatario validado
            if (state.status == TransferStatus.accountValid &&
                _currentStep == 0) {
              _nextPage();
              // Step 1 → 2: detalles validados (saldo OK) → ir a revisión
            } else if (state.status == TransferStatus.accountValid &&
                _currentStep == 1) {
              _nextPage();
              // Step 2 → 3: token recibido → autofill oculto + campanita
            } else if (state.status == TransferStatus.tokenRequested &&
                _currentStep == 2) {
              _tokenController.text = state.securityToken ?? '';
              context.read<SimulationBloc>().add(
                    const AddUserActionNotification(
                      title: 'Código de seguridad enviado',
                      message:
                          'Se envió un código de verificación a tu móvil registrado para confirmar la transferencia.',
                      type: NotificationType.security,
                    ),
                  );
              _nextPage();
              // Step 3 → 4: transferencia exitosa
            } else if (state.status == TransferStatus.success &&
                _currentStep == 3) {
              context.read<SimulationBloc>().add(
                    AddUserActionNotification(
                      title: 'Transferencia realizada',
                      message:
                          'Tu transferencia de ${CurrencyFormatter.format(state.amount)} fue procesada exitosamente.',
                      type: NotificationType.info,
                      amount: state.amount,
                    ),
                  );
              _nextPage();
            } else if (state.status == TransferStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? 'Error'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                if (_currentStep < 4) _buildStepIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(context, state),
                      _buildStep2(context, state),
                      _buildStepReview(context, state),
                      _buildStepToken(context, state),
                      _buildStepSuccess(context, state),
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
        children: List.generate(4, (index) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingPage,
              vertical: AppDimensions.spaceLG,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('¿A quién deseas transferir?',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppDimensions.spaceSM),
                const Text(
                    'Ingresa el número de cuenta o tarjeta (16 dígitos) del destinatario.',
                    style: TextStyle(color: AppColors.grey500)),
                const SizedBox(height: AppDimensions.spaceXXL),
                TextField(
                  controller: _accountController,
                  decoration: InputDecoration(
                    labelText: 'Número de cuenta',
                    prefixIcon: const Icon(Icons.account_balance_outlined),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    hintText: '0000 0000 0000 0000',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 16,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingPage,
            0,
            AppDimensions.paddingPage,
            AppDimensions.spaceLG,
          ),
          child: ElevatedButton(
            onPressed: state.status == TransferStatus.validatingAccount
                ? null
                : () {
                    if (_accountController.text.length < 16) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('El número debe tener 16 dígitos')),
                      );
                      return;
                    }
                    context
                        .read<TransferBloc>()
                        .add(UpdateDestinationAccount(_accountController.text));
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: state.status == TransferStatus.validatingAccount
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Validar Cuenta',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(BuildContext context, TransferState state) {
    if (_isLoadingAccounts) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingPage,
              vertical: AppDimensions.spaceLG,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Detalles del envío',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppDimensions.spaceXXL),
                const Text('Cuenta de origen',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: AppDimensions.spaceSM),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSourceAccountId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD)),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  hint: const Text('Selecciona una cuenta'),
                  items: _accounts
                      .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.type == AccountType.credit
                              ? '${a.alias} (Disponible: ${CurrencyFormatter.format(a.remainingCredit)})'
                              : '${a.alias} (${CurrencyFormatter.format(a.balance)})')))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedSourceAccountId = val),
                ),
                const SizedBox(height: AppDimensions.spaceXL),
                const Text('Monto a transferir',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: AppDimensions.spaceSM),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text('S/',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold))),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD)),
                    hintText: '0.00',
                  ),
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingPage,
            0,
            AppDimensions.paddingPage,
            AppDimensions.spaceLG,
          ),
          child: ElevatedButton(
            onPressed: () {
              if (_selectedSourceAccountId == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Selecciona una cuenta de origen')));
                return;
              }
              final amount = double.tryParse(_amountController.text) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa un monto válido')));
                return;
              }
              final account =
                  _accounts.firstWhere((a) => a.id == _selectedSourceAccountId);
              // Solo valida detalles; RequestToken se lanza desde la pantalla de revisión
              context
                  .read<TransferBloc>()
                  .add(UpdateTransferDetails(account, amount));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Continuar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ── Step 2: Revisión de datos (ANTES del token) ──────────────────────────
  Widget _buildStepReview(BuildContext context, TransferState state) {
    final isLoading = state.status == TransferStatus.processing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingPage,
              vertical: AppDimensions.spaceLG,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Revisa tu transferencia',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppDimensions.spaceSM),
                const Text(
                    'Confirma los datos antes de recibir el código de seguridad.',
                    style: TextStyle(color: AppColors.grey500)),
                const SizedBox(height: AppDimensions.spaceXL),
                _buildReviewRow(Icons.attach_money, 'Monto',
                    CurrencyFormatter.format(state.amount),
                    valueStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
                const Divider(height: AppDimensions.spaceLG),
                _buildReviewRow(Icons.account_balance_wallet_outlined,
                    'Cuenta origen', state.sourceAccount?.alias ?? '-'),
                const Divider(height: AppDimensions.spaceLG),
                _buildReviewRow(Icons.person_outline, 'Destinatario',
                    state.destinationAccountName ?? 'Cuenta verificada'),
                if (state.destinationBankName != null) ...[
                  const Divider(height: AppDimensions.spaceLG),
                  _buildReviewRow(Icons.account_balance_outlined, 'Banco',
                      state.destinationBankName!),
                ],
                const Divider(height: AppDimensions.spaceLG),
                _buildReviewRow(Icons.credit_card_outlined, 'Cuenta destino',
                    _formatAccountDisplay(state.destinationAccount ?? '')),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingPage,
            0,
            AppDimensions.paddingPage,
            AppDimensions.spaceLG,
          ),
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () => context.read<TransferBloc>().add(const RequestToken()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Confirmar y recibir código',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ── Step 3: Token oculto (autollenado, no editable) ───────────────────────
  Widget _buildStepToken(BuildContext context, TransferState state) {
    final isLoading = state.status == TransferStatus.processing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingPage,
              vertical: AppDimensions.spaceLG,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Código de seguridad',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppDimensions.spaceXL),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.security_rounded,
                          color: AppColors.primary, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Código recibido en tu móvil',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryDark),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'El código fue registrado automáticamente y de forma segura.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppColors.grey500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXXL),
                // Campo solo lectura y oculto — el usuario nunca ve el número
                AbsorbPointer(
                  child: TextField(
                    controller: _tokenController,
                    obscureText: true,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Código de seguridad',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMD)),
                      counterText: '',
                      suffixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.primary),
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingPage,
            0,
            AppDimensions.paddingPage,
            AppDimensions.spaceLG,
          ),
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (_tokenController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'El código no fue recibido. Regresa e inténtalo.')),
                      );
                      return;
                    }
                    context
                        .read<TransferBloc>()
                        .add(SubmitTransfer(_tokenController.text.trim()));
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Confirmar transferencia',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ── Step 4: Éxito con datos y 2 botones ──────────────────────────────────
  Widget _buildStepSuccess(BuildContext context, TransferState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingPage),
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.spaceLG),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 60,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXL),
          const Text(
            '¡Transferencia realizada!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          const Text(
            'Tu dinero fue enviado exitosamente.',
            style: TextStyle(color: AppColors.grey500, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceXXL),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingPage,
                vertical: AppDimensions.spaceLG),
            decoration: BoxDecoration(
              color: AppColors.grey200.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            ),
            child: Column(
              children: [
                _buildReviewRow(Icons.attach_money, 'Monto enviado',
                    CurrencyFormatter.format(state.amount),
                    valueStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success)),
                const Divider(height: AppDimensions.spaceLG),
                _buildReviewRow(Icons.account_balance_wallet_outlined,
                    'Cuenta origen', state.sourceAccount?.alias ?? '-'),
                const Divider(height: AppDimensions.spaceLG),
                _buildReviewRow(Icons.person_outline, 'Destinatario',
                    state.destinationAccountName ?? 'Cuenta verificada'),
                if (state.destinationBankName != null) ...[
                  const Divider(height: AppDimensions.spaceLG),
                  _buildReviewRow(Icons.account_balance_outlined, 'Banco',
                      state.destinationBankName!),
                ],
                const Divider(height: AppDimensions.spaceLG),
                _buildReviewRow(Icons.credit_card_outlined, 'Cuenta destino',
                    _formatAccountDisplay(state.destinationAccount ?? '')),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXXL),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<TransferBloc>().add(const ResetTransfer());
                    _tokenController.clear();
                    _accountController.clear();
                    _amountController.clear();
                    setState(() {
                      _currentStep = 0;
                      _selectedSourceAccountId = null;
                    });
                    _pageController.jumpToPage(0);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Nueva\ntransferencia',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Finalizar',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceLG),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildReviewRow(IconData icon, String label, String value,
      {TextStyle? valueStyle}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppDimensions.spaceMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.grey500)),
              Text(value,
                  style: valueStyle ??
                      const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAccountDisplay(String account) {
    if (account.length < 8) return account;
    return '**** **** **** ${account.substring(account.length - 4)}';
  }
}
