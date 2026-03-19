import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

/// Validation error types
enum ValidationError {
  invalidMessageId,
  invalidLatitude,
  invalidLongitude,
  invalidTimestamp,
  invalidEmergencyType,
  invalidHopCount,
  timestampTooOld,
  missingRequiredField,
}

/// Validation result with detailed error information
class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;
  final List<String> errorMessages;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.errorMessages = const [],
  });

  factory ValidationResult.success() {
    return const ValidationResult(isValid: true);
  }

  factory ValidationResult.failure(
    List<ValidationError> errors,
    List<String> messages,
  ) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      errorMessages: messages,
    );
  }

  @override
  String toString() {
    if (isValid) return 'ValidationResult(valid)';
    return 'ValidationResult(invalid: ${errorMessages.join(', ')})';
  }
}

/// Payload validator for comprehensive payload validation
/// Prevents malformed messages from propagating through the mesh network
class PayloadValidator {
  static const double _minLatitude = -90.0;
  static const double _maxLatitude = 90.0;
  static const double _minLongitude = -180.0;
  static const double _maxLongitude = 180.0;
  static const int _minEmergencyType = 1;
  static const int _maxEmergencyType = 6;
  static const int _maxTimestampAge = 24 * 60 * 60 * 1000; // 24 hours in milliseconds

  final Logger _logger;
  final Uuid _uuid;

  PayloadValidator({
    Logger? logger,
    Uuid? uuid,
  })  : _logger = logger ?? Logger(),
        _uuid = uuid ?? const Uuid();

  /// Validate complete payload
  /// 
  /// Checks:
  /// - Message ID is valid UUID v4
  /// - Latitude is between -90 and 90
  /// - Longitude is between -180 and 180
  /// - Timestamp is positive and within last 24 hours
  /// - Emergency type is between 1 and 6
  /// - Hop count is non-negative
  ValidationResult validatePayload(Map<String, dynamic> payload) {
    _logger.d('Validating payload: $payload');

    final errors = <ValidationError>[];
    final messages = <String>[];

    // Validate message ID
    final messageIdError = _validateMessageId(payload['id']);
    if (messageIdError != null) {
      errors.add(messageIdError);
      messages.add(_getErrorMessage(messageIdError, payload['id']));
    }

    // Validate latitude
    final latError = _validateLatitude(payload['lat']);
    if (latError != null) {
      errors.add(latError);
      messages.add(_getErrorMessage(latError, payload['lat']));
    }

    // Validate longitude
    final lngError = _validateLongitude(payload['lng']);
    if (lngError != null) {
      errors.add(lngError);
      messages.add(_getErrorMessage(lngError, payload['lng']));
    }

    // Validate timestamp
    final tsError = _validateTimestamp(payload['ts']);
    if (tsError != null) {
      errors.add(tsError);
      messages.add(_getErrorMessage(tsError, payload['ts']));
    }

    // Validate emergency type
    final typeError = _validateEmergencyType(payload['type']);
    if (typeError != null) {
      errors.add(typeError);
      messages.add(_getErrorMessage(typeError, payload['type']));
    }

    // Validate hop count
    final hopError = _validateHopCount(payload['hop']);
    if (hopError != null) {
      errors.add(hopError);
      messages.add(_getErrorMessage(hopError, payload['hop']));
    }

    if (errors.isEmpty) {
      _logger.d('Payload validation successful');
      return ValidationResult.success();
    } else {
      _logger.w('Payload validation failed: ${messages.join(', ')}');
      return ValidationResult.failure(errors, messages);
    }
  }

  /// Validate message ID is valid UUID v4 format
  ValidationError? _validateMessageId(dynamic id) {
    if (id == null) {
      return ValidationError.missingRequiredField;
    }

    if (id is! String) {
      return ValidationError.invalidMessageId;
    }

    if (id.isEmpty) {
      return ValidationError.invalidMessageId;
    }

    // Check UUID v4 format using regex
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    if (!uuidRegex.hasMatch(id)) {
      return ValidationError.invalidMessageId;
    }

    return null;
  }

  /// Validate latitude is between -90 and 90 degrees
  ValidationError? _validateLatitude(dynamic lat) {
    if (lat == null) {
      return ValidationError.missingRequiredField;
    }

    if (lat is! num) {
      return ValidationError.invalidLatitude;
    }

    final latValue = lat.toDouble();

    if (latValue < _minLatitude || latValue > _maxLatitude) {
      return ValidationError.invalidLatitude;
    }

    return null;
  }

  /// Validate longitude is between -180 and 180 degrees
  ValidationError? _validateLongitude(dynamic lng) {
    if (lng == null) {
      return ValidationError.missingRequiredField;
    }

    if (lng is! num) {
      return ValidationError.invalidLongitude;
    }

    final lngValue = lng.toDouble();

    if (lngValue < _minLongitude || lngValue > _maxLongitude) {
      return ValidationError.invalidLongitude;
    }

    return null;
  }

  /// Validate timestamp is positive integer within last 24 hours
  ValidationError? _validateTimestamp(dynamic ts) {
    if (ts == null) {
      return ValidationError.missingRequiredField;
    }

    if (ts is! int) {
      return ValidationError.invalidTimestamp;
    }

    if (ts <= 0) {
      return ValidationError.invalidTimestamp;
    }

    // Check if timestamp is within last 24 hours
    final now = DateTime.now().millisecondsSinceEpoch;
    final age = now - ts;

    if (age > _maxTimestampAge) {
      return ValidationError.timestampTooOld;
    }

    // Also check if timestamp is not in the future (allow 5 minute clock skew)
    if (age < -300000) {
      return ValidationError.invalidTimestamp;
    }

    return null;
  }

  /// Validate emergency type is integer between 1 and 6
  ValidationError? _validateEmergencyType(dynamic type) {
    if (type == null) {
      return ValidationError.missingRequiredField;
    }

    if (type is! int) {
      return ValidationError.invalidEmergencyType;
    }

    if (type < _minEmergencyType || type > _maxEmergencyType) {
      return ValidationError.invalidEmergencyType;
    }

    return null;
  }

  /// Validate hop count is non-negative integer
  ValidationError? _validateHopCount(dynamic hop) {
    if (hop == null) {
      return ValidationError.missingRequiredField;
    }

    if (hop is! int) {
      return ValidationError.invalidHopCount;
    }

    if (hop < 0) {
      return ValidationError.invalidHopCount;
    }

    return null;
  }

  /// Get descriptive error message for validation error
  String _getErrorMessage(ValidationError error, dynamic value) {
    switch (error) {
      case ValidationError.invalidMessageId:
        return 'Invalid message ID: must be valid UUID v4 format (got: $value)';
      case ValidationError.invalidLatitude:
        return 'Invalid latitude: must be between $_minLatitude and $_maxLatitude degrees (got: $value)';
      case ValidationError.invalidLongitude:
        return 'Invalid longitude: must be between $_minLongitude and $_maxLongitude degrees (got: $value)';
      case ValidationError.invalidTimestamp:
        return 'Invalid timestamp: must be positive integer (got: $value)';
      case ValidationError.timestampTooOld:
        return 'Timestamp too old: must be within last 24 hours (got: $value)';
      case ValidationError.invalidEmergencyType:
        return 'Invalid emergency type: must be between $_minEmergencyType and $_maxEmergencyType (got: $value)';
      case ValidationError.invalidHopCount:
        return 'Invalid hop count: must be non-negative integer (got: $value)';
      case ValidationError.missingRequiredField:
        return 'Missing required field';
    }
  }

  /// Quick validation for message ID only
  bool isValidMessageId(String id) {
    return _validateMessageId(id) == null;
  }

  /// Quick validation for coordinates
  bool areValidCoordinates(double lat, double lng) {
    return _validateLatitude(lat) == null && _validateLongitude(lng) == null;
  }

  /// Quick validation for timestamp
  bool isValidTimestamp(int ts) {
    return _validateTimestamp(ts) == null;
  }

  /// Quick validation for emergency type
  bool isValidEmergencyType(int type) {
    return _validateEmergencyType(type) == null;
  }

  /// Quick validation for hop count
  bool isValidHopCount(int hop) {
    return _validateHopCount(hop) == null;
  }

  /// Get validation constraints for documentation
  Map<String, dynamic> get validationConstraints {
    return {
      'messageId': 'UUID v4 format',
      'latitude': {'min': _minLatitude, 'max': _maxLatitude},
      'longitude': {'min': _minLongitude, 'max': _maxLongitude},
      'timestamp': 'Positive integer within last 24 hours',
      'emergencyType': {'min': _minEmergencyType, 'max': _maxEmergencyType},
      'hopCount': 'Non-negative integer',
    };
  }
}
