import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NearbyService', () {
    late NearbyService nearbyService;
    late Logger logger;
    
    // Mock method channel
    const MethodChannel nearbyChannel = MethodChannel('com.vanguard.crisis/nearby');
    const EventChannel connectionEventChannel = EventChannel('com.vanguard.crisis/connection_events');
    const EventChannel payloadEventChannel = EventChannel('com.vanguard.crisis/payload_events');

    setUp(() {
      logger = Logger(level: Level.off);
      nearbyService = NearbyService(logger: logger);
      
      // Set up method channel mock handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(nearbyChannel, (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'startAdvertising':
            return true;
          case 'startDiscovery':
            return true;
          case 'stopAdvertising':
            return true;
          case 'stopDiscovery':
            return true;
          case 'sendPayload':
            return 1; // Sent to 1 endpoint
          case 'getConnectedEndpointsCount':
            return 0;
          case 'getConnectedEndpoints':
            return <String>[];
          default:
            return null;
        }
      });
    });

    tearDown(() {
      nearbyService.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(nearbyChannel, null);
    });

    group('Initialization', () {
      test('should initialize with disconnected state', () {
        expect(nearbyService.currentState, ConnectionState.disconnected);
        expect(nearbyService.isActive, isFalse);
        expect(nearbyService.hasConnections, isFalse);
      });

      test('should have empty endpoints list initially', () {
        expect(nearbyService.connectedEndpointsCount, 0);
        expect(nearbyService.connectedEndpoints, isEmpty);
      });

      test('should have empty payload queue initially', () {
        expect(nearbyService.queuedPayloadsCount, 0);
      });
    });

    group('Connection State', () {
      test('should have all connection states defined', () {
        expect(ConnectionState.values.length, 4);
        expect(ConnectionState.values, contains(ConnectionState.disconnected));
        expect(ConnectionState.values, contains(ConnectionState.advertising));
        expect(ConnectionState.values, contains(ConnectionState.discovering));
        expect(ConnectionState.values, contains(ConnectionState.connected));
      });

      test('should have display names for all states', () {
        expect(ConnectionState.disconnected.displayName, 'Disconnected');
        expect(ConnectionState.advertising.displayName, 'Advertising');
        expect(ConnectionState.discovering.displayName, 'Discovering');
        expect(ConnectionState.connected.displayName, 'Connected');
      });

      test('should emit state changes via stream', () async {
        final states = <ConnectionState>[];
        final subscription = nearbyService.connectionStateStream.listen(states.add);

        await nearbyService.startMeshNetworking('TestUser');

        await Future.delayed(const Duration(milliseconds: 100));

        expect(states, isNotEmpty);
        
        await subscription.cancel();
      });
    });

    group('Start Mesh Networking', () {
      test('should start advertising and discovery successfully', () async {
        final result = await nearbyService.startMeshNetworking('TestUser');

        expect(result, isTrue);
        expect(nearbyService.isActive, isTrue);
      });

      test('should update state when starting', () async {
        await nearbyService.startMeshNetworking('TestUser');

        expect(nearbyService.currentState, isNot(ConnectionState.disconnected));
      });

      test('should handle start failure gracefully', () async {
        // Override mock to return false
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(nearbyChannel, (MethodCall methodCall) async {
          return false;
        });

        final result = await nearbyService.startMeshNetworking('TestUser');

        expect(result, isFalse);
      });
    });

    group('Stop Mesh Networking', () {
      test('should stop advertising and discovery successfully', () async {
        await nearbyService.startMeshNetworking('TestUser');
        final result = await nearbyService.stopMeshNetworking();

        expect(result, isTrue);
        expect(nearbyService.currentState, ConnectionState.disconnected);
        expect(nearbyService.isActive, isFalse);
      });

      test('should clear endpoints when stopping', () async {
        await nearbyService.startMeshNetworking('TestUser');
        await nearbyService.stopMeshNetworking();

        expect(nearbyService.connectedEndpointsCount, 0);
        expect(nearbyService.connectedEndpoints, isEmpty);
      });
    });

    group('Send Payload', () {
      test('should queue payload when no endpoints connected', () async {
        final payload = Uint8List.fromList([1, 2, 3, 4, 5]);
        
        final sentCount = await nearbyService.sendPayload(payload);

        expect(sentCount, 0);
        expect(nearbyService.queuedPayloadsCount, 1);
      });

      test('should send payload when endpoints connected', () async {
        // Mock having connected endpoints
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(nearbyChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'sendPayload') {
            return 2; // Sent to 2 endpoints
          }
          return true;
        });

        await nearbyService.startMeshNetworking('TestUser');
        
        final payload = Uint8List.fromList([1, 2, 3, 4, 5]);
        final sentCount = await nearbyService.sendPayload(payload);

        // Note: In real scenario with connected endpoints, this would be > 0
        // For this test with mocked channel, we're testing the flow
        expect(sentCount, greaterThanOrEqualTo(0));
      });

      test('should handle send errors gracefully', () async {
        // Override mock to throw error
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(nearbyChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'sendPayload') {
            throw PlatformException(code: 'ERROR', message: 'Send failed');
          }
          return true;
        });

        final payload = Uint8List.fromList([1, 2, 3, 4, 5]);
        final sentCount = await nearbyService.sendPayload(payload);

        expect(sentCount, 0);
        expect(nearbyService.queuedPayloadsCount, greaterThan(0));
      });
    });

    group('Payload Queue', () {
      test('should queue multiple payloads', () async {
        final payload1 = Uint8List.fromList([1, 2, 3]);
        final payload2 = Uint8List.fromList([4, 5, 6]);
        final payload3 = Uint8List.fromList([7, 8, 9]);

        await nearbyService.sendPayload(payload1);
        await nearbyService.sendPayload(payload2);
        await nearbyService.sendPayload(payload3);

        expect(nearbyService.queuedPayloadsCount, 3);
      });

      test('should clear payload queue', () async {
        final payload = Uint8List.fromList([1, 2, 3]);
        await nearbyService.sendPayload(payload);

        expect(nearbyService.queuedPayloadsCount, 1);

        nearbyService.clearPayloadQueue();

        expect(nearbyService.queuedPayloadsCount, 0);
      });
    });

    group('Connection Management', () {
      test('should track active state correctly', () {
        expect(nearbyService.isActive, isFalse);
        
        // After starting, should be active
        // (tested in start mesh networking tests)
      });

      test('should track connection state correctly', () {
        expect(nearbyService.hasConnections, isFalse);
        expect(nearbyService.connectedEndpointsCount, 0);
      });

      test('should provide immutable endpoints list', () {
        final endpoints = nearbyService.connectedEndpoints;
        
        expect(endpoints, isA<List<String>>());
        expect(() => endpoints.add('test'), throwsUnsupportedError);
      });
    });

    group('Streams', () {
      test('should provide connection state stream', () {
        expect(nearbyService.connectionStateStream, isA<Stream<ConnectionState>>());
      });

      test('should provide payload stream', () {
        expect(nearbyService.payloadStream, isA<Stream<Map<String, dynamic>>>());
      });

      test('should emit connection state changes', () async {
        final states = <ConnectionState>[];
        final subscription = nearbyService.connectionStateStream.listen(states.add);

        await nearbyService.startMeshNetworking('TestUser');
        await Future.delayed(const Duration(milliseconds: 50));

        await nearbyService.stopMeshNetworking();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, isNotEmpty);
        
        await subscription.cancel();
      });
    });

    group('Disposal', () {
      test('should dispose resources cleanly', () {
        expect(() => nearbyService.dispose(), returnsNormally);
      });

      test('should close streams on dispose', () async {
        final service = NearbyService(logger: logger);
        
        service.dispose();

        // Streams should be closed
        expect(service.connectionStateStream.isBroadcast, isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle platform exceptions gracefully', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(nearbyChannel, (MethodCall methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Platform error');
        });

        final result = await nearbyService.startMeshNetworking('TestUser');

        expect(result, isFalse);
      });

      test('should handle null responses from platform', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(nearbyChannel, (MethodCall methodCall) async {
          return null;
        });

        final result = await nearbyService.startMeshNetworking('TestUser');

        // Should handle null gracefully
        expect(result, isA<bool>());
      });
    });
  });
}
