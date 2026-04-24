import 'package:flutter_test/flutter_test.dart';

import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_bloc.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_event.dart';

class _FakeNetworkInfo implements NetworkInfo {
  final bool connected;

  _FakeNetworkInfo(this.connected);

  @override
  Future<bool> get isConnected async => connected;
}

void main() {
  group('CardBloc', () {
    late CardBloc bloc;

    setUp(() {
      MockBankApi.resetState();
      bloc = CardBloc(const MockBankApi(), _FakeNetworkInfo(true));
    });

    tearDown(() async {
      await bloc.close();
    });

    test('permite ver información sensible con token válido', () async {
      bloc.add(const RequestFreezeToken('1'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final token = bloc.state.securityToken;

      expect(token, isNotNull);

      bloc.add(ShowSensitiveInfo('1', token!));
      await Future<void>.delayed(const Duration(milliseconds: 700));

      expect(bloc.state.isSensitiveVisible, isTrue);
      expect(bloc.state.cvv, isNotNull);
      expect(bloc.state.remainingSeconds, 180);
    });

    test('rechaza intento de interceptar información con token inválido',
        () async {
      bloc.add(const RequestFreezeToken('1'));
      await Future<void>.delayed(const Duration(milliseconds: 500));

      bloc.add(const ShowSensitiveInfo('1', '000000'));
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.isSensitiveVisible, isFalse);
      expect(bloc.state.error, contains('Token de seguridad inválido'));
    });

    test('la sesión sensible decrementa el contador y no se queda en espera',
        () async {
      bloc.add(const RequestFreezeToken('1'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final token = bloc.state.securityToken!;

      bloc.add(ShowSensitiveInfo('1', token));
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final before = bloc.state.remainingSeconds;

      bloc.add(const TickCVVTimer());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.remainingSeconds, before - 1);
    });

    test('oculta información sensible al vencer la sesión', () async {
      bloc.add(const RequestFreezeToken('1'));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final token = bloc.state.securityToken!;

      bloc.add(ShowSensitiveInfo('1', token));
      await Future<void>.delayed(const Duration(milliseconds: 700));

      for (var i = 0; i < 180; i++) {
        bloc.add(const TickCVVTimer());
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.isSensitiveVisible, isFalse);
      expect(bloc.state.remainingSeconds, 0);
    });
  });
}
