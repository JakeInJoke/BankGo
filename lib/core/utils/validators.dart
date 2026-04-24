class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
  );

  /// Returns an error message or null if valid.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Este campo es requerido';
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'La contraseña debe incluir mayúsculas, minúsculas, números y caracteres especiales';
    }
    return null;
  }

  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es requerido';
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) return 'Ingresa un monto válido';
    if (amount <= 0) return 'El monto debe ser mayor a cero';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'El teléfono es requerido';
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Ingresa un número de teléfono válido';
    }
    return null;
  }

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email.trim());
  static bool isValidPassword(String password) => _passwordRegex.hasMatch(password);
}
