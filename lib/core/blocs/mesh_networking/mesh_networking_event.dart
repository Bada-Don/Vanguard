import 'package:equatable/equatable.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';

abstract class MeshNetworkingEvent extends Equatable {
  const MeshNetworkingEvent();

  @override
  List<Object?> get props => [];
}

class StartMeshNetworkingEvent extends MeshNetworkingEvent {
  final String userName;
  const StartMeshNetworkingEvent({required this.userName});

  @override
  List<Object?> get props => [userName];
}

class StopMeshNetworkingEvent extends MeshNetworkingEvent {}

class ConnectionStateChangedEvent extends MeshNetworkingEvent {
  final ConnectionState state;
  const ConnectionStateChangedEvent(this.state);

  @override
  List<Object?> get props => [state];
}

class EndpointsUpdatedEvent extends MeshNetworkingEvent {
  final int count;
  const EndpointsUpdatedEvent(this.count);

  @override
  List<Object?> get props => [count];
}
