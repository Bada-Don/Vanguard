import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:vanguard_crisis_response/core/services/connectivity_monitor.dart';

class MockConnectivity extends Fake implements Connectivity {
  final List<ConnectivityResult> currentResult;
  final StreamController<List<ConnectivityResult>> controller = StreamController<List<ConnectivityResult>>.broadcast();

  MockConnectivity({required this.currentResult});

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return currentResult;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => controller.stream;
}

void main() {
  group('ConnectivityMonitor Tests', () {
    test('initializes and checks connectivity correctly (WiFi)', () async {
      final mockConnectivity = MockConnectivity(currentResult: [ConnectivityResult.wifi]);
      final monitor = ConnectivityMonitor(
        connectivity: mockConnectivity,
        logger: Logger(level: Level.nothing),
      );

      final status = await monitor.checkConnectivity();
      expect(status, ConnectivityStatus.wifi);
      expect(monitor.currentStatus, ConnectivityStatus.wifi);
    });

    test('initializes and checks connectivity correctly (Cellular)', () async {
      final mockConnectivity = MockConnectivity(currentResult: [ConnectivityResult.mobile]);
      final monitor = ConnectivityMonitor(
        connectivity: mockConnectivity,
        logger: Logger(level: Level.nothing),
      );

      final status = await monitor.checkConnectivity();
      expect(status, ConnectivityStatus.cellular);
      expect(monitor.currentStatus, ConnectivityStatus.cellular);
    });

    test('emits connectivity changes', () async {
      final mockConnectivity = MockConnectivity(currentResult: [ConnectivityResult.none]);
      final monitor = ConnectivityMonitor(
        connectivity: mockConnectivity,
        logger: Logger(level: Level.nothing),
      );

      final events = <ConnectivityStatus>[];
      monitor.connectivityStream.listen((event) {
        events.add(event);
      });

      monitor.startMonitoring();
      
      mockConnectivity.controller.add([ConnectivityResult.wifi]);
      await Future.delayed(const Duration(milliseconds: 10)); // Allow stream to process
      
      expect(events, contains(ConnectivityStatus.wifi));
      
      mockConnectivity.controller.add([ConnectivityResult.none]);
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(events, contains(ConnectivityStatus.none));
      
      monitor.stopMonitoring();
    });
  });
}
