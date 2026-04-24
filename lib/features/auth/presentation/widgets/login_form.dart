import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_event.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_state.dart';
import 'package:bank_go/features/auth/presentation/widgets/secure_numeric_keypad.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String _pin = "";
  final int _pinLength = 6;

  void _onDigitPressed(String digit) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += digit;
      });
      if (_pin.length == _pinLength) {
        _onSubmit();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _onClearPressed() {
    setState(() {
      _pin = "";
    });
  }

  void _onSubmit() {
    if (_pin.length == _pinLength) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: "user@bankgo.com", // Simulated for backward compatibility
              password: _pin,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pinLength, (index) {
              bool isFilled = index < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppColors.primary : AppColors.grey200,
                  border: Border.all(
                    color: isFilled ? AppColors.primary : AppColors.grey300,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXXL),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.spaceLG),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return SecureNumericKeypad(
              onDigitPressed: _onDigitPressed,
              onDeletePressed: _onDeletePressed,
              onClearPressed: _onClearPressed,
            );
          },
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: () {},
            child: const Text(AppStrings.forgotPassword),
          ),
        ),
      ],
    );
  }
}
