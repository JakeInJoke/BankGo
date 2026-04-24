import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bank_go/features/accounts/presentation/bloc/card_bloc.dart';

import 'package:bank_go/features/accounts/presentation/bloc/card_state.dart';

class CardActionModal extends StatefulWidget {
  final String accountId;
  final bool isFreezeAction;
  final String title;
  final String description;
  final Function(String token) onConfirm;

  const CardActionModal({
    super.key,
    required this.accountId,
    required this.isFreezeAction,
    required this.title,
    required this.description,
    required this.onConfirm,
  });

  @override
  State<CardActionModal> createState() => _CardActionModalState();
}

class _CardActionModalState extends State<CardActionModal> {
  late final TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardBloc, CardState>(
      listener: (context, state) {
        if (state.securityToken != null &&
            _tokenController.text != state.securityToken) {
          _tokenController.text = state.securityToken!;
        }
        if (state.securityToken == null &&
            !state.isLoading &&
            state.error == null) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(widget.description),
              const SizedBox(height: 8),
              const Text('Código recibido y completado automáticamente.'),
              const SizedBox(height: 24),
              AbsorbPointer(
                child: TextField(
                  controller: _tokenController,
                  obscureText: true,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Token de seguridad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state.isLoading || state.securityToken == null
                    ? null
                    : () => widget.onConfirm(_tokenController.text),
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Confirmar'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
