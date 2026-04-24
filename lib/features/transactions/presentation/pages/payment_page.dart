import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.payBills),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccione el servicio a pagar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            // Mock de servicios
            const _ServiceCard(
              icon: Icons.water_drop,
              name: 'Agua',
              color: AppColors.info,
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            const _ServiceCard(
              icon: Icons.electric_bolt,
              name: 'Electricidad',
              color: AppColors.warning,
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            const _ServiceCard(
              icon: Icons.wifi,
              name: 'Internet',
              color: AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            Text(
              'Ingrese los datos de pago',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Número de referencia',
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Monto a pagar',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pago realizado con éxito')),
                  );
                },
                child: const Text('Confirmar Pago'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;

  const _ServiceCard({
    required this.icon,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.grey200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceSM),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(name, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Select service logic
        },
      ),
    );
  }
}
