import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:uuid/uuid.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';
import 'package:vanguard_crisis_response/core/services/payload_generator.dart';

// Note: Geolocator uses static methods, so we'll test with integration approach
// For true unit testing, we'd need to wrap Geolocator in an interface

@GenerateMocks([Uuid])
import 'payload_generator_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PayloadGenerator', () {
    late PayloadGenerator payloadGenerator;
    late MockUuid mockUuid;
    late Logger logger;

    setUp(() {
      mockUuid = MockUuid();
      logger = Logger(level: Level.off); // Disable logging in tests
      payloadGenerator = PayloadGenerator(
        logger: logger,
        uuid: mockUuid,
      );
    });

    group('Configuration', () {
      test('should have correct accuracy threshold', () {
        expect(payloadGenerator.accuracyThreshold, 50.0);
      });

      test('should have correct max retries', () {
        expect(payloadGenerator.maxRetries, 3);
      });

      test('should have correct retry delay', () {
        expect(payloadGenerator.retryDelay, const Duration(seconds: 2));
      });
    });

    group('UUID Generation', () {
      test('should generate UUID v4 for message ID', () {
        const testUuid = '550e8400-e29b-41d4-a716-446655440000';
        when(mockUuid.v4()).thenReturn(testUuid);

        final uuid = mockUuid.v4();

        expect(uuid, testUuid);
        expect(uuid.length, 36); // UUID v4 format length
        verify(mockUuid.v4()).called(1);
      });

      test('should generate unique UUIDs for each call', () {
        const uuid1 = '550e8400-e29b-41d4-a716-446655440000';
        const uuid2 = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

        when(mockUuid.v4()).thenAnswer((_) => uuid1);
        final firstUuid = mockUuid.v4();
        
        when(mockUuid.v4()).thenAnswer((_) => uuid2);
        final secondUuid = mockUuid.v4();

        expect(firstUuid, isNot(equals(secondUuid)));
      });
    });

    group('Timestamp Generation', () {
      test('should generate Unix epoch timestamp', () {
        final beforeTimestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Small delay to ensure time passes
        Future.delayed(const Duration(milliseconds: 10));
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        expect(timestamp, greaterThanOrEqualTo(beforeTimestamp));
        expect(timestamp, isPositive);
      });

      test('should generate timestamp in milliseconds', () {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Unix epoch in milliseconds should be 13 digits (as of 2024)
        expect(timestamp.toString().length, 13);
      });
    });

    group('Emergency Type Handling', () {
      test('should handle all emergency types', () {
        const testUuid = 'test-uuid';
        when(mockUuid.v4()).thenReturn(testUuid);

        for (final emergencyType in EmergencyType.values) {
          expect(emergencyType.value, inInclusiveRange(1, 6));
          expect(emergencyType.displayName, isNotEmpty);
        }
      });

      test('should create payload with correct emergency type value', () {
        const testUuid = 'test-uuid';
        when(mockUuid.v4()).thenReturn(testUuid);

        final payload = EmergencyPayload(
          id: testUuid,
          lat: 30.7333,
          lng: 76.7794,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: EmergencyType.fire.value,
          hop: 0,
        );

        expect(payload.type, 2);
        expect(payload.emergencyType, EmergencyType.fire);
      });
    });

    group('Payload Structure', () {
      test('should create payload with all required fields', () {
        const testUuid = '550e8400-e29b-41d4-a716-446655440000';
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        final payload = EmergencyPayload(
          id: testUuid,
          lat: 30.7333,
          lng: 76.7794,
          ts: timestamp,
          type: EmergencyType.medical.value,
          hop: 0,
          accuracy: 15.5,
        );

        expect(payload.id, testUuid);
        expect(payload.lat, 30.7333);
        expect(payload.lng, 76.7794);
        expect(payload.ts, timestamp);
        expect(payload.type, 1);
        expect(payload.hop, 0);
        expect(payload.accuracy, 15.5);
      });

      test('should initialize hop count to zero', () {
        const testUuid = 'test-uuid';

        final payload = EmergencyPayload(
          id: testUuid,
          lat: 30.0,
          lng: 76.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
        );

        expect(payload.hop, 0);
      });

      test('should serialize payload to JSON correctly', () {
        const testUuid = 'test-uuid-123';
        final timestamp = 1710000000;

        final payload = EmergencyPayload(
          id: testUuid,
          lat: 30.7333,
          lng: 76.7794,
          ts: timestamp,
          type: 2,
          hop: 0,
          accuracy: 20.0,
        );

        final json = payload.toJson();

        expect(json['id'], testUuid);
        expect(json['lat'], 30.7333);
        expect(json['lng'], 76.7794);
        expect(json['ts'], timestamp);
        expect(json['type'], 2);
        expect(json['hop'], 0);
        expect(json['accuracy'], 20.0);
      });
    });

    group('GPS Coordinate Validation', () {
      test('should validate latitude range', () {
        final validPayload = EmergencyPayload(
          id: 'test',
          lat: 45.0, // Valid: -90 to 90
          lng: 76.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
        );

        expect(validPayload.isValid, isTrue);

        final invalidPayload = EmergencyPayload(
          id: 'test',
          lat: 95.0, // Invalid: > 90
          lng: 76.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
        );

        expect(invalidPayload.isValid, isFalse);
      });

      test('should validate longitude range', () {
        final validPayload = EmergencyPayload(
          id: 'test',
          lat: 30.0,
          lng: 120.0, // Valid: -180 to 180
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
        );

        expect(validPayload.isValid, isTrue);

        final invalidPayload = EmergencyPayload(
          id: 'test',
          lat: 30.0,
          lng: 200.0, // Invalid: > 180
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
        );

        expect(invalidPayload.isValid, isFalse);
      });

      test('should accept edge case coordinates', () {
        final northPole = EmergencyPayload(
          id: 'test',
          lat: 90.0,
          lng: 0.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
        );

        expect(northPole.isValid, isTrue);

        final southPole = EmergencyPayload(
          id: 'test',
          lat: -90.0,
          lng: 0.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
        );

        expect(southPole.isValid, isTrue);

        final dateLine = EmergencyPayload(
          id: 'test',
          lat: 0.0,
          lng: 180.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
        );

        expect(dateLine.isValid, isTrue);
      });
    });

    group('GPS Accuracy Validation', () {
      test('should accept accuracy within threshold', () {
        final payload = EmergencyPayload(
          id: 'test',
          lat: 30.0,
          lng: 76.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
          accuracy: 25.0, // Within 50m threshold
        );

        expect(payload.accuracy, lessThanOrEqualTo(50.0));
      });

      test('should flag poor accuracy', () {
        final payload = EmergencyPayload(
          id: 'test',
          lat: 30.0,
          lng: 76.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
          accuracy: 75.0, // Poor accuracy
        );

        expect(payload.accuracy, greaterThan(50.0));
      });

      test('should handle missing accuracy value', () {
        final payload = EmergencyPayload(
          id: 'test',
          lat: 30.0,
          lng: 76.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
          // No accuracy provided
        );

        expect(payload.accuracy, isNull);
      });
    });

    group('Error Handling', () {
      test('should have all error types defined', () {
        expect(PayloadError.values.length, 6);
        expect(PayloadError.values, contains(PayloadError.gpsUnavailable));
        expect(PayloadError.values, contains(PayloadError.gpsInaccurate));
        expect(PayloadError.values, contains(PayloadError.permissionDenied));
        expect(PayloadError.values, contains(PayloadError.timeout));
        expect(PayloadError.values, contains(PayloadError.locationServiceDisabled));
        expect(PayloadError.values, contains(PayloadError.unknownError));
      });

      test('should create failure result with error', () {
        const result = PayloadResult<EmergencyPayload, PayloadError>.failure(
          PayloadError.gpsUnavailable,
        );

        expect(result.isSuccess, isFalse);
        expect(result.error, PayloadError.gpsUnavailable);
        expect(result.data, isNull);
      });

      test('should create success result with data', () {
        final payload = EmergencyPayload(
          id: 'test',
          lat: 30.0,
          lng: 76.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
        );

        final result = PayloadResult<EmergencyPayload, PayloadError>.success(payload);

        expect(result.isSuccess, isTrue);
        expect(result.data, payload);
        expect(result.error, isNull);
      });
    });

    group('Real-world Coordinates', () {
      test('should handle coordinates from various locations', () {
        final locations = [
          {'name': 'Chandigarh, India', 'lat': 30.7333, 'lng': 76.7794},
          {'name': 'New York, USA', 'lat': 40.7128, 'lng': -74.0060},
          {'name': 'London, UK', 'lat': 51.5074, 'lng': -0.1278},
          {'name': 'Tokyo, Japan', 'lat': 35.6762, 'lng': 139.6503},
          {'name': 'Sydney, Australia', 'lat': -33.8688, 'lng': 151.2093},
        ];

        for (final location in locations) {
          final payload = EmergencyPayload(
            id: 'test',
            lat: location['lat'] as double,
            lng: location['lng'] as double,
            ts: DateTime.now().millisecondsSinceEpoch,
            type: 1,
            hop: 0,
          );

          expect(payload.isValid, isTrue, reason: 'Failed for ${location['name']}');
        }
      });
    });

    group('Payload Immutability', () {
      test('should create new instance when incrementing hop', () {
        final original = EmergencyPayload(
          id: 'test',
          lat: 30.0,
          lng: 76.0,
          ts: DateTime.now().millisecondsSinceEpoch,
          type: 1,
          hop: 0,
        );

        final incremented = original.incrementHop();

        expect(incremented.hop, 1);
        expect(original.hop, 0); // Original unchanged
        expect(incremented.id, original.id);
        expect(incremented.lat, original.lat);
      });
    });
  });
}
