abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // In production, integrate connectivity_plus package:
    // final connectivityResult = await Connectivity().checkConnectivity();
    // return connectivityResult != ConnectivityResult.none;
    return true;
  }
}
