import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/accounts/data/models/account_model.dart';
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
          _accounts = response.map(AccountModel.fromJson).toList();
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
            if (state.status == TransferStatus.accountValid &&
                _currentStep == 0) {
              _nextPage();
            } else if (state.status == TransferStatus.tokenRequested &&
                _currentStep == 1) {
              _nextPage();
            } else if (state.status == TransferStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transferencia exitosa')),
              );
              Navigator.pop(context);
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
        children: List.generate(3, (index) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
        vertical: AppDimensions.spaceLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('¿A quién deseas transferir?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              hintText: '0000 0000 0000 0000',
            ),
            keyboardType: TextInputType.number,
            maxLength: 16,
          ),
          const Spacer(),
          ElevatedButton(
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
        ],
      ),
    );
  }

  Widget _buildStep2(BuildContext context, TransferState state) {
    if (_isLoadingAccounts) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
        vertical: AppDimensions.spaceLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Detalles del envío',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppDimensions.spaceXXL),
          const Text('Cuenta de origen',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppDimensions.spaceSM),
          DropdownButtonFormField<String>(
            initialValue: _selectedSourceAccountId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
              contentPadding: const EdgeInsets.all(16),
            ),
            hint: const Text('Selecciona una cuenta'),
            items: _accounts
                .map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text(
                        '${a.alias} (${CurrencyFormatter.format(a.balance)})')))
                .toList(),
            onChanged: (val) => setState(() => _selectedSourceAccountId = val),
          ),
          const SizedBox(height: AppDimensions.spaceXL),
          const Text('Monto a transferir',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
              hintText: '0.00',
            ),
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const Spacer(),
          ElevatedButton(
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
              context
                  .read<TransferBloc>()
                  .add(UpdateTransferDetails(account, amount));
              context.read<TransferBloc>().add(const RequestToken());
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Continuar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(BuildContext context, TransferState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingPage,
        vertical: AppDimensions.spaceLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Verificación Final',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppDimensions.spaceXL),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.security_rounded,
                    color: AppColors.primary, size: 48),
                const SizedBox(height: 16),
                const Text('Se ha enviado un token a tu móvil registrado:',
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(state.securityToken ?? "...",
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: AppColors.primaryDark)),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXXL),
          TextField(
            controller: _tokenController,
            decoration: InputDecoration(
              labelText: 'Ingresa el token',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
              counterText: '',
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: const TextStyle(
                fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              context
                  .read<TransferBloc>()
                  .add(SubmitTransfer(_tokenController.text));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Confirmar Transferencia',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
