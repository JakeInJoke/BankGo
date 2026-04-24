abstract class SimulationRepository {
  List<String> get demoAccountIds;

  bool isCardEnabledForAccount(String accountId);
}
