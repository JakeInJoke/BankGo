import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/dashboard/domain/repositories/simulation_repository.dart';

class SimulationRepositoryImpl implements SimulationRepository {
  const SimulationRepositoryImpl();

  @override
  List<String> get demoAccountIds => MockBankApi.demoAccountIds;

  @override
  bool isCardEnabledForAccount(String accountId) {
    return MockBankApi.isCardEnabledForAccount(accountId);
  }
}
