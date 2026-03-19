import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';
import 'package:vanguard_crisis_response/core/services/api_client.dart';

class MockHttpClient extends Fake implements http.Client {
  final Future<http.Response> Function(Uri url, {Map<String, String>? headers, Object? body}) onPost;
  
  MockHttpClient({required this.onPost});

  @override
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return onPost(url, headers: headers, body: body);
  }
}

void main() {
  group('ApiClient Tests', () {
    late EmergencyPayload testPayload;
    
    setUp(() {
      testPayload = EmergencyPayload(
        id: '123e4567-e89b-12d3-a456-426614174000',
        lat: 37.7749,
        lng: -122.4194,
        ts: DateTime.now().millisecondsSinceEpoch,
        type: 1,
        hop: 0,
        accuracy: 10.0,
      );
    });

    test('uploadEmergencyMessage returns success on 201', () async {
      final mockClient = MockHttpClient(
        onPost: (url, {headers, body}) async {
          return http.Response('{"messageId": "123e4567"}', 201);
        },
      );
      
      final client = ApiClient(client: mockClient, logger: Logger(level: Level.nothing));
      final result = await client.uploadEmergencyMessage(testPayload);
      
      expect(result.isSuccess, isTrue);
      expect(result.data, testPayload.id);
    });
    
    test('uploadEmergencyMessage returns validationError on 400', () async {
      final mockClient = MockHttpClient(
        onPost: (url, {headers, body}) async {
          return http.Response('{"error": "Invalid payload"}', 400);
        },
      );
      
      final client = ApiClient(client: mockClient, logger: Logger(level: Level.nothing));
      final result = await client.uploadEmergencyMessage(testPayload);
      
      expect(result.isSuccess, isFalse);
      expect(result.error, ApiError.validationError);
    });
    
    test('uploadEmergencyMessage returns serverError on 500', () async {
      final mockClient = MockHttpClient(
        onPost: (url, {headers, body}) async {
          return http.Response('{"error": "Internal Server Error"}', 500);
        },
      );
      
      final client = ApiClient(client: mockClient, logger: Logger(level: Level.nothing));
      final result = await client.uploadEmergencyMessage(testPayload);
      
      expect(result.isSuccess, isFalse);
      expect(result.error, ApiError.serverError);
    });

    test('uploadEmergencyMessage returns rateLimitExceeded on 429', () async {
      final mockClient = MockHttpClient(
        onPost: (url, {headers, body}) async {
          return http.Response('{"error": "Rate limit"}', 429);
        },
      );
      
      final client = ApiClient(client: mockClient, logger: Logger(level: Level.nothing));
      final result = await client.uploadEmergencyMessage(testPayload);
      
      expect(result.isSuccess, isFalse);
      expect(result.error, ApiError.rateLimitExceeded);
    });
  });
}
