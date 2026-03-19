import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:vanguard_crisis_response/core/services/payload_validator.dart';

void main() {
  late PayloadValidator validator;

  setUp(() {
    validator = PayloadValidator(logger: Logger(level: Level.off));
  });

  group('PayloadValidator - Complete Payload Validation', () {
    test('should validate correct payload successfully', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.7333,
        'lng': 76.7794,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 2,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);

      expect(result.isValid, true);
      expect(result.errors, isEmpty);
      expect(result.errorMessages, isEmpty);
    });

    test('should detect multiple validation errors', () {
      final payload = {
        'id': 'invalid-uuid',
        'lat': 100.0, // Invalid
        'lng': 200.0, // Invalid
        'ts': -1, // Invalid
        'type': 10, // Invalid
        'hop': -5, // Invalid
      };

      final result = validator.validatePayload(payload);

      expect(result.isValid, false);
      expect(result.errors.length, 6);
      expect(result.errorMessages.length, 6);
    });
  });

  group('PayloadValidator - Message ID Validation', () {
    test('should accept valid UUID v4', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, true);
    });

    test('should reject invalid UUID format', () {
      final payload = {
        'id': 'not-a-uuid',
        'lat': 30.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidMessageId));
    });

    test('should reject empty message ID', () {
      final payload = {
        'id': '',
        'lat': 30.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidMessageId));
    });

    test('should reject null message ID', () {
      final payload = {
        'id': null,
        'lat': 30.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.missingRequiredField));
    });

    test('should validate UUID v4 with isValidMessageId helper', () {
      expect(validator.isValidMessageId('550e8400-e29b-41d4-a716-446655440000'), true);
      expect(validator.isValidMessageId('invalid-uuid'), false);
      expect(validator.isValidMessageId(''), false);
    });
  });

  group('PayloadValidator - Latitude Validation', () {
    test('should accept valid latitude values', () {
      final validLatitudes = [-90.0, -45.0, 0.0, 45.0, 90.0];

      for (final lat in validLatitudes) {
        final payload = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'lat': lat,
          'lng': 76.0,
          'ts': DateTime.now().millisecondsSinceEpoch,
          'type': 1,
          'hop': 0,
        };

        final result = validator.validatePayload(payload);
        expect(result.isValid, true, reason: 'Latitude $lat should be valid');
      }
    });

    test('should reject latitude below -90', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': -91.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidLatitude));
    });

    test('should reject latitude above 90', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 91.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidLatitude));
    });

    test('should reject null latitude', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': null,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.missingRequiredField));
    });
  });

  group('PayloadValidator - Longitude Validation', () {
    test('should accept valid longitude values', () {
      final validLongitudes = [-180.0, -90.0, 0.0, 90.0, 180.0];

      for (final lng in validLongitudes) {
        final payload = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'lat': 30.0,
          'lng': lng,
          'ts': DateTime.now().millisecondsSinceEpoch,
          'type': 1,
          'hop': 0,
        };

        final result = validator.validatePayload(payload);
        expect(result.isValid, true, reason: 'Longitude $lng should be valid');
      }
    });

    test('should reject longitude below -180', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': -181.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidLongitude));
    });

    test('should reject longitude above 180', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 181.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidLongitude));
    });

    test('should validate coordinates with helper method', () {
      expect(validator.areValidCoordinates(30.0, 76.0), true);
      expect(validator.areValidCoordinates(91.0, 76.0), false);
      expect(validator.areValidCoordinates(30.0, 181.0), false);
    });
  });

  group('PayloadValidator - Timestamp Validation', () {
    test('should accept recent timestamp', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, true);
    });

    test('should accept timestamp from 1 hour ago', () {
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
      
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 76.0,
        'ts': oneHourAgo,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, true);
    });

    test('should reject timestamp older than 24 hours', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch;
      
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 76.0,
        'ts': twoDaysAgo,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.timestampTooOld));
    });

    test('should reject negative timestamp', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 76.0,
        'ts': -1,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidTimestamp));
    });

    test('should reject zero timestamp', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 76.0,
        'ts': 0,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidTimestamp));
    });

    test('should validate timestamp with helper method', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(validator.isValidTimestamp(now), true);
      expect(validator.isValidTimestamp(-1), false);
      expect(validator.isValidTimestamp(0), false);
    });
  });

  group('PayloadValidator - Emergency Type Validation', () {
    test('should accept all valid emergency types (1-6)', () {
      for (int type = 1; type <= 6; type++) {
        final payload = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'lat': 30.0,
          'lng': 76.0,
          'ts': DateTime.now().millisecondsSinceEpoch,
          'type': type,
          'hop': 0,
        };

        final result = validator.validatePayload(payload);
        expect(result.isValid, true, reason: 'Type $type should be valid');
      }
    });

    test('should reject emergency type 0', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 0,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidEmergencyType));
    });

    test('should reject emergency type 7', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 7,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidEmergencyType));
    });

    test('should validate emergency type with helper method', () {
      expect(validator.isValidEmergencyType(1), true);
      expect(validator.isValidEmergencyType(6), true);
      expect(validator.isValidEmergencyType(0), false);
      expect(validator.isValidEmergencyType(7), false);
    });
  });

  group('PayloadValidator - Hop Count Validation', () {
    test('should accept hop count 0', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': 0,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, true);
    });

    test('should accept positive hop counts', () {
      for (int hop = 1; hop <= 10; hop++) {
        final payload = {
          'id': '550e8400-e29b-41d4-a716-446655440000',
          'lat': 30.0,
          'lng': 76.0,
          'ts': DateTime.now().millisecondsSinceEpoch,
          'type': 1,
          'hop': hop,
        };

        final result = validator.validatePayload(payload);
        expect(result.isValid, true, reason: 'Hop $hop should be valid');
      }
    });

    test('should reject negative hop count', () {
      final payload = {
        'id': '550e8400-e29b-41d4-a716-446655440000',
        'lat': 30.0,
        'lng': 76.0,
        'ts': DateTime.now().millisecondsSinceEpoch,
        'type': 1,
        'hop': -1,
      };

      final result = validator.validatePayload(payload);
      expect(result.isValid, false);
      expect(result.errors, contains(ValidationError.invalidHopCount));
    });

    test('should validate hop count with helper method', () {
      expect(validator.isValidHopCount(0), true);
      expect(validator.isValidHopCount(5), true);
      expect(validator.isValidHopCount(-1), false);
    });
  });

  group('PayloadValidator - Validation Constraints', () {
    test('should provide validation constraints', () {
      final constraints = validator.validationConstraints;

      expect(constraints['messageId'], 'UUID v4 format');
      expect(constraints['latitude'], {'min': -90.0, 'max': 90.0});
      expect(constraints['longitude'], {'min': -180.0, 'max': 180.0});
      expect(constraints['timestamp'], 'Positive integer within last 24 hours');
      expect(constraints['emergencyType'], {'min': 1, 'max': 6});
      expect(constraints['hopCount'], 'Non-negative integer');
    });
  });
}
