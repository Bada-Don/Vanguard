import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';
import 'package:vanguard_crisis_response/core/config/env_config.dart';

enum ApiError {
  networkError,
  validationError,
  authenticationError,
  rateLimitExceeded,
  serverError,
  timeoutError,
  unknownError
}

class ApiResult<T, E> {
  final T? data;
  final E? error;
  final bool isSuccess;

  const ApiResult.success(this.data)
      : error = null,
        isSuccess = true;

  const ApiResult.failure(this.error)
      : data = null,
        isSuccess = false;
}

class ApiClient {
  final http.Client _client;
  final Logger _logger;
  
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);
  
  ApiClient({
    http.Client? client,
    Logger? logger,
  })  : _client = client ?? http.Client(),
        _logger = logger ?? Logger();

  Future<ApiResult<String, ApiError>> uploadEmergencyMessage(EmergencyPayload payload) async {
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        _logger.i('Uploading emergency message: ${payload.id} (Attempt ${attempts + 1})');
        
        final uri = Uri.parse('${EnvConfig.current.apiBaseUrl}/emergency/sos');
        final response = await _client.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${EnvConfig.current.apiKey}',
          },
          body: payload.toJsonString(),
        ).timeout(_timeout);

        if (response.statusCode == 201 || response.statusCode == 200) {
          _logger.i('Message ${payload.id} uploaded successfully');
          return ApiResult.success(payload.id);
        } else if (response.statusCode == 400) {
          _logger.w('Validation error for message ${payload.id}: ${response.body}');
          return const ApiResult.failure(ApiError.validationError);
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          _logger.e('Authentication error: ${response.statusCode}');
          return const ApiResult.failure(ApiError.authenticationError);
        } else if (response.statusCode == 429) {
          _logger.w('Rate limit exceeded');
          if (attempts == _maxRetries - 1) {
            return const ApiResult.failure(ApiError.rateLimitExceeded);
          }
        } else if (response.statusCode >= 500) {
          _logger.e('Server error: ${response.statusCode} - ${response.body}');
          if (attempts == _maxRetries - 1) {
           return const ApiResult.failure(ApiError.serverError);
          }
        } else {
          _logger.w('Unexpected API response: ${response.statusCode} - ${response.body}');
        }
      } on TimeoutException {
        _logger.e('Request timeout uploading message ${payload.id}');
        if (attempts == _maxRetries - 1) {
          return const ApiResult.failure(ApiError.timeoutError);
        }
      } catch (e) {
        _logger.e('Network error uploading message ${payload.id}: $e');
        if (attempts == _maxRetries - 1) {
          return const ApiResult.failure(ApiError.networkError);
        }
      }

      attempts++;
      if (attempts < _maxRetries) {
        final delay = Duration(seconds: (1 << attempts)); // Exponential backoff
        _logger.d('Waiting ${delay.inSeconds}s before next attempt...');
        await Future.delayed(delay);
      }
    }

    return const ApiResult.failure(ApiError.unknownError);
  }
}
