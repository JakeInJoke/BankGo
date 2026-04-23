import '../../domain/entities/recent_transaction.dart';

class RecentTransactionModel extends RecentTransaction {
  const RecentTransactionModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.amount,
    required super.type,
    required super.date,
    super.iconName,
  });

  factory RecentTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecentTransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      date: DateTime.parse(json['date'] as String),
      iconName: json['icon_name'] as String?,
    );
  }

  /// Placeholder data list for UI development.
  static List<RecentTransactionModel> placeholders() {
    final now = DateTime.now();
    return [
      RecentTransactionModel(
        id: '1',
        title: 'Salario mensual',
        subtitle: 'Empresa XYZ',
        amount: 15000.00,
        type: TransactionType.income,
        date: now.subtract(const Duration(hours: 2)),
      ),
      RecentTransactionModel(
        id: '2',
        title: 'Supermercado',
        subtitle: 'Walmart',
        amount: -850.50,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 1)),
      ),
      RecentTransactionModel(
        id: '3',
        title: 'Transferencia enviada',
        subtitle: 'A: Juan Pérez',
        amount: -2000.00,
        type: TransactionType.transfer,
        date: now.subtract(const Duration(days: 2)),
      ),
      RecentTransactionModel(
        id: '4',
        title: 'Netflix',
        subtitle: 'Suscripción mensual',
        amount: -219.00,
        type: TransactionType.expense,
        date: now.subtract(const Duration(days: 3)),
      ),
      RecentTransactionModel(
        id: '5',
        title: 'Pago recibido',
        subtitle: 'De: María García',
        amount: 500.00,
        type: TransactionType.income,
        date: now.subtract(const Duration(days: 4)),
      ),
    ];
  }
}
