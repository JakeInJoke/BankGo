import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:bank_go/core/mocks/mock_bank_api.dart';

// ─── Domain types ────────────────────────────────────────────────────────────

enum NotificationType { security, purchase, info }

class NotificationItem extends Equatable {
  final String title;
  final String message;
  final NotificationType type;
  final double? amount;
  final DateTime createdAt;
  final bool isRead;

  const NotificationItem({
    required this.title,
    required this.message,
    required this.type,
    this.amount,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationItem copyWithRead() => NotificationItem(
        title: title,
        message: message,
        type: type,
        amount: amount,
        createdAt: createdAt,
        isRead: true,
      );

  @override
  List<Object?> get props => [title, message, type, amount, createdAt, isRead];
}

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class SimulationEvent extends Equatable {
  const SimulationEvent();
  @override
  List<Object?> get props => [];
}

class StartSimulation extends SimulationEvent {}

class StopSimulation extends SimulationEvent {}

class ClearBlockedAttempt extends SimulationEvent {}

class _SimulatePurchase extends SimulationEvent {}

class MarkNotificationsAsRead extends SimulationEvent {}

class AddUserActionNotification extends SimulationEvent {
  final String title;
  final String message;
  final NotificationType type;
  final double? amount;

  const AddUserActionNotification({
    required this.title,
    required this.message,
    required this.type,
    this.amount,
  });

  @override
  List<Object?> get props => [title, message, type, amount];
}

// ─── State ───────────────────────────────────────────────────────────────────

class SimulationState extends Equatable {
  final bool isBlockedAttempt;
  final String? message;
  final List<NotificationItem> notifications;

  const SimulationState({
    this.isBlockedAttempt = false,
    this.message,
    this.notifications = const [],
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  SimulationState copyWith({
    bool? isBlockedAttempt,
    String? message,
    List<NotificationItem>? notifications,
  }) =>
      SimulationState(
        isBlockedAttempt: isBlockedAttempt ?? this.isBlockedAttempt,
        message: message ?? this.message,
        notifications: notifications ?? this.notifications,
      );

  @override
  List<Object?> get props => [isBlockedAttempt, message, notifications];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class SimulationBloc extends Bloc<SimulationEvent, SimulationState> {
  final MockBankApi _api;
  Timer? _timer;
  int _currentCardIndex = 0;

  static const List<String> _cardAccountIds = ['1', '2', '3'];
  static const Map<String, String> _cardAliases = {
    '1': 'Cuenta Principal',
    '2': 'Cuenta Corriente',
    '3': 'Tarjeta de Crédito',
  };

  SimulationBloc(this._api) : super(const SimulationState()) {
    on<StartSimulation>((event, emit) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
        add(_SimulatePurchase());
      });
    });

    on<StopSimulation>((event, emit) {
      _timer?.cancel();
    });

    on<ClearBlockedAttempt>((event, emit) {
      emit(state.copyWith(isBlockedAttempt: false));
    });

    on<MarkNotificationsAsRead>((event, emit) {
      emit(state.copyWith(
        notifications:
            state.notifications.map((n) => n.copyWithRead()).toList(),
      ));
    });

    on<AddUserActionNotification>((event, emit) {
      final item = NotificationItem(
        title: event.title,
        message: event.message,
        type: event.type,
        amount: event.amount,
        createdAt: DateTime.now(),
      );
      emit(state.copyWith(notifications: [item, ...state.notifications]));
    });

    on<_SimulatePurchase>((event, emit) async {
      final accountId =
          _cardAccountIds[_currentCardIndex % _cardAccountIds.length];
      _currentCardIndex = (_currentCardIndex + 1) % _cardAccountIds.length;
      final alias = _cardAliases[accountId] ?? 'Tarjeta';

      if (!MockBankApi.isCardEnabledForAccount(accountId)) {
        final notification = NotificationItem(
          title: 'Compra bloqueada',
          message:
              'Intento de compra en $alias fue bloqueado. La tarjeta está desactivada.',
          type: NotificationType.purchase,
          createdAt: DateTime.now(),
        );
        emit(state.copyWith(
          isBlockedAttempt: true,
          message: 'Compra bloqueada en $alias (tarjeta desactivada).',
          notifications: [notification, ...state.notifications],
        ));
        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) add(ClearBlockedAttempt());
        });
      } else {
        try {
          final amount = 5 + (DateTime.now().millisecond % 6); // 5..10
          await _api.simulateCardPurchase(
            accountId: accountId,
            amount: amount.toDouble(),
          );

          final notification = NotificationItem(
            title: 'Compra realizada',
            message: 'Compra exitosa en $alias por S/ $amount.00.',
            type: NotificationType.purchase,
            amount: amount.toDouble(),
            createdAt: DateTime.now(),
          );
          emit(state.copyWith(
            isBlockedAttempt: false,
            notifications: [notification, ...state.notifications],
          ));
        } catch (_) {
          final notification = NotificationItem(
            title: 'Compra rechazada',
            message:
                'No se pudo procesar compra en $alias por saldo/línea insuficiente.',
            type: NotificationType.purchase,
            createdAt: DateTime.now(),
          );
          emit(state.copyWith(
            isBlockedAttempt: true,
            message: 'Compra rechazada en $alias por saldo insuficiente.',
            notifications: [notification, ...state.notifications],
          ));
          Future.delayed(const Duration(seconds: 2), () {
            if (!isClosed) add(ClearBlockedAttempt());
          });
        }
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
