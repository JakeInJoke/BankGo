import 'package:flutter/material.dart';
import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/constants/app_dimensions.dart';

class SecureNumericKeypad extends StatefulWidget {
  final Function(String) onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onClearPressed;

  const SecureNumericKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onDeletePressed,
    required this.onClearPressed,
  });

  @override
  State<SecureNumericKeypad> createState() => _SecureNumericKeypadState();
}

class _SecureNumericKeypadState extends State<SecureNumericKeypad> {
  late List<int> _digits;

  @override
  void initState() {
    super.initState();
    _shuffleDigits();
  }

  void _shuffleDigits() {
    _digits = List.generate(10, (index) => index);
    _digits.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceSM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var j = 0; j < 3; j++)
                  _buildKey(_digits[i * 3 + j].toString()),
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionKey(Icons.backspace_outlined, widget.onDeletePressed),
            _buildKey(_digits[9].toString()),
            _buildActionKey(Icons.refresh, () {
              setState(() {
                _shuffleDigits();
              });
              widget.onClearPressed();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String digit) {
    return InkWell(
      onTap: () => widget.onDigitPressed(digit),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.grey900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Icon(
          icon,
          color: AppColors.grey700,
        ),
      ),
    );
  }
}
