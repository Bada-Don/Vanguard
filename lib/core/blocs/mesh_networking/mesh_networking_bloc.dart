import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';
import 'mesh_networking_event.dart';
import 'mesh_networking_state.dart';

export 'mesh_networking_event.dart';
export 'mesh_networking_state.dart';

class MeshNetworkingBloc extends Bloc<MeshNetworkingEvent, MeshNetworkingState> {
  final NearbyService nearbyService;
  StreamSubscription? _connectionStateSub;

  MeshNetworkingBloc({required this.nearbyService})
      : super(const MeshNetworkingState()) {
    on<StartMeshNetworkingEvent>(_onStartMeshNetworking);
    on<StopMeshNetworkingEvent>(_onStopMeshNetworking);
    on<ConnectionStateChangedEvent>(_onConnectionStateChanged);
    on<EndpointsUpdatedEvent>(_onEndpointsUpdated);

    _connectionStateSub = nearbyService.connectionStateStream.listen((state) {
      add(ConnectionStateChangedEvent(state));
      add(EndpointsUpdatedEvent(nearbyService.connectedEndpointsCount));
    });
  }

  Future<void> _onStartMeshNetworking(
      StartMeshNetworkingEvent event, Emitter<MeshNetworkingState> emit) async {
    emit(state.copyWith(isStarting: true, clearErrorMessage: true));
    try {
      final success = await nearbyService.startMeshNetworking(event.userName);
      if (!success) {
        emit(state.copyWith(
            errorMessage: 'Failed to start mesh networking', isStarting: false));
      } else {
        emit(state.copyWith(isStarting: false));
      }
    } catch (e) {
      emit(state.copyWith(
          errorMessage: 'Error starting mesh networking: $e', isStarting: false));
    }
  }

  Future<void> _onStopMeshNetworking(
      StopMeshNetworkingEvent event, Emitter<MeshNetworkingState> emit) async {
    await nearbyService.stopMeshNetworking();
  }

  void _onConnectionStateChanged(
      ConnectionStateChangedEvent event, Emitter<MeshNetworkingState> emit) {
    emit(state.copyWith(connectionState: event.state));
  }

  void _onEndpointsUpdated(
      EndpointsUpdatedEvent event, Emitter<MeshNetworkingState> emit) {
    emit(state.copyWith(connectedEndpointsCount: event.count));
  }

  @override
  Future<void> close() {
    _connectionStateSub?.cancel();
    return super.close();
  }
}
