import 'package:equatable/equatable.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';

class MeshNetworkingState extends Equatable {
  final ConnectionState connectionState;
  final int connectedEndpointsCount;
  final int? lastTransmissionTime;
  final String? errorMessage;
  final bool isStarting;

  const MeshNetworkingState({
    this.connectionState = ConnectionState.disconnected,
    this.connectedEndpointsCount = 0,
    this.lastTransmissionTime,
    this.errorMessage,
    this.isStarting = false,
  });

  MeshNetworkingState copyWith({
    ConnectionState? connectionState,
    int? connectedEndpointsCount,
    int? lastTransmissionTime,
    String? errorMessage,
    bool? isStarting,
    bool clearErrorMessage = false,
  }) {
    return MeshNetworkingState(
      connectionState: connectionState ?? this.connectionState,
      connectedEndpointsCount: connectedEndpointsCount ?? this.connectedEndpointsCount,
      lastTransmissionTime: lastTransmissionTime ?? this.lastTransmissionTime,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isStarting: isStarting ?? this.isStarting,
    );
  }

  @override
  List<Object?> get props => [
        connectionState,
        connectedEndpointsCount,
        lastTransmissionTime,
        errorMessage,
        isStarting,
      ];
}
