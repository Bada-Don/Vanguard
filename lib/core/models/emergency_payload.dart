import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Emergency type enumeration
enum EmergencyType {
  medical(1),
  fire(2),
  crime(3),
  naturalDisaster(4),
  accident(5),
  other(6);

  final int value;
  const EmergencyType(this.value);

  static EmergencyType fromValue(int value) {
    return EmergencyType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => EmergencyType.other,
    );
  }

  String get displayName {
    switch (this) {
      case EmergencyType.medical:
        return 'Medical';
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.crime:
        return 'Crime';
      case EmergencyType.naturalDisaster:
        return 'Natural Disaster';
      case EmergencyType.accident:
        return 'Accident';
      case EmergencyType.other:
        return 'Other';
    }
  }
}

/// Emergency payload model for mesh network transmission
/// Contains all information needed for emergency message propagation
class EmergencyPayload extends Equatable {
  /// Unique message identifier (UUID v4)
  final String id;

  /// Latitude coordinate (-90 to 90)
  final double lat;

  /// Longitude coordinate (-180 to 180)
  final double lng;

  /// Unix epoch timestamp
  final int ts;

  /// Emergency type (1-6)
  final int type;

  /// Hop count (number of relay transmissions)
  final int hop;

  /// GPS accuracy in meters (optional)
  final double? accuracy;

  const EmergencyPayload({
    required this.id,
    required this.lat,
    required this.lng,
    required this.ts,
    required this.type,
    required this.hop,
    this.accuracy,
  });

  /// Create payload from JSON map
  factory EmergencyPayload.fromJson(Map<String, dynamic> json) {
    return EmergencyPayload(
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      ts: json['ts'] as int,
      type: json['type'] as int,
      hop: json['hop'] as int,
      accuracy: json['accuracy'] != null 
          ? (json['accuracy'] as num).toDouble() 
          : null,
    );
  }

  /// Create payload from JSON string
  factory EmergencyPayload.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return EmergencyPayload.fromJson(json);
  }

  /// Convert payload to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': lat,
      'lng': lng,
      'ts': ts,
      'type': type,
      'hop': hop,
      if (accuracy != null) 'accuracy': accuracy,
    };
  }

  /// Convert payload to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create a copy with updated hop count
  EmergencyPayload incrementHop() {
    return EmergencyPayload(
      id: id,
      lat: lat,
      lng: lng,
      ts: ts,
      type: type,
      hop: hop + 1,
      accuracy: accuracy,
    );
  }

  /// Create a copy with updated fields
  EmergencyPayload copyWith({
    String? id,
    double? lat,
    double? lng,
    int? ts,
    int? type,
    int? hop,
    double? accuracy,
  }) {
    return EmergencyPayload(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      ts: ts ?? this.ts,
      type: type ?? this.type,
      hop: hop ?? this.hop,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  /// Get emergency type enum
  EmergencyType get emergencyType => EmergencyType.fromValue(type);

  /// Validate payload fields
  bool get isValid {
    return id.isNotEmpty &&
        lat >= -90 && lat <= 90 &&
        lng >= -180 && lng <= 180 &&
        ts > 0 &&
        type >= 1 && type <= 6 &&
        hop >= 0;
  }

  @override
  List<Object?> get props => [id, lat, lng, ts, type, hop, accuracy];

  @override
  String toString() {
    return 'EmergencyPayload(id: $id, lat: $lat, lng: $lng, ts: $ts, type: $type, hop: $hop, accuracy: $accuracy)';
  }
}
