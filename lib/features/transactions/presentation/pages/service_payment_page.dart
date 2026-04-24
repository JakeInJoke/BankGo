import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';
import 'package:bank_go/features/accounts/data/models/account_model.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/injection_container.dart';

class ServicePaymentPage extends StatefulWidget {
  final String? initialService;

  const ServicePaymentPage({
    super.key,
    this.initialService,
  });

  @override
  State<ServicePaymentPage> createState() => _ServicePaymentPageState();
}

class _ServicePaymentPageState extends State<ServicePaymentPage> {
  String? _selectedService;
  String? _selectedAccountId;
  final TextEditingController _amountController = TextEditingController();
  List<AccountModel> _accounts = const [];
  bool _isLoadingAccounts = true;
  bool _isLoading = false;

  final List<String> _services = [
    'Luz (CFE)',
    'Agua (SACMEX)',
    'Internet (Telmex)',
    'Gas (Naturgy)'
  ];

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService;
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    try {
      final response = await sl<MockBankApi>().getAccounts();
      _accounts = response.map(AccountModel.fromJson).toList();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAccounts = false;
        });
      }
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedService == null ||
        _selectedAccountId == null ||
        _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa todos los campos')));
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto válido')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = sl<MockBankApi>();
      await api.processServicePayment(
        serviceName: _selectedService!,
        amount: amount,
        sourceAccountId: _selectedAccountId!,
      );
      if (mounted) {
        context.read<SimulationBloc>().add(
              AddUserActionNotification(
                title: 'Pago realizado',
                message:
                    'Pago de ${CurrencyFormatter.format(amount)} a $_selectedService procesado.',
                type: NotificationType.info,
                amount: amount,
              ),
            );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago de Servicios')),
      body: _isLoadingAccounts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingPage),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_accounts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: AppDimensions.spaceMD),
                      child: Text(
                          'No hay cuentas disponibles para pagar servicios.'),
                    ),
                  const Text('Selecciona el servicio',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedService,
                    items: _services
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedService = val),
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  const Text('Cuenta de origen',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAccountId,
                    items: _accounts
                        .map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.type == AccountType.credit
                                ? '${a.alias} (Disponible: ${CurrencyFormatter.format(a.remainingCredit)})'
                                : '${a.alias} (${CurrencyFormatter.format(a.balance)})')))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedAccountId = val),
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 24),
                  const Text('Monto a pagar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                    ],
                    decoration: const InputDecoration(
                        prefixText: '\$', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handlePayment,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16)),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Realizar Pago'),
                  ),
                ],
              ),
            ),
    );
  }
}
