part of 'passive_node_dashboard_bloc.dart';

class PassiveNodeDashboardState extends Equatable {
  final PassiveNodeDashboardModel? passiveNodeDashboardModel;
  final int processedMessagesCount;
  final int queuedMessagesCount;
  final String? lastRelayTimestamp;
  final String? lastUplinkTimestamp;
  final bool uplinkActive;
  final int connectedEndpointsCount;
  final bool isRelayModeEnabled;

  PassiveNodeDashboardState({
    this.passiveNodeDashboardModel,
    this.processedMessagesCount = 0,
    this.queuedMessagesCount = 0,
    this.lastRelayTimestamp,
    this.lastUplinkTimestamp,
    this.uplinkActive = false,
    this.connectedEndpointsCount = 0,
    this.isRelayModeEnabled = true,
  });

  @override
  List<Object?> get props => [
        passiveNodeDashboardModel,
        processedMessagesCount,
        queuedMessagesCount,
        lastRelayTimestamp,
        lastUplinkTimestamp,
        uplinkActive,
        connectedEndpointsCount,
        isRelayModeEnabled,
      ];

  PassiveNodeDashboardState copyWith({
    PassiveNodeDashboardModel? passiveNodeDashboardModel,
    int? processedMessagesCount,
    int? queuedMessagesCount,
    String? lastRelayTimestamp,
    String? lastUplinkTimestamp,
    bool? uplinkActive,
    int? connectedEndpointsCount,
    bool? isRelayModeEnabled,
  }) {
    return PassiveNodeDashboardState(
      passiveNodeDashboardModel:
          passiveNodeDashboardModel ?? this.passiveNodeDashboardModel,
      processedMessagesCount:
          processedMessagesCount ?? this.processedMessagesCount,
      queuedMessagesCount: queuedMessagesCount ?? this.queuedMessagesCount,
      lastRelayTimestamp: lastRelayTimestamp ?? this.lastRelayTimestamp,
      lastUplinkTimestamp: lastUplinkTimestamp ?? this.lastUplinkTimestamp,
      uplinkActive: uplinkActive ?? this.uplinkActive,
      connectedEndpointsCount:
          connectedEndpointsCount ?? this.connectedEndpointsCount,
      isRelayModeEnabled: isRelayModeEnabled ?? this.isRelayModeEnabled,
    );
  }
}
