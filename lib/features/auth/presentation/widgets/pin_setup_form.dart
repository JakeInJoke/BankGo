import 'package:flutter/material.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';
import 'package:bank_go/core/constants/app_strings.dart';
import 'package:bank_go/features/auth/presentation/widgets/secure_numeric_keypad.dart';

import 'package:bank_go/features/auth/presentation/widgets/pin_indicator.dart';

class PinSetupForm extends StatefulWidget {
  final Function(String) onPinSet;

  const PinSetupForm({super.key, required this.onPinSet});

  @override
  State<PinSetupForm> createState() => _PinSetupFormState();
}

class _PinSetupFormState extends State<PinSetupForm> {
  String _pin = "";
  final int _pinLength = 6;
  bool _isConfirming = false;
  String _firstPin = "";

  void _onDigitPressed(String digit) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += digit;
      });
      if (_pin.length == _pinLength) {
        _handlePinCompletion();
      }
    }
  }

  void _handlePinCompletion() {
    if (!_isConfirming) {
      setState(() {
        _firstPin = _pin;
        _pin = "";
        _isConfirming = true;
      });
    } else {
      if (_pin == _firstPin) {
        widget.onPinSet(_pin);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Los PINs no coinciden. Intenta de nuevo."),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _pin = "";
          _firstPin = "";
          _isConfirming = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isConfirming ? "Confirma tu nuevo PIN" : "Crea tu PIN de 6 dígitos",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Text(
          _isConfirming
              ? "Ingresa el mismo código para confirmar"
              : "Este código se usará para tus próximos ingresos",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
              ),
        ),
        const SizedBox(height: AppDimensions.spaceXXL),
        Center(
          child: PinIndicator(
            length: _pinLength,
            filledCount: _pin.length,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXXL),
        SecureNumericKeypad(
          onDigitPressed: _onDigitPressed,
          onDeletePressed: _onDeletePressed,
          onClearPressed: _onClearPressed,
        ),
        const SizedBox(height: AppDimensions.spaceLG),
        if (!_isConfirming)
          TextButton(
            onPressed: () => widget.onPinSet(""), // Skip
            child: const Text(AppStrings.cancel),
          ),
      ],
    );
  }
}
