import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:vanguard_crisis_response/core/models/emergency_payload.dart';

/// Result type for payload generation operations
class PayloadResult<T, E> {
  final T? data;
  final E? error;
  final bool isSuccess;

  const PayloadResult.success(this.data)
      : error = null,
        isSuccess = true;

  const PayloadResult.failure(this.error)
      : data = null,
        isSuccess = false;
}

/// Payload generation error types
enum PayloadError {
  gpsUnavailable,
  gpsInaccurate,
  permissionDenied,
  timeout,
  locationServiceDisabled,
  unknownError,
}

/// Payload generator service for creating emergency payloads
/// Handles GPS coordinate collection with validation and retry logic
class PayloadGenerator {
  static const double _accuracyThreshold = 50.0; // meters
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);
  static const Duration _gpsTimeout = Duration(seconds: 10);

  final Logger _logger;
  final Uuid _uuid;

  PayloadGenerator({
    Logger? logger,
    Uuid? uuid,
  })  : _logger = logger ?? Logger(),
        _uuid = uuid ?? const Uuid();

  /// Generate emergency payload with GPS coordinates
  /// 
  /// Process:
  /// 1. Check location service status
  /// 2. Check location permissions
  /// 3. Collect GPS coordinates with high accuracy
  /// 4. Validate GPS accuracy (within 50 meters)
  /// 5. Retry up to 3 times if accuracy is poor
  /// 6. Generate UUID v4 for Message_ID
  /// 7. Record Unix epoch timestamp
  /// 8. Create EmergencyPayload with all data
  /// 
  /// Returns PayloadResult with EmergencyPayload or error
  Future<PayloadResult<EmergencyPayload, PayloadError>> generatePayload({
    required EmergencyType emergencyType,
  }) async {
    try {
      _logger.i('Generating emergency payload for type: ${emergencyType.displayName}');

      // Step 1: Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.e('Location services are disabled');
        return const PayloadResult.failure(PayloadError.locationServiceDisabled);
      }

      // Step 2: Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        _logger.w('Location permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _logger.e('Location permission denied by user');
          return const PayloadResult.failure(PayloadError.permissionDenied);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _logger.e('Location permission permanently denied');
        return const PayloadResult.failure(PayloadError.permissionDenied);
      }

      // Step 3: Collect GPS coordinates with retry logic
      Position? position;
      int retryCount = 0;

      while (retryCount < _maxRetries) {
        try {
          _logger.d('Attempting GPS acquisition (attempt ${retryCount + 1}/$_maxRetries)');

          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: _gpsTimeout,
          );

          _logger.d('GPS acquired: lat=${position.latitude}, lng=${position.longitude}, accuracy=${position.accuracy}m');

          // Step 4: Validate GPS accuracy
          if (position.accuracy <= _accuracyThreshold) {
            _logger.i('GPS accuracy acceptable: ${position.accuracy}m');
            break;
          } else {
            _logger.w('GPS accuracy poor: ${position.accuracy}m (threshold: $_accuracyThreshold m)');
            
            if (retryCount < _maxRetries - 1) {
              _logger.d('Waiting ${_retryDelay.inSeconds}s before retry...');
              await Future.delayed(_retryDelay);
            }
          }
        } catch (e) {
          _logger.e('GPS acquisition failed: $e');
          
          if (retryCount < _maxRetries - 1) {
            _logger.d('Waiting ${_retryDelay.inSeconds}s before retry...');
            await Future.delayed(_retryDelay);
          }
        }

        retryCount++;
      }

      // Check if we got a position
      if (position == null) {
        _logger.e('Failed to acquire GPS position after $_maxRetries attempts');
        return const PayloadResult.failure(PayloadError.gpsUnavailable);
      }

      // Check final accuracy (allow slightly worse accuracy after retries)
      if (position.accuracy > 100.0) {
        _logger.e('GPS accuracy too poor: ${position.accuracy}m (max: 100m)');
        return const PayloadResult.failure(PayloadError.gpsInaccurate);
      }

      // Step 5: Generate UUID v4 for Message_ID
      final messageId = _uuid.v4();
      _logger.d('Generated message ID: $messageId');

      // Step 6: Record Unix epoch timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _logger.d('Timestamp: $timestamp');

      // Step 7: Create EmergencyPayload
      final payload = EmergencyPayload(
        id: messageId,
        lat: position.latitude,
        lng: position.longitude,
        ts: timestamp,
        type: emergencyType.value,
        hop: 0, // Initial hop count
        accuracy: position.accuracy,
      );

      _logger.i('Emergency payload generated successfully');
      _logger.d('Payload: ${payload.toJsonString()}');

      return PayloadResult.success(payload);
    } catch (e) {
      _logger.e('Unexpected error during payload generation: $e');
      return const PayloadResult.failure(PayloadError.unknownError);
    }
  }

  /// Check if GPS is accurate enough for emergency messaging
  /// 
  /// Returns true if current GPS accuracy is within threshold
  Future<bool> isGpsAccurate() async {
    try {
      _logger.d('Checking GPS accuracy...');

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('Location services disabled');
        return false;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _logger.w('Location permission not granted');
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: _gpsTimeout,
      );

      final isAccurate = position.accuracy <= _accuracyThreshold;
      _logger.d('GPS accuracy: ${position.accuracy}m (threshold: $_accuracyThreshold m) - ${isAccurate ? "PASS" : "FAIL"}');

      return isAccurate;
    } catch (e) {
      _logger.e('Error checking GPS accuracy: $e');
      return false;
    }
  }

  /// Get current GPS position without validation (for testing/debugging)
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: _gpsTimeout,
      );
    } catch (e) {
      _logger.e('Error getting current position: $e');
      return null;
    }
  }

  /// Get last known position (faster but may be stale)
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      _logger.e('Error getting last known position: $e');
      return null;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Get accuracy threshold
  double get accuracyThreshold => _accuracyThreshold;

  /// Get max retries
  int get maxRetries => _maxRetries;

  /// Get retry delay
  Duration get retryDelay => _retryDelay;
}
