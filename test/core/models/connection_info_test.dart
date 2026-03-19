import 'package:flutter_test/flutter_test.dart';
import 'package:vanguard_crisis_response/core/models/connection_info.dart';

void main() {
  group('ConnectionInfo', () {
    final testDateTime = DateTime(2024, 3, 19, 10, 0, 0);
    
    final testConnectionInfo = ConnectionInfo(
      endpointId: 'endpoint-123',
      endpointName: 'Device A',
      connectedAt: testDateTime,
      status: ConnectionStatus.connected,
      messagesSent: 5,
      messagesReceived: 3,
    );

    test('should create connection info with all fields', () {
      expect(testConnectionInfo.endpointId, 'endpoint-123');
      expect(testConnectionInfo.endpointName, 'Device A');
      expect(testConnectionInfo.connectedAt, testDateTime);
      expect(testConnectionInfo.status, ConnectionStatus.connected);
      expect(testConnectionInfo.messagesSent, 5);
      expect(testConnectionInfo.messagesReceived, 3);
    });

    test('should increment messages sent counter', () {
      final updated = testConnectionInfo.incrementMessagesSent();

      expect(updated.messagesSent, 6);
      expect(updated.messagesReceived, 3);
      expect(updated.lastActivityAt, isNotNull);
    });

    test('should increment messages received counter', () {
      final updated = testConnectionInfo.incrementMessagesReceived();

      expect(updated.messagesReceived, 4);
      expect(updated.messagesSent, 5);
      expect(updated.lastActivityAt, isNotNull);
    });

    test('should update connection status', () {
      final updated = testConnectionInfo.updateStatus(ConnectionStatus.disconnected);

      expect(updated.status, ConnectionStatus.disconnected);
      expect(updated.lastActivityAt, isNotNull);
    });

    test('should check if connection is active', () {
      expect(testConnectionInfo.isActive, isTrue);

      final disconnected = testConnectionInfo.updateStatus(ConnectionStatus.disconnected);
      expect(disconnected.isActive, isFalse);
    });

    test('should calculate connection duration', () {
      final duration = testConnectionInfo.connectionDuration;
      expect(duration, isA<Duration>());
      expect(duration.inSeconds, greaterThan(0));
    });

    test('should support equality comparison', () {
      final info1 = ConnectionInfo(
        endpointId: 'same-id',
        endpointName: 'Device',
        connectedAt: testDateTime,
        status: ConnectionStatus.connected,
      );

      final info2 = ConnectionInfo(
        endpointId: 'same-id',
        endpointName: 'Device',
        connectedAt: testDateTime,
        status: ConnectionStatus.connected,
      );

      expect(info1, info2);
    });

    test('should create copy with updated fields', () {
      final copied = testConnectionInfo.copyWith(
        endpointName: 'Device B',
        messagesSent: 10,
      );

      expect(copied.endpointName, 'Device B');
      expect(copied.messagesSent, 10);
      expect(copied.endpointId, testConnectionInfo.endpointId);
      expect(copied.messagesReceived, testConnectionInfo.messagesReceived);
    });
  });

  group('ConnectionStatus', () {
    test('should get correct display name for each status', () {
      expect(ConnectionStatus.connecting.displayName, 'Connecting');
      expect(ConnectionStatus.connected.displayName, 'Connected');
      expect(ConnectionStatus.disconnected.displayName, 'Disconnected');
      expect(ConnectionStatus.failed.displayName, 'Failed');
    });
  });
}
