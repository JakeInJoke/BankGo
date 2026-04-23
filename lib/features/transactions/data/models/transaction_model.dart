import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.amount,
    required super.type,
    required super.status,
    required super.date,
    super.category,
    super.reference,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      status: TransactionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TransactionStatus.completed,
      ),
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String?,
      reference: json['reference'] as String?,
    );
  }

  static List<TransactionModel> placeholders() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: '1',
        title: 'Salario mensual',
        description: 'Depósito de nómina - Empresa XYZ S.A.',
        amount: 15000.00,
        type: TransactionType.income,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(hours: 2)),
        category: 'Nómina',
        reference: 'NOM-2024-001',
      ),
      TransactionModel(
        id: '2',
        title: 'Supermercado Walmart',
        description: 'Compra con tarjeta - Walmart Insurgentes',
        amount: -850.50,
        type: TransactionType.expense,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 1)),
        category: 'Alimentación',
      ),
      TransactionModel(
        id: '3',
        title: 'Transferencia a Juan Pérez',
        description: 'Pago de renta de local',
        amount: -2000.00,
        type: TransactionType.transfer,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 2)),
        reference: 'TRF-20240115-003',
      ),
      TransactionModel(
        id: '4',
        title: 'Netflix',
        description: 'Suscripción mensual Premium',
        amount: -219.00,
        type: TransactionType.expense,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 3)),
        category: 'Entretenimiento',
      ),
      TransactionModel(
        id: '5',
        title: 'Pago recibido',
        description: 'Transferencia de María García',
        amount: 500.00,
        type: TransactionType.income,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 4)),
      ),
      TransactionModel(
        id: '6',
        title: 'CFE - Luz',
        description: 'Pago de servicio eléctrico',
        amount: -450.00,
        type: TransactionType.expense,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 5)),
        category: 'Servicios',
      ),
      TransactionModel(
        id: '7',
        title: 'TELCEL',
        description: 'Recarga de tiempo aire',
        amount: -200.00,
        type: TransactionType.expense,
        status: TransactionStatus.completed,
        date: now.subtract(const Duration(days: 6)),
        category: 'Telecomunicaciones',
      ),
      TransactionModel(
        id: '8',
        title: 'Pago freelance',
        description: 'Proyecto web - Cliente ABC',
        amount: 5000.00,
        type: TransactionType.income,
        status: TransactionStatus.pending,
        date: now.subtract(const Duration(days: 7)),
        reference: 'FRL-2024-008',
      ),
    ];
  }
}
