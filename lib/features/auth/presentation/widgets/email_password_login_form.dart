import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_event.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_state.dart';

class EmailPasswordLoginForm extends StatefulWidget {
  const EmailPasswordLoginForm({super.key});

  @override
  State<EmailPasswordLoginForm> createState() => _EmailPasswordLoginFormState();
}

class _EmailPasswordLoginFormState extends State<EmailPasswordLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _dniController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              dni: _dniController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _dniController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: AppStrings.dniLabel,
              hintText: AppStrings.dniHint,
              prefixIcon: const Icon(Icons.badge_outlined),
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.fieldRequired;
              }
              if (value.length != 8 || !RegExp(r'^\d{8}$').hasMatch(value)) {
                return AppStrings.invalidDni;
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: AppStrings.passwordLabel,
              hintText: AppStrings.passwordHint,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey500,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.fieldRequired;
              }
              if (value.length < 8) {
                return AppStrings.passwordTooShort;
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spaceXS),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(AppStrings.forgotPassword),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceLG),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              bool isLoading = state is AuthLoading;
              return ElevatedButton(
                onPressed: isLoading ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spaceMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  elevation: 2,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : const Text(
                        AppStrings.loginButton,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spaceXL),
        ],
      ),
    );
  }
}
