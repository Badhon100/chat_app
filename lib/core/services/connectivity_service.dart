import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();

  Stream<bool> get connectionStream => _connectivity.onConnectivityChanged.map(
    (r) => r != ConnectivityResult.none,
  );

  Future<bool> get isOnline async =>
      await _connectivity.checkConnectivity() != ConnectivityResult.none;
}
