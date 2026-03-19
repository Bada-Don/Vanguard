import 'package:equatable/equatable.dart';

/// Connection status enumeration
enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
  failed;

  String get displayName {
    switch (this) {
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.failed:
        return 'Failed';
    }
  }
}

/// Connection information for a nearby endpoint
/// Tracks the state and metadata of mesh network connections
class ConnectionInfo extends Equatable {
  /// Unique endpoint identifier
  final String endpointId;

  /// Human-readable endpoint name
  final String endpointName;

  /// Timestamp when connection was established
  final DateTime connectedAt;

  /// Current connection status
  final ConnectionStatus status;

  /// Last activity timestamp (optional)
  final DateTime? lastActivityAt;

  /// Number of messages sent to this endpoint
  final int messagesSent;

  /// Number of messages received from this endpoint
  final int messagesReceived;

  const ConnectionInfo({
    required this.endpointId,
    required this.endpointName,
    required this.connectedAt,
    required this.status,
    this.lastActivityAt,
    this.messagesSent = 0,
    this.messagesReceived = 0,
  });

  /// Create a copy with updated fields
  ConnectionInfo copyWith({
    String? endpointId,
    String? endpointName,
    DateTime? connectedAt,
    ConnectionStatus? status,
    DateTime? lastActivityAt,
    int? messagesSent,
    int? messagesReceived,
  }) {
    return ConnectionInfo(
      endpointId: endpointId ?? this.endpointId,
      endpointName: endpointName ?? this.endpointName,
      connectedAt: connectedAt ?? this.connectedAt,
      status: status ?? this.status,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      messagesSent: messagesSent ?? this.messagesSent,
      messagesReceived: messagesReceived ?? this.messagesReceived,
    );
  }

  /// Increment messages sent counter
  ConnectionInfo incrementMessagesSent() {
    return copyWith(
      messagesSent: messagesSent + 1,
      lastActivityAt: DateTime.now(),
    );
  }

  /// Increment messages received counter
  ConnectionInfo incrementMessagesReceived() {
    return copyWith(
      messagesReceived: messagesReceived + 1,
      lastActivityAt: DateTime.now(),
    );
  }

  /// Update connection status
  ConnectionInfo updateStatus(ConnectionStatus newStatus) {
    return copyWith(
      status: newStatus,
      lastActivityAt: DateTime.now(),
    );
  }

  /// Check if connection is active
  bool get isActive => status == ConnectionStatus.connected;

  /// Get connection duration
  Duration get connectionDuration {
    return DateTime.now().difference(connectedAt);
  }

  /// Get time since last activity
  Duration? get timeSinceLastActivity {
    if (lastActivityAt == null) return null;
    return DateTime.now().difference(lastActivityAt!);
  }

  @override
  List<Object?> get props => [
        endpointId,
        endpointName,
        connectedAt,
        status,
        lastActivityAt,
        messagesSent,
        messagesReceived,
      ];

  @override
  String toString() {
    return 'ConnectionInfo(endpointId: $endpointId, endpointName: $endpointName, status: $status, messagesSent: $messagesSent, messagesReceived: $messagesReceived)';
  }
}
