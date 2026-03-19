import 'dart:async';
import 'package:flutter/material.dart';

/// Simulates mesh connectivity, GPS signal, and transmission status
/// for the Vanguard Crisis Response Network app.
class ConnectivityStatusService extends ChangeNotifier {
  static final ConnectivityStatusService _instance =
      ConnectivityStatusService._internal();
  factory ConnectivityStatusService() => _instance;
  ConnectivityStatusService._internal() {
    _startSimulation();
  }

  // --- State ---
  MeshStatus _meshStatus = MeshStatus.connecting;
  GpsStatus _gpsStatus = GpsStatus.acquiring;
  TransmissionStatus _transmissionStatus = TransmissionStatus.idle;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  MeshStatus get meshStatus => _meshStatus;
  GpsStatus get gpsStatus => _gpsStatus;
  TransmissionStatus get transmissionStatus => _transmissionStatus;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Timer? _simulationTimer;

  void _startSimulation() {
    // Simulate initial connecting state
    _isLoading = true;
    _meshStatus = MeshStatus.connecting;
    _gpsStatus = GpsStatus.acquiring;
    _transmissionStatus = TransmissionStatus.idle;

    // After 2s, transition to connected
    _simulationTimer = Timer(const Duration(seconds: 2), () {
      _isLoading = false;
      _meshStatus = MeshStatus.connected;
      _gpsStatus = GpsStatus.locked;
      _transmissionStatus = TransmissionStatus.idle;
      _errorMessage = null;
      notifyListeners();
    });
  }

  /// Simulate a transmission attempt (e.g., SOS send)
  Future<bool> simulateTransmission() async {
    _transmissionStatus = TransmissionStatus.transmitting;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    // Simulate occasional failure
    final success = DateTime.now().second % 5 != 0;
    if (success) {
      _transmissionStatus = TransmissionStatus.success;
    } else {
      _transmissionStatus = TransmissionStatus.failed;
      _errorMessage = 'Transmission failed: No relay nodes in range.';
    }
    notifyListeners();

    // Reset after 3s
    Future.delayed(const Duration(seconds: 3), () {
      _transmissionStatus = TransmissionStatus.idle;
      _errorMessage = null;
      notifyListeners();
    });

    return success;
  }

  /// Simulate mesh disconnection
  void simulateMeshDisconnect() {
    _meshStatus = MeshStatus.disconnected;
    _errorMessage = 'Mesh network unreachable. Retrying...';
    notifyListeners();

    Future.delayed(const Duration(seconds: 3), () {
      _meshStatus = MeshStatus.connecting;
      notifyListeners();
      Future.delayed(const Duration(seconds: 2), () {
        _meshStatus = MeshStatus.connected;
        _errorMessage = null;
        notifyListeners();
      });
    });
  }

  /// Simulate GPS signal loss
  void simulateGpsLoss() {
    _gpsStatus = GpsStatus.lost;
    _errorMessage = 'GPS signal lost. Searching for satellites...';
    notifyListeners();

    Future.delayed(const Duration(seconds: 4), () {
      _gpsStatus = GpsStatus.acquiring;
      notifyListeners();
      Future.delayed(const Duration(seconds: 2), () {
        _gpsStatus = GpsStatus.locked;
        _errorMessage = null;
        notifyListeners();
      });
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

enum MeshStatus { connecting, connected, disconnected }

enum GpsStatus { acquiring, locked, lost }

enum TransmissionStatus { idle, transmitting, success, failed }
