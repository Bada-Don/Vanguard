part of 'emergency_sos_dashboard_bloc.dart';

abstract class EmergencySOSDashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EmergencySOSDashboardInitialEvent extends EmergencySOSDashboardEvent {}

class InitializeSOSEvent extends EmergencySOSDashboardEvent {}

class UpdateConnectivityStatusEvent extends EmergencySOSDashboardEvent {
  final String status;

  UpdateConnectivityStatusEvent({required this.status});

  @override
  List<Object?> get props => [status];
}

class UpdateMeshNodesEvent extends EmergencySOSDashboardEvent {
  final int count;

  UpdateMeshNodesEvent({required this.count});

  @override
  List<Object?> get props => [count];
}

class NavigateToSettingsEvent extends EmergencySOSDashboardEvent {}
