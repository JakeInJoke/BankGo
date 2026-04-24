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
  final DateTime createdAt;
  final bool isRead;

  const NotificationItem({
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationItem copyWithRead() => NotificationItem(
        title: title,
        message: message,
        type: type,
        createdAt: createdAt,
        isRead: true,
      );

  @override
  List<Object?> get props => [title, message, type, createdAt, isRead];
}

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class SimulationEvent extends Equatable {
  const SimulationEvent();
  @override
  List<Object> get props => [];
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

  const AddUserActionNotification({
    required this.title,
    required this.message,
    required this.type,
  });

  @override
  List<Object> get props => [title, message, type];
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
  Timer? _timer;

  SimulationBloc() : super(const SimulationState()) {
    on<StartSimulation>((event, emit) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
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
        createdAt: DateTime.now(),
      );
      emit(state.copyWith(notifications: [item, ...state.notifications]));
    });

    on<_SimulatePurchase>((event, emit) {
      if (!MockBankApi.isAnyCardEnabled) {
        final notification = NotificationItem(
          title: 'Intento de compra bloqueado',
          message: 'Se realizó un intento de compra con una tarjeta apagada.',
          type: NotificationType.purchase,
          createdAt: DateTime.now(),
        );
        emit(state.copyWith(
          isBlockedAttempt: true,
          message: 'Se realizó un intento de compra con una tarjeta apagada.',
          notifications: [notification, ...state.notifications],
        ));
        Future.delayed(const Duration(seconds: 2), () {
          add(ClearBlockedAttempt());
        });
      } else {
        emit(state.copyWith(isBlockedAttempt: false));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
