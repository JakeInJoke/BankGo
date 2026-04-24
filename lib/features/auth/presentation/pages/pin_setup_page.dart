import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/routes/app_router.dart';
import 'package:bank_go/features/auth/presentation/widgets/pin_setup_form.dart';

class PinSetupPage extends StatelessWidget {
  const PinSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.grey900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimensions.paddingPage),
          child: Column(
            children: [
              const SizedBox(height: AppDimensions.spaceLG),
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceLG),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_person_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceXL),
              PinSetupForm(
                onPinSet: (pin) {
                  // Here you would save the PIN locally
                  // For now, let's just go to dashboard
                  Navigator.pushReplacementNamed(context, AppRouter.dashboard);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
