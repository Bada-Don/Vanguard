part of 'passive_node_dashboard_bloc.dart';

abstract class PassiveNodeDashboardEvent extends Equatable {
  PassiveNodeDashboardEvent();

  @override
  List<Object?> get props => [];
}

class PassiveNodeDashboardInitialEvent extends PassiveNodeDashboardEvent {}

class ToggleSuspendNodeEvent extends PassiveNodeDashboardEvent {
  final bool value;

  ToggleSuspendNodeEvent({required this.value});

  @override
  List<Object?> get props => [value];
}
