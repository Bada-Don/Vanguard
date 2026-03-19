part of 'passive_node_dashboard_bloc.dart';

class PassiveNodeDashboardState extends Equatable {
  final PassiveNodeDashboardModel? passiveNodeDashboardModel;

  PassiveNodeDashboardState({this.passiveNodeDashboardModel});

  @override
  List<Object?> get props => [passiveNodeDashboardModel];

  PassiveNodeDashboardState copyWith({
    PassiveNodeDashboardModel? passiveNodeDashboardModel,
  }) {
    return PassiveNodeDashboardState(
      passiveNodeDashboardModel:
          passiveNodeDashboardModel ?? this.passiveNodeDashboardModel,
    );
  }
}
