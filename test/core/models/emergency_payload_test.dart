import 'package:flutter_test/flutter_test.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';

void main() {
  group('EmergencyPayload', () {
    const testPayload = EmergencyPayload(
      id: 'test-uuid-1234',
      lat: 30.7333,
      lng: 76.7794,
      ts: 1710000000,
      type: 2,
      hop: 0,
      accuracy: 15.5,
    );

    test('should create payload with all fields', () {
      expect(testPayload.id, 'test-uuid-1234');
      expect(testPayload.lat, 30.7333);
      expect(testPayload.lng, 76.7794);
      expect(testPayload.ts, 1710000000);
      expect(testPayload.type, 2);
      expect(testPayload.hop, 0);
      expect(testPayload.accuracy, 15.5);
    });

    test('should serialize to JSON correctly', () {
      final json = testPayload.toJson();
      
      expect(json['id'], 'test-uuid-1234');
      expect(json['lat'], 30.7333);
      expect(json['lng'], 76.7794);
      expect(json['ts'], 1710000000);
      expect(json['type'], 2);
      expect(json['hop'], 0);
      expect(json['accuracy'], 15.5);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-uuid-5678',
        'lat': 40.7128,
        'lng': -74.0060,
        'ts': 1710000100,
        'type': 1,
        'hop': 2,
        'accuracy': 20.0,
      };

      final payload = EmergencyPayload.fromJson(json);

      expect(payload.id, 'test-uuid-5678');
      expect(payload.lat, 40.7128);
      expect(payload.lng, -74.0060);
      expect(payload.ts, 1710000100);
      expect(payload.type, 1);
      expect(payload.hop, 2);
      expect(payload.accuracy, 20.0);
    });

    test('should handle JSON without accuracy field', () {
      final json = {
        'id': 'test-uuid-9999',
        'lat': 51.5074,
        'lng': -0.1278,
        'ts': 1710000200,
        'type': 3,
        'hop': 1,
      };

      final payload = EmergencyPayload.fromJson(json);

      expect(payload.accuracy, isNull);
    });

    test('should serialize and deserialize JSON string correctly', () {
      final jsonString = testPayload.toJsonString();
      final deserializedPayload = EmergencyPayload.fromJsonString(jsonString);

      expect(deserializedPayload, testPayload);
    });

    test('should increment hop count correctly', () {
      final incrementedPayload = testPayload.incrementHop();

      expect(incrementedPayload.hop, 1);
      expect(incrementedPayload.id, testPayload.id);
      expect(incrementedPayload.lat, testPayload.lat);
      expect(incrementedPayload.lng, testPayload.lng);
    });

    test('should validate correct payload', () {
      expect(testPayload.isValid, isTrue);
    });

    test('should invalidate payload with invalid latitude', () {
      const invalidPayload = EmergencyPayload(
        id: 'test-uuid',
        lat: 95.0, // Invalid: > 90
        lng: 76.7794,
        ts: 1710000000,
        type: 2,
        hop: 0,
      );

      expect(invalidPayload.isValid, isFalse);
    });

    test('should invalidate payload with invalid longitude', () {
      const invalidPayload = EmergencyPayload(
        id: 'test-uuid',
        lat: 30.7333,
        lng: 200.0, // Invalid: > 180
        ts: 1710000000,
        type: 2,
        hop: 0,
      );

      expect(invalidPayload.isValid, isFalse);
    });

    test('should invalidate payload with invalid emergency type', () {
      const invalidPayload = EmergencyPayload(
        id: 'test-uuid',
        lat: 30.7333,
        lng: 76.7794,
        ts: 1710000000,
        type: 10, // Invalid: > 6
        hop: 0,
      );

      expect(invalidPayload.isValid, isFalse);
    });

    test('should invalidate payload with negative hop count', () {
      const invalidPayload = EmergencyPayload(
        id: 'test-uuid',
        lat: 30.7333,
        lng: 76.7794,
        ts: 1710000000,
        type: 2,
        hop: -1, // Invalid: < 0
      );

      expect(invalidPayload.isValid, isFalse);
    });

    test('should get correct emergency type enum', () {
      expect(testPayload.emergencyType, EmergencyType.fire);
    });

    test('should support equality comparison', () {
      const payload1 = EmergencyPayload(
        id: 'same-id',
        lat: 30.0,
        lng: 76.0,
        ts: 1710000000,
        type: 1,
        hop: 0,
      );

      const payload2 = EmergencyPayload(
        id: 'same-id',
        lat: 30.0,
        lng: 76.0,
        ts: 1710000000,
        type: 1,
        hop: 0,
      );

      expect(payload1, payload2);
    });

    test('should create copy with updated fields', () {
      final copiedPayload = testPayload.copyWith(hop: 5, type: 3);

      expect(copiedPayload.hop, 5);
      expect(copiedPayload.type, 3);
      expect(copiedPayload.id, testPayload.id);
      expect(copiedPayload.lat, testPayload.lat);
    });
  });

  group('EmergencyType', () {
    test('should get correct value for each type', () {
      expect(EmergencyType.medical.value, 1);
      expect(EmergencyType.fire.value, 2);
      expect(EmergencyType.crime.value, 3);
      expect(EmergencyType.naturalDisaster.value, 4);
      expect(EmergencyType.accident.value, 5);
      expect(EmergencyType.other.value, 6);
    });

    test('should get correct display name for each type', () {
      expect(EmergencyType.medical.displayName, 'Medical');
      expect(EmergencyType.fire.displayName, 'Fire');
      expect(EmergencyType.crime.displayName, 'Crime');
      expect(EmergencyType.naturalDisaster.displayName, 'Natural Disaster');
      expect(EmergencyType.accident.displayName, 'Accident');
      expect(EmergencyType.other.displayName, 'Other');
    });

    test('should convert from value correctly', () {
      expect(EmergencyType.fromValue(1), EmergencyType.medical);
      expect(EmergencyType.fromValue(2), EmergencyType.fire);
      expect(EmergencyType.fromValue(3), EmergencyType.crime);
      expect(EmergencyType.fromValue(4), EmergencyType.naturalDisaster);
      expect(EmergencyType.fromValue(5), EmergencyType.accident);
      expect(EmergencyType.fromValue(6), EmergencyType.other);
    });

    test('should default to other for invalid value', () {
      expect(EmergencyType.fromValue(99), EmergencyType.other);
    });
  });
}
