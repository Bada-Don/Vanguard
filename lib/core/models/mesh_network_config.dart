import 'dart:convert';
import 'package:equatable/equatable.dart';

/// Mesh network configuration model
/// Contains configurable parameters for mesh networking behavior
class MeshNetworkConfig extends Equatable {
  /// Maximum number of relay hops (3-5)
  final int maxHops;

  /// Maximum message queue size (50-200)
  final int messageQueueSize;

  /// Number of uplink retry attempts (1-5)
  final int uplinkRetryAttempts;

  /// Connection timeout in seconds (10-60)
  final int connectionTimeout;

  /// Scan frequency in seconds for discovery (5-30)
  final int scanFrequency;

  /// Enable background service
  final bool enableBackgroundService;

  /// Enable automatic uplink when internet available
  final bool enableAutoUplink;

  const MeshNetworkConfig({
    this.maxHops = 3,
    this.messageQueueSize = 100,
    this.uplinkRetryAttempts = 3,
    this.connectionTimeout = 30,
    this.scanFrequency = 10,
    this.enableBackgroundService = true,
    this.enableAutoUplink = true,
  });

  /// Default configuration
  static const MeshNetworkConfig defaultConfig = MeshNetworkConfig();

  /// Validate configuration values
  bool get isValid {
    return maxHops >= 3 && maxHops <= 5 &&
        messageQueueSize >= 50 && messageQueueSize <= 200 &&
        uplinkRetryAttempts >= 1 && uplinkRetryAttempts <= 5 &&
        connectionTimeout >= 10 && connectionTimeout <= 60 &&
        scanFrequency >= 5 && scanFrequency <= 30;
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (maxHops < 3 || maxHops > 5) {
      errors.add('Max hops must be between 3 and 5');
    }
    
    if (messageQueueSize < 50 || messageQueueSize > 200) {
      errors.add('Message queue size must be between 50 and 200');
    }
    
    if (uplinkRetryAttempts < 1 || uplinkRetryAttempts > 5) {
      errors.add('Uplink retry attempts must be between 1 and 5');
    }
    
    if (connectionTimeout < 10 || connectionTimeout > 60) {
      errors.add('Connection timeout must be between 10 and 60 seconds');
    }
    
    if (scanFrequency < 5 || scanFrequency > 30) {
      errors.add('Scan frequency must be between 5 and 30 seconds');
    }
    
    return errors;
  }

  /// Create configuration from JSON map
  factory MeshNetworkConfig.fromJson(Map<String, dynamic> json) {
    return MeshNetworkConfig(
      maxHops: json['maxHops'] as int? ?? 3,
      messageQueueSize: json['messageQueueSize'] as int? ?? 100,
      uplinkRetryAttempts: json['uplinkRetryAttempts'] as int? ?? 3,
      connectionTimeout: json['connectionTimeout'] as int? ?? 30,
      scanFrequency: json['scanFrequency'] as int? ?? 10,
      enableBackgroundService: json['enableBackgroundService'] as bool? ?? true,
      enableAutoUplink: json['enableAutoUplink'] as bool? ?? true,
    );
  }

  /// Create configuration from JSON string
  factory MeshNetworkConfig.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return MeshNetworkConfig.fromJson(json);
  }

  /// Convert configuration to JSON map
  Map<String, dynamic> toJson() {
    return {
      'maxHops': maxHops,
      'messageQueueSize': messageQueueSize,
      'uplinkRetryAttempts': uplinkRetryAttempts,
      'connectionTimeout': connectionTimeout,
      'scanFrequency': scanFrequency,
      'enableBackgroundService': enableBackgroundService,
      'enableAutoUplink': enableAutoUplink,
    };
  }

  /// Convert configuration to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create a copy with updated fields
  MeshNetworkConfig copyWith({
    int? maxHops,
    int? messageQueueSize,
    int? uplinkRetryAttempts,
    int? connectionTimeout,
    int? scanFrequency,
    bool? enableBackgroundService,
    bool? enableAutoUplink,
  }) {
    return MeshNetworkConfig(
      maxHops: maxHops ?? this.maxHops,
      messageQueueSize: messageQueueSize ?? this.messageQueueSize,
      uplinkRetryAttempts: uplinkRetryAttempts ?? this.uplinkRetryAttempts,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      scanFrequency: scanFrequency ?? this.scanFrequency,
      enableBackgroundService: enableBackgroundService ?? this.enableBackgroundService,
      enableAutoUplink: enableAutoUplink ?? this.enableAutoUplink,
    );
  }

  @override
  List<Object?> get props => [
        maxHops,
        messageQueueSize,
        uplinkRetryAttempts,
        connectionTimeout,
        scanFrequency,
        enableBackgroundService,
        enableAutoUplink,
      ];

  @override
  String toString() {
    return 'MeshNetworkConfig(maxHops: $maxHops, messageQueueSize: $messageQueueSize, uplinkRetryAttempts: $uplinkRetryAttempts, connectionTimeout: $connectionTimeout, scanFrequency: $scanFrequency, enableBackgroundService: $enableBackgroundService, enableAutoUplink: $enableAutoUplink)';
  }
}
