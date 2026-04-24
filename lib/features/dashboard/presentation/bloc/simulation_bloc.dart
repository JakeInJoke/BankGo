import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:bank_go/core/mocks/mock_bank_api.dart';

abstract class SimulationEvent extends Equatable {
  const SimulationEvent();
  @override
  List<Object> get props => [];
}

class StartSimulation extends SimulationEvent {}

class StopSimulation extends SimulationEvent {}

class ClearBlockedAttempt extends SimulationEvent {}

class MarkNotificationsAsRead extends SimulationEvent {}

class AddUserActionNotification extends SimulationEvent {
  final String title;
  final String message;
  final NotificationType type;

  const AddUserActionNotification({
    required this.title,
    required this.message,
    this.type = NotificationType.info,
  });

  @override
  List<Object> get props => [title, message, type];
}

class _SimulatePurchase extends SimulationEvent {}

class SimulationState extends Equatable {
  final bool hasBlockedAttempt;
  final String? latestMessage;
  final List<InAppNotificationItem> notifications;
  final int unreadCount;

  const SimulationState({
    this.hasBlockedAttempt = false,
    this.latestMessage,
    this.notifications = const [],
    this.unreadCount = 0,
  });

  SimulationState copyWith({
    bool? hasBlockedAttempt,
    String? latestMessage,
    List<InAppNotificationItem>? notifications,
    int? unreadCount,
  }) {
    return SimulationState(
      hasBlockedAttempt: hasBlockedAttempt ?? this.hasBlockedAttempt,
      latestMessage: latestMessage,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        hasBlockedAttempt,
        latestMessage,
        notifications,
        unreadCount,
      ];
}

class SimulationBloc extends Bloc<SimulationEvent, SimulationState> {
  Timer? _timer;
  int _tick = 0;

  SimulationBloc() : super(const SimulationState()) {
    on<StartSimulation>((event, emit) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
        add(_SimulatePurchase());
      });
    });

    on<StopSimulation>((event, emit) {
      _timer?.cancel();
    });

    on<ClearBlockedAttempt>((event, emit) {
      emit(state.copyWith(hasBlockedAttempt: false, latestMessage: null));
    });

    on<MarkNotificationsAsRead>((event, emit) {
      emit(state.copyWith(unreadCount: 0));
    });

    on<AddUserActionNotification>((event, emit) {
      final newNotification = InAppNotificationItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: event.title,
        message: event.message,
        createdAt: DateTime.now(),
        type: event.type,
      );
      emit(state.copyWith(
        notifications: [newNotification, ...state.notifications],
        unreadCount: state.unreadCount + 1,
      ));
    });

    on<_SimulatePurchase>((event, emit) {
      final accountId =
          MockBankApi.demoAccountIds[_tick % MockBankApi.demoAccountIds.length];
      _tick += 1;

      if (!MockBankApi.isCardEnabledForAccount(accountId)) {
        final message =
            'Intento de compra bloqueado en la tarjeta de la cuenta $accountId.';
        final updatedNotifications = [
          InAppNotificationItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: 'Compra bloqueada',
            message: message,
            createdAt: DateTime.now(),
            type: NotificationType.security,
          ),
          ...state.notifications,
        ];

        emit(state.copyWith(
          hasBlockedAttempt: true,
          latestMessage: message,
          notifications: updatedNotifications,
          unreadCount: state.unreadCount + 1,
        ));

        Future.delayed(const Duration(seconds: 2), () {
          add(ClearBlockedAttempt());
        });
      } else {
        emit(state.copyWith(hasBlockedAttempt: false, latestMessage: null));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

enum NotificationType { security, purchase, info }

class InAppNotificationItem extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationType type;

  const InAppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, message, createdAt, type];
}
