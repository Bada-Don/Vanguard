import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:vanguard_crisis_response/core/blocs/mesh_networking/mesh_networking_bloc.dart';
import 'package:vanguard_crisis_response/core/services/nearby_service.dart';

class MockNearbyService extends Fake implements NearbyService {
  final StreamController<ConnectionState> _connController = StreamController<ConnectionState>.broadcast();
  int _endpoints = 0;
  bool startResult = true;

  @override
  Stream<ConnectionState> get connectionStateStream => _connController.stream;

  @override
  int get connectedEndpointsCount => _endpoints;

  @override
  Future<bool> startMeshNetworking(String userName) async {
    return startResult;
  }

  @override
  Future<bool> stopMeshNetworking() async {
    return true;
  }
}

void main() {
  group('MeshNetworkingBloc Tests', () {
    late MockNearbyService mockNearbyService;
    late MeshNetworkingBloc bloc;

    setUp(() {
      mockNearbyService = MockNearbyService();
      bloc = MeshNetworkingBloc(nearbyService: mockNearbyService);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is disconnected', () {
      expect(bloc.state.connectionState, ConnectionState.disconnected);
    });

    test('StartMeshNetworking emits starting then connected if successful', () async {
      mockNearbyService.startResult = true;
      bloc.add(StartMeshNetworkingEvent(userName: 'test_node'));
      
      await Future.delayed(Duration.zero);
      expect(bloc.state.isStarting, false);
      expect(bloc.state.errorMessage, null);
    });
    
    test('ConnectionStateChanged updates state', () async {
      bloc.add(ConnectionStateChangedEvent(ConnectionState.advertising));
      await Future.delayed(Duration.zero);
      expect(bloc.state.connectionState, ConnectionState.advertising);
    });
    
    test('EndpointsUpdatedEvent updates count', () async {
      bloc.add(EndpointsUpdatedEvent(5));
      await Future.delayed(Duration.zero);
      expect(bloc.state.connectedEndpointsCount, 5);
    });
  });
}
