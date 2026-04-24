import 'package:equatable/equatable.dart';

abstract class CardEvent extends Equatable {
  const CardEvent();

  @override
  List<Object> get props => [];
}

class LoadCardDetails extends CardEvent {
  final String accountId;
  const LoadCardDetails(this.accountId);
}

class ToggleCardFreeze extends CardEvent {
  final String accountId;
  final bool freeze;
  final String token;
  const ToggleCardFreeze(this.accountId, this.freeze, this.token);

  @override
  List<Object> get props => [accountId, freeze, token];
}

class ShowSensitiveInfo extends CardEvent {
  final String accountId;
  final String token;
  const ShowSensitiveInfo(this.accountId, this.token);

  @override
  List<Object> get props => [accountId, token];
}

class HideSensitiveInfo extends CardEvent {
  const HideSensitiveInfo();
}

class TickCVVTimer extends CardEvent {
  const TickCVVTimer();
}

class RequestFreezeToken extends CardEvent {
  final String accountId;
  const RequestFreezeToken(this.accountId);

  @override
  List<Object> get props => [accountId];
}
