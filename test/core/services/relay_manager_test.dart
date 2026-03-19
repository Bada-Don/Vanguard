import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';
import 'package:vanguard_crisis_response/core/models/mesh_network_config.dart';
import 'package:vanguard_crisis_response/core/services/encryption_layer.dart';
import 'package:vanguard_crisis_response/core/services/message_queue.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';
import 'package:vanguard_crisis_response/core/services/payload_validator.dart';
import 'package:vanguard_crisis_response/core/services/relay_manager.dart';

@GenerateMocks([NearbyService, FlutterSecureStorage])
import 'relay_manager_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RelayManager relayManager;
  late EncryptionLayer encryptionLayer;
  late PayloadValidator payloadValidator;
  late MockNearbyService mockNearbyService;
  late MessageQueue messageQueue;
  late MeshNetworkConfig config;
  late StreamController<Map<String, dynamic>> payloadStreamController;
  final uuid = const Uuid();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    // Mock FlutterSecureStorage
    final mockSecureStorage = MockFlutterSecureStorage();
    when(mockSecureStorage.read(key: anyNamed('key')))
        .thenAnswer((_) async => null);
    when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
        .thenAnswer((_) async => null);

    // Initialize real services
    encryptionLayer = EncryptionLayer(
      logger: Logger(level: Level.off),
      secureStorage: mockSecureStorage,
    );
    await encryptionLayer.initializeKey();

    payloadValidator = PayloadValidator(logger: Logger(level: Level.off));

    messageQueue = MessageQueue(logger: Logger(level: Level.off), maxSize: 50);
    await messageQueue.initialize();

    config = const MeshNetworkConfig(maxHops: 3);

    // Mock NearbyService
    mockNearbyService = MockNearbyService();
    payloadStreamController = StreamController<Map<String, dynamic>>.broadcast();
    
    when(mockNearbyService.payloadStream).thenAnswer((_) => payloadStreamController.stream);
    when(mockNearbyService.sendPayload(any)).thenAnswer((_) async => 2);

    relayManager = RelayManager(
      encryptionLayer: encryptionLayer,
      payloadValidator: payloadValidator,
      nearbyService: mockNearbyService,
      messageQueue: messageQueue,
      config: config,
      logger: Logger(level: Level.off),
    );

    await relayManager.initialize();
  });

  tearDown(() async {
    await relayManager.dispose();
    await payloadStreamController.close();
  });

  EmergencyPayload createTestPayload({
    String? id,
    int? hop,
    int? ts,
  }) {
    return EmergencyPayload(
      id: id ?? uuid.v4(),
      lat: 30.7333,
      lng: 76.7794,
      ts: ts ?? DateTime.now().millisecondsSinceEpoch,
      type: 1,
      hop: hop ?? 0,
    );
  }

  Future<Uint8List> encryptPayload(EmergencyPayload payload) async {
    final result = await encryptionLayer.encrypt(payload.toJsonString());
    return result.data!;
  }

  group('RelayManager - Initialization', () {
    test('should initialize successfully', () {
      expect(relayManager.isInitialized, true);
      expect(relayManager.processedMessageCount, 0);
    });

    test('should initialize dependencies', () async {
      expect(encryptionLayer.isInitialized, true);
      expect(messageQueue.isInitialized, true);
    });

    test('should subscribe to payload stream', () {
      verify(mockNearbyService.payloadStream).called(1);
    });
  });

  group('RelayManager - Payload Processing', () {
    test('should process valid payload successfully', () async {
      final payload = createTestPayload(id: 'valid-payload');
      final encrypted = await encryptPayload(payload);

      final result = await relayManager.processReceivedPayload(encrypted);

      expect(result, RelayResult.success);
      expect(relayManager.isMessageProcessed('valid-payload'), true);
      expect(relayManager.statistics.messagesProcessed, 1);
      expect(relayManager.statistics.messagesRelayed, 1);
    });

    test('should detect duplicate messages', () async {
      final payload = createTestPayload(id: 'duplicate-test');
      final encrypted = await encryptPayload(payload);

      // Process first time
      final result1 = await relayManager.processReceivedPayload(encrypted);
      expect(result1, RelayResult.success);

      // Process second time (duplicate)
      final result2 = await relayManager.processReceivedPayload(encrypted);
      expect(result2, RelayResult.duplicate);
      expect(relayManager.statistics.messagesDuplicate, 1);
    });

    test('should reject payload with max hops reached', () async {
      final payload = createTestPayload(id: 'max-hops', hop: 3);
      final encrypted = await encryptPayload(payload);

      final result = await relayManager.processReceivedPayload(encrypted);

      expect(result, RelayResult.maxHopsReached);
      expect(relayManager.statistics.messagesDropped, 1);
      verify(mockNearbyService.sendPayload(any)).called(0); // Should not relay
    });

    test('should increment hop count when relaying', () async {
      final payload = createTestPayload(id: 'hop-test', hop: 1);
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);

      // Verify sendPayload was called
      final captured = verify(mockNearbyService.sendPayload(captureAny)).captured;
      expect(captured.length, 1);

      // Decrypt and verify hop was incremented
      final relayedEncrypted = captured[0] as Uint8List;
      final decryptResult = await encryptionLayer.decrypt(relayedEncrypted);
      final relayedPayload = EmergencyPayload.fromJsonString(decryptResult.data!);

      expect(relayedPayload.hop, 2);
    });

    test('should handle decryption failure', () async {
      final invalidEncrypted = Uint8List.fromList([1, 2, 3, 4, 5]);

      final result = await relayManager.processReceivedPayload(invalidEncrypted);

      expect(result, RelayResult.decryptionFailed);
      expect(relayManager.statistics.decryptionErrors, 1);
    });

    test('should handle validation failure', () async {
      final invalidPayload = EmergencyPayload(
        id: 'invalid-uuid',
        lat: 100.0, // Invalid latitude
        lng: 76.0,
        ts: DateTime.now().millisecondsSinceEpoch,
        type: 1,
        hop: 0,
      );

      final encrypted = await encryptPayload(invalidPayload);
      final result = await relayManager.processReceivedPayload(encrypted);

      expect(result, RelayResult.validationFailed);
      expect(relayManager.statistics.validationErrors, 1);
    });
  });

  group('RelayManager - Message Queue Integration', () {
    test('should add processed message to queue', () async {
      final payload = createTestPayload(id: 'queue-test');
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);

      expect(messageQueue.size, 1);
      expect(messageQueue.contains('queue-test'), true);
    });

    test('should add message to queue even when max hops reached', () async {
      final payload = createTestPayload(id: 'max-hop-queue', hop: 3);
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);

      expect(messageQueue.size, 1);
      expect(messageQueue.contains('max-hop-queue'), true);
    });

    test('should not add duplicate to queue', () async {
      final payload = createTestPayload(id: 'dup-queue');
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);
      await relayManager.processReceivedPayload(encrypted);

      expect(messageQueue.size, 1);
    });
  });

  group('RelayManager - Relay Statistics', () {
    test('should track messages processed', () async {
      for (int i = 0; i < 5; i++) {
        final payload = createTestPayload(id: 'msg-$i');
        final encrypted = await encryptPayload(payload);
        await relayManager.processReceivedPayload(encrypted);
      }

      expect(relayManager.statistics.messagesProcessed, 5);
      expect(relayManager.statistics.messagesRelayed, 5);
    });

    test('should track duplicate messages', () async {
      final payload = createTestPayload(id: 'dup-stat');
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);
      await relayManager.processReceivedPayload(encrypted);
      await relayManager.processReceivedPayload(encrypted);

      expect(relayManager.statistics.messagesProcessed, 3);
      expect(relayManager.statistics.messagesDuplicate, 2);
    });

    test('should track dropped messages', () async {
      final payload = createTestPayload(id: 'drop-stat', hop: 3);
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);

      expect(relayManager.statistics.messagesDropped, 1);
    });

    test('should track validation errors', () async {
      final invalidPayload = EmergencyPayload(
        id: 'invalid',
        lat: 100.0,
        lng: 76.0,
        ts: DateTime.now().millisecondsSinceEpoch,
        type: 1,
        hop: 0,
      );

      final encrypted = await encryptPayload(invalidPayload);
      await relayManager.processReceivedPayload(encrypted);

      expect(relayManager.statistics.validationErrors, 1);
    });

    test('should update last relay timestamp', () async {
      final payload = createTestPayload();
      final encrypted = await encryptPayload(payload);

      final beforeTs = DateTime.now().millisecondsSinceEpoch;
      await relayManager.processReceivedPayload(encrypted);
      final afterTs = DateTime.now().millisecondsSinceEpoch;

      expect(relayManager.statistics.lastRelayTimestamp, isNotNull);
      expect(relayManager.statistics.lastRelayTimestamp! >= beforeTs, true);
      expect(relayManager.statistics.lastRelayTimestamp! <= afterTs, true);
    });
  });

  group('RelayManager - Relay Events', () {
    test('should emit message_relayed event', () async {
      final events = <Map<String, dynamic>>[];
      relayManager.relayEventStream.listen(events.add);

      final payload = createTestPayload(id: 'event-test');
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);
      await Future.delayed(const Duration(milliseconds: 100));

      final relayedEvents = events.where((e) => e['type'] == 'message_relayed').toList();
      expect(relayedEvents.length, 1);
      expect(relayedEvents[0]['messageId'], 'event-test');
    });

    test('should emit duplicate_detected event', () async {
      final events = <Map<String, dynamic>>[];
      relayManager.relayEventStream.listen(events.add);

      final payload = createTestPayload(id: 'dup-event');
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);
      await relayManager.processReceivedPayload(encrypted);
      await Future.delayed(const Duration(milliseconds: 100));

      final dupEvents = events.where((e) => e['type'] == 'duplicate_detected').toList();
      expect(dupEvents.length, 1);
      expect(dupEvents[0]['messageId'], 'dup-event');
    });

    test('should emit max_hops_reached event', () async {
      final events = <Map<String, dynamic>>[];
      relayManager.relayEventStream.listen(events.add);

      final payload = createTestPayload(id: 'max-hop-event', hop: 3);
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);
      await Future.delayed(const Duration(milliseconds: 100));

      final maxHopEvents = events.where((e) => e['type'] == 'max_hops_reached').toList();
      expect(maxHopEvents.length, 1);
      expect(maxHopEvents[0]['messageId'], 'max-hop-event');
      expect(maxHopEvents[0]['hopCount'], 3);
    });

    test('should emit message_queued event', () async {
      final events = <Map<String, dynamic>>[];
      relayManager.relayEventStream.listen(events.add);

      final payload = createTestPayload(id: 'queue-event');
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);
      await Future.delayed(const Duration(milliseconds: 100));

      final queuedEvents = events.where((e) => e['type'] == 'message_queued').toList();
      expect(queuedEvents.length, 1);
      expect(queuedEvents[0]['messageId'], 'queue-event');
    });
  });

  group('RelayManager - Processed Messages Management', () {
    test('should track processed message IDs', () async {
      final payload = createTestPayload(id: 'track-test');
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);

      expect(relayManager.isMessageProcessed('track-test'), true);
      expect(relayManager.isMessageProcessed('non-existent'), false);
    });

    test('should get processed message count', () async {
      for (int i = 0; i < 3; i++) {
        final payload = createTestPayload(id: 'count-$i');
        final encrypted = await encryptPayload(payload);
        await relayManager.processReceivedPayload(encrypted);
      }

      expect(relayManager.processedMessageCount, 3);
    });

    test('should clear processed messages', () async {
      final payload = createTestPayload(id: 'clear-test');
      final encrypted = await encryptPayload(payload);

      await relayManager.processReceivedPayload(encrypted);
      expect(relayManager.processedMessageCount, 1);

      relayManager.clearProcessedMessages();
      expect(relayManager.processedMessageCount, 0);
      expect(relayManager.isMessageProcessed('clear-test'), false);
    });
  });

  group('RelayManager - Configuration', () {
    test('should use provided configuration', () {
      expect(relayManager.config.maxHops, 3);
    });

    test('should respect max hops from config', () async {
      final customConfig = const MeshNetworkConfig(maxHops: 5);
      final customRelayManager = RelayManager(
        encryptionLayer: encryptionLayer,
        payloadValidator: payloadValidator,
        nearbyService: mockNearbyService,
        messageQueue: messageQueue,
        config: customConfig,
        logger: Logger(level: Level.off),
      );

      await customRelayManager.initialize();

      final payload = createTestPayload(id: 'config-test', hop: 4);
      final encrypted = await encryptPayload(payload);

      final result = await customRelayManager.processReceivedPayload(encrypted);

      expect(result, RelayResult.success); // Should relay with hop 4
      await customRelayManager.dispose();
    });
  });

  group('RelayManager - Payload Stream Integration', () {
    test('should process payloads from stream', () async {
      final payload = createTestPayload(id: 'stream-test');
      final encrypted = await encryptPayload(payload);

      // Emit payload through stream
      payloadStreamController.add({
        'payload': encrypted,
        'endpointId': 'test-endpoint',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Wait for async processing
      await Future.delayed(const Duration(milliseconds: 200));

      expect(relayManager.isMessageProcessed('stream-test'), true);
    });

    test('should handle multiple payloads from stream', () async {
      for (int i = 0; i < 3; i++) {
        final payload = createTestPayload(id: 'stream-$i');
        final encrypted = await encryptPayload(payload);

        payloadStreamController.add({
          'payload': encrypted,
          'endpointId': 'endpoint-$i',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }

      await Future.delayed(const Duration(milliseconds: 300));

      expect(relayManager.processedMessageCount, 3);
    });
  });

  group('RelayManager - Error Handling', () {
    test('should throw error if operations called before initialization', () {
      final uninitManager = RelayManager(
        encryptionLayer: encryptionLayer,
        payloadValidator: payloadValidator,
        nearbyService: mockNearbyService,
        messageQueue: messageQueue,
        logger: Logger(level: Level.off),
      );

      expect(
        () => uninitManager.isMessageProcessed('test'),
        throwsStateError,
      );
    });

    test('should handle sendPayload failure gracefully', () async {
      when(mockNearbyService.sendPayload(any)).thenThrow(Exception('Send failed'));

      final payload = createTestPayload(id: 'send-fail');
      final encrypted = await encryptPayload(payload);

      final result = await relayManager.processReceivedPayload(encrypted);

      // Should still process but fail to relay
      expect(result, RelayResult.transmissionFailed);
    });
  });

  group('RelayManager - toString', () {
    test('should provide readable string representation', () async {
      final payload = createTestPayload();
      final encrypted = await encryptPayload(payload);
      await relayManager.processReceivedPayload(encrypted);

      final str = relayManager.toString();

      expect(str, contains('RelayManager'));
      expect(str, contains('processed: 1'));
    });
  });

  group('RelayManager - Statistics JSON', () {
    test('should convert statistics to JSON', () async {
      final payload = createTestPayload();
      final encrypted = await encryptPayload(payload);
      await relayManager.processReceivedPayload(encrypted);

      final json = relayManager.statistics.toJson();

      expect(json['messagesProcessed'], 1);
      expect(json['messagesRelayed'], 1);
      expect(json['messagesDuplicate'], 0);
      expect(json['messagesDropped'], 0);
      expect(json['lastRelayTimestamp'], isNotNull);
    });
  });
}
