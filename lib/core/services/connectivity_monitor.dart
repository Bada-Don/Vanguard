import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

enum ConnectivityStatus {
  none,
  wifi,
  cellular,
  ethernet,
  other
}

class ConnectivityMonitor {
  final Connectivity _connectivity;
  final Logger _logger;
  
  final StreamController<ConnectivityStatus> _statusController = 
      StreamController<ConnectivityStatus>.broadcast();
  
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  ConnectivityStatus _currentStatus = ConnectivityStatus.none;

  ConnectivityMonitor({
    Connectivity? connectivity,
    Logger? logger,
  })  : _connectivity = connectivity ?? Connectivity(),
        _logger = logger ?? Logger();

  Stream<ConnectivityStatus> get connectivityStream => _statusController.stream;
  ConnectivityStatus get currentStatus => _currentStatus;

  Future<void> initialize() async {
    await checkConnectivity();
  }

  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      _logger.e('Failed to check connectivity: $e');
    }
    return _currentStatus;
  }

  void startMonitoring() {
    _logger.i('Starting connectivity monitoring');
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void stopMonitoring() {
    _logger.i('Stopping connectivity monitoring');
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    ConnectivityStatus newStatus = ConnectivityStatus.none;

    if (results.contains(ConnectivityResult.wifi)) {
      newStatus = ConnectivityStatus.wifi;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      newStatus = ConnectivityStatus.ethernet;
    } else if (results.contains(ConnectivityResult.mobile)) {
      newStatus = ConnectivityStatus.cellular;
    } else if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
      newStatus = ConnectivityStatus.other;
    }

    if (_currentStatus != newStatus) {
      _logger.i('Connectivity changed from $_currentStatus to $newStatus');
      _currentStatus = newStatus;
      _statusController.add(_currentStatus);
    }
  }

  Future<void> dispose() async {
    stopMonitoring();
    await _statusController.close();
  }
}
