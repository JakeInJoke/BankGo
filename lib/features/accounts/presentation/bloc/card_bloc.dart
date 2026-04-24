import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_event.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  final MockBankApi _api;
  final NetworkInfo _networkInfo;
  Timer? _cvvTimer;

  CardBloc(this._api, this._networkInfo) : super(const CardState()) {
    on<LoadCardDetails>(_onLoadCardDetails);
    on<ToggleCardFreeze>(_onToggleCardFreeze);
    on<ShowSensitiveInfo>(_onShowSensitiveInfo);
    on<HideSensitiveInfo>(_onHideSensitiveInfo);
    on<TickCVVTimer>(_onTickCVVTimer);
    on<RequestFreezeToken>(_onRequestFreezeToken);
  }

  Future<void> _onLoadCardDetails(
      LoadCardDetails event, Emitter<CardState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final details = await _api.getCardDetails(event.accountId);
      emit(state.copyWith(
        isLoading: false,
        cardNumber: details['card_number'] as String?,
        expirationDate: details['expiration_date'] as String?,
        isFrozen: !(details['is_enabled'] as bool? ?? true),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRequestFreezeToken(
      RequestFreezeToken event, Emitter<CardState> emit) async {
    if (!await _networkInfo.isConnected) {
      emit(state.copyWith(
        error: 'Sin conexión a internet. No se puede solicitar el token.',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final token = await _api.requestSecurityToken(accountId: event.accountId);
      emit(state.copyWith(isLoading: false, securityToken: token));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onToggleCardFreeze(
      ToggleCardFreeze event, Emitter<CardState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _api.toggleCardFreeze(
        accountId: event.accountId,
        freeze: event.freeze,
        token: event.token,
      );
      emit(state.copyWith(
          isLoading: false, isFrozen: event.freeze, securityToken: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onShowSensitiveInfo(
      ShowSensitiveInfo event, Emitter<CardState> emit) async {
    final token = event.token.trim();
    if (token.isEmpty ||
        state.securityToken == null ||
        token != state.securityToken) {
      emit(state.copyWith(
        error: 'Token de seguridad inválido o expirado.',
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final details = await _api.getCardDetails(event.accountId);
      emit(state.copyWith(
        isLoading: false,
        isSensitiveVisible: true,
        cvv: details['cvv'] as String?,
        remainingSeconds: 180,
        securityToken: null,
      ));
      _cvvTimer?.cancel();
      _cvvTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(const TickCVVTimer());
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onHideSensitiveInfo(HideSensitiveInfo event, Emitter<CardState> emit) {
    _cvvTimer?.cancel();
    emit(state.copyWith(
      isSensitiveVisible: false,
      cvv: null,
      remainingSeconds: 0,
    ));
  }

  void _onTickCVVTimer(TickCVVTimer event, Emitter<CardState> emit) {
    if (state.remainingSeconds > 1) {
      emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
    } else {
      add(const HideSensitiveInfo());
    }
  }

  @override
  Future<void> close() {
    _cvvTimer?.cancel();
    return super.close();
  }
}
