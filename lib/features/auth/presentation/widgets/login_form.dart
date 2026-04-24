import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_event.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_state.dart';
import 'package:bank_go/features/auth/presentation/widgets/secure_numeric_keypad.dart';

import 'package:bank_go/features/auth/presentation/widgets/pin_indicator.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static const String _demoPin = '123456';

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
    if (_pin.length != _pinLength) {
      return;
    }

    if (_pin != _demoPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN inválido. Usa 123456 para demo.'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() {
        _pin = '';
      });
      return;
    }

    context.read<AuthBloc>().add(
          const AuthLoginRequested(
            dni: MockBankApi.demoDni,
            password: MockBankApi.demoPassword,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: PinIndicator(
            length: _pinLength,
            filledCount: _pin.length,
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
